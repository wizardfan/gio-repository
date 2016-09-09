#!/usr/bin/perl -w
use strict;
#define the temp folder for the middle files
my $tmpFolder="/tmp/searchgui";
system ("mkdir $tmpFolder") unless (-d $tmpFolder);

my $config = $ARGV[0];#the config file contains all settings
my $output = $ARGV[1];#the output file, should be temporary
my $path = $ARGV[2];#galaxy temp folder, used to locate executables
my $id = $ARGV[3];#new job id to be distinguished from other SearchGUI search
my $omssa_result = $ARGV[4];
my $msgf_result = $ARGV[5];
my $tandem_result = $ARGV[6];

open OUT,">$output";
my $version="3.1.0";
my $applicationPath = "$path/../../../gio_applications";
my $jarFile = "$applicationPath/searchgui/SearchGUI/SearchGUI-${version}-javaLib.jar";
unless (-e $jarFile){
	print OUT "Error: Cannot locate the jar file at $jarFile\n";
	exit 1;
}

print OUT "New file folder: $path\n";
print OUT "New job id: $id\n\n";

my $javaStr = "java -Xmx1024M";
my $line;
open IN,"$config";
my @spectra;
$line = <IN>;#the spectra header
while($line=<IN>){
	chomp $line;
	last if (length $line==0);
	push (@spectra,$line);
}
print OUT "spectra:\n@spectra\n\n";

my $type=<IN>;#the type of the database, either built-in or uploaded file
chomp $type;
my $database=<IN>;#the fasta database file
chomp $database;
print OUT "$type: $database\n";
#generate the decoy database
my $original;
my $decoy;
if($type eq "upload"){
	my $series;
	my $serial;
	if($database=~/\/(\d+)\/dataset_(\d+)\.dat$/){
		$series=$1;
		$serial=$2;
	}
	$original = "$tmpFolder/seq_${series}_${serial}.fasta";
	$decoy = "$tmpFolder/seq_${series}_${serial}_concatenated_target_decoy.fasta";
}else{
	$original = $database;
	if($original=~/\.fasta$/){
		$decoy = "$`_concatenated_target_decoy.fasta";	
	}
}
print OUT "Original fasta: $original\n";
print OUT "Decoy: $decoy\n";
unless (-e $decoy){
	print OUT ("cp $database $original\n") if ($type eq "upload");
	system("cp $database $original") if ($type eq "upload");
	print OUT "$javaStr -cp $jarFile eu.isas.searchgui.cmd.FastaCLI -in $original -decoy\n";
	system("$javaStr -cp $jarFile eu.isas.searchgui.cmd.FastaCLI -in $original -decoy");
	system("rm $original") if ($type eq "upload");	
}

#generate parameter file
$line=<IN>;#empty line
$line=<IN>;#header line
$line=<IN>;
chomp $line;
my $identification = $line;
my $cmd = "$javaStr -cp $jarFile eu.isas.searchgui.cmd.IdentificationParametersCLI -db $decoy -out $tmpFolder/search_$id ";
if($identification =~/ \-fixed_mods (.+) \-variable_mods (.+)$/){
	$cmd .= $`;
	$cmd .= " -fixed_mods \"$1\"" unless ($1 eq "None");
	$cmd .= " -variable_mods \"$2\"" unless ($2 eq "None");
}
print OUT "$cmd\n";
system($cmd);

#execute SearchGUI command line
$line=<IN>;#empty line
$line=<IN>;#header line
$line=<IN>;
chomp $line;
my $search = $line;
print OUT "search from config: $search\n";
my $xtandem;
my $msgf;
my $omssa;
if($search =~ /-xtandem (\d) -msgf (\d) -omssa (\d)/){
	$xtandem = $1;
	$msgf = $2;
	$omssa = $3;
}
print OUT ("mkdir $tmpFolder/result$id\n");
system("mkdir $tmpFolder/result$id");
my $searchCmd = "$javaStr -cp $jarFile eu.isas.searchgui.cmd.SearchCLI -spectrum_files ";
my @mgf;
my @historyIDs;
for (my $i=0;$i<scalar @spectra;$i++){
	my ($spectra,$hid) = split(" ",$spectra[$i]);
	my $mgf = "$tmpFolder/spectra_${id}_$i.mgf";
	print OUT "cp $spectra $mgf\n";
	system ("cp $spectra $mgf");
	push (@mgf, $mgf); 
	push (@historyIDs, $hid);
}
my $spectraStr = join(",", @mgf);
$searchCmd .= "$spectraStr -output_folder $tmpFolder/result$id -id_params $tmpFolder/search_$id.par -mgf_splitting 8000 $search 2> /dev/null";
print OUT "search command: $searchCmd\n\n\n";
#open CMD, "$searchCmd |";
#while(<CMD>){
#	print OUT "$_";
#}
system ($searchCmd);
system ("unzip $tmpFolder/result$id/searchgui_out.zip -d $tmpFolder/result$id");
print OUT "unzip $tmpFolder/result$id/searchgui_out.zip -d $tmpFolder/result$id\n";

#deal with the result files
for (my $i=0;$i < scalar @spectra;$i++){
	my $prefix = "$tmpFolder/result$id/spectra_${id}_$i";
	if($msgf == 1){
		system("cp ${prefix}.msgf.mzid $msgf_result");
	}
	if($omssa == 1){
		$cmd = "$javaStr -jar $applicationPath/mzidlib/mzidlib-1.6.11-javaLib.jar Omssa2mzid ${prefix}.omx ${prefix}-omssa.mzid -outputFragmentation false -decoyRegex REVERSED -omssaModsFile $tmpFolder/result$id/omssa_mods.xml -userModsFile $tmpFolder/result$id/omssa_usermods.xml -compress false";
		print OUT "OMSSA conversion: $cmd\n";
		system ($cmd);
		system("cp ${prefix}-omssa.mzid $omssa_result");
	}
	if($xtandem == 1){
		$cmd = "$javaStr -jar $applicationPath/mzidlib/mzidlib-1.6.11-javaLib.jar Tandem2mzid ${prefix}.t.xml ${prefix}-tandem.mzid -outputFragmentation false -decoyRegex REVERSED -databaseFileFormatID MS:1001348 -massSpecFileFormatID MS:1001062 -idsStartAtZero false -proteinCodeRegex \\\\S+ -compress false";
		print OUT "Tandem conversion: $cmd\n";
		system ($cmd);
		system("cp ${prefix}-tandem.mzid $tandem_result");
	}
}

close OUT;
opendir DIR, "$tmpFolder/result$id/";
my @files = readdir DIR;
foreach my $file(@files){
	if ($file=~/SearchGUI Report .+\.html$/){
		print "cp \"$tmpFolder/result$id/$file\" $output\n";
		system ("cp \"$tmpFolder/result$id/$file\" $output");
		last;
	}
}

#clear all temp files
system("rm $tmpFolder/search_$id.par");
system("rm -rf $tmpFolder/result$id");
for (my $i=0;$i<scalar @spectra;$i++){
	system ("rm $tmpFolder/spectra_${id}_$i.mgf*");
}

