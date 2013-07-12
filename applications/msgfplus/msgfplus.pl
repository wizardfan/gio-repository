#!/usr/bin/perl -w
use strict;

my $input = $ARGV[0];
my $type = $ARGV[1];
my $data_source = $ARGV[2];
my $fasta = $ARGV[3];
my $output = $ARGV[4];
my $mods = $ARGV[5];
my $id = $ARGV[6];
my $path = $ARGV[7];
my $args = $ARGV[8];
for (my $i = 9;$i<scalar @ARGV;$i++){
	$args .=" $ARGV[$i]";
}
#$args = join(" ",@args) if ((scalar @args) > 0);
#open OUT,">$output";
#print OUT "Spectral file: $input\n";
#print OUT "Spectral type: $type\n";
#print OUT "Protein database file: $fasta\n";
#print OUT "Output file: $output\n";
#print OUT "ID: $id\n";
#print OUT "Output path: $path\n";
#print OUT "Argument list: $args\n";
#close OUT;
#exit;
open IN, "$mods";
my $line = <IN>;
my $flag = "fix";
#first line is the flag line fixed
open OUT,">/$path/tmp_$id.mods";
print OUT "NumMods = 2\n";
while($line=<IN>){
	chomp($line);
	if($line eq "variable"){
		$flag = "opt";
		next;
	}
	next if ($line eq "None");
	next if ($line eq "fixed");
	my @elmts = split(",",$line);
	foreach my $elmt(@elmts){
		my @tmp = split(":",$elmt);
		print OUT "$tmp[0],$tmp[1],$flag,$tmp[2],$tmp[3]\n";
	}
}
close OUT;

system("cp $input /$path/tmp_$id.$type");
my $fasta_file;
if ($data_source eq "built-in"){
	$fasta_file = $fasta;
}else{
	system("cp $fasta /$path/tmp_$id.fasta");
	$fasta_file = "/$path/tmp_$id.fasta";
}
my $str = "java -Xmx3500M -jar /$path/../../../gio_applications/msgfplus/MSGFPlus.jar -s /$path/tmp_$id.$type -d $fasta_file -o /$path/tmp_$id.mzid -mod /$path/tmp_$id.mods $args";
#print "$str\n";
system($str);
system("mv /$path/tmp_$id.mzid $output");
system("rm /$path/tmp_$id.$type");
system("rm /$path/tmp_$id.fasta") unless ($data_source eq "built-in");

