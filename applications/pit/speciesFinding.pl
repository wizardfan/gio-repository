#!/usr/bin/perl -w
use strict;
use POSIX;
use constant {BLASTDB => "BLASTDB", MIDDLE => "blastMiddleFiles", FINAL => "nr"};
my $blastDBdir = "";
my $deleteCmd = "";
my $cmdLocation = "";
my $coreSetting = "";

my $argLen = scalar @ARGV;
if($argLen < 3){
	print "Error: Not enough parameters\n";
	&usage();
	exit 1;
}

my ($file, $threshold, $output, @dbsIn) = @ARGV;
unless ($threshold=~/^\d*\.*\d+$/){
	print "The given threshold is not a valid positive number\n";
	exit 3;
}

if ($threshold < 50){
	$threshold = 50;
	print "WARNING: the given threshold is below 50, which is automatically set to 50 to make it reasonable\n";
}

#print "$^O\n";
my $os = lc($^O);
#http://perldoc.perl.org/perlport.html#DOS-and-Derivatives
if($os eq "mswin32" || $os eq "cygwin" || $os eq "dos" || $os eq "os2"){
	if(exists $ENV{BLASTDB}){
		$blastDBdir = $ENV{BLASTDB};
	}
	$deleteCmd = "del";
	print "OS system detected as Windows\n";
}else{
	open IN, "$ENV{HOME}/.ncbirc" or die "The OS is detected as linux based. Can not find the BLAST environment file $ENV{HOME}/.ncbirc\n";
	<IN>;
	my $line = <IN>;
	chomp $line;
	my @elmts = split("=",$line);
	$blastDBdir = $elmts[1];
	$deleteCmd = "rm";

#	$cmdLocation = "$ENV{HOME}/gio_applications/pit/";
	my @tmp = split("\/",$file);
	my @kept;
	for (my $i = 0;$i < ((scalar @tmp)-1);$i++){
		last if ($tmp[$i] eq "database" && $tmp[$i+1] eq "files");
		push (@kept,$tmp[$i]);
	}
	pop @kept;
	my $abc = join("\/",@kept);
#	the line below is for execution outside Galaxy
#	$abc = "/home/galaxy";
	$cmdLocation = "$abc/gio_applications/pit/";
	close IN;
	print "Command location: $cmdLocation\n";
	open IN, "$abc/gio_applications/coreSetting.conf" or die "Could not find coreSetting.conf under gio_applications folder which is distributed with gio-repository";
	while ($line=<IN>){
		next if($line=~/^#/);
		chomp ($line);
		my ($program,$number) = split("\t",$line);
		if($program eq "blast") {
			$coreSetting = "-num_threads $number";
			last;	
		}
	}
	
	print "OS system detected as Unix-based\n";
}

if(length $blastDBdir == 0){
	print "No environment variable found for BLASTDB which tells the program where the BLAST db is. Please ask the admin to set up properly\n";
	exit 2;
}
#print "program blastp location: $cmdLocation\n";
my %availableDBs;
&getAvailableBLASTdbs();
&printAvailableBLASTdbs();

my @dbs;
$"="\n";
#check whether the selected BLAST database is available on the server to use
foreach my $db(@dbsIn){
	unless(exists $availableDBs{$db}){
		print "The given database $db is not available on this server\n";
		&printAvailableBLASTdbs();
		exit 4;
	}
	push (@dbs, $db) unless ($db eq FINAL);
}
#push (@dbs, FINAL);
print "BLAST databases to be searched:\n@dbs\n";

#start real business here
#   Background:
#   In the BLAST analysis, tabular file format is used to retrieve information easily
#       Among the columns, qseqid (query sequence id) is important which helps to identify the protein header in 
#   the qseqid is the part before the first white space in the fasta header, e.g. qseqid sp|P17535|JUND_HUMAN for the header >sp|P17535|JUND_HUMAN Transcription factor jun-D OS=Homo sapiens GN=JUND PE=1 SV=3
#       To simplify things, first convert into auto_incremental numbers
#   if no hits found for one sequence, no qseqid in the result, i.e. got omitted
#       e.g. the query sequence is too short, therefore all_species_ident could be null 
#   using -max_target_seqs <num_top_hits> option to reduce computation time by only calculating the top hit(s)
#       however multiple hits from the same protein will be included
#       for a single species database, num_top_hits = 3 to indicate whether it is a conserved segment shared by proteins
#       for all species database (FINAL one) use 5 instead to include more proteins
#   Algorithm:
#   1. Replace the original fasta header with serial number and saved into a new temp file
#	2. Blast the whole temp fasta file against each database in the given list excluding the all-species one
#   3. Parse the blast result file to get the top hit(s) and the highest identity percentage. 
#		i.	If the score is no less than the threshold, 1) record the identity percentage and the hit protein 2) remove from the list for all-species BLAST. If more than one hit sharing the same highest identity percentage, keep all of them, separate by “,”
#		ii.	If the score is below the threshold, record NA for both protein hit and identity percentage
#   4. Generate the fasta file for sequences which need to blast against all species database. Likewise do step 3 blast result analysis
#         the clever part is that use database FINAL as the hash key which make it possible to re-use the two subroutines
#   5. Output the result
#	a.	The header is sequence id, protein sequence, species 1 hit proteins, species 1 hit identity percentage, …, all-species hit protein, all-species hit identity percentage, all-species search needed
#	b.	For those with at least one significant hit from the selected species BLASTs, output the corresponding data before the column of all-species hit protein
#	c.	Assign the value of No to column all-species search needed
#	d.	Get the highest identity percentage from all available species BLAST search and assign as the value for column of all-species hit identity percentage with the corresponding hit protein

#step 1
open IN, "$file";
my $tmpFile = "$file-".localtime.".tmp";
$tmpFile=~s/\s+/_/g;
$tmpFile=~s/:/_/g;
open TMP, ">$tmpFile" or die "Could not write into file <$tmpFile>";
my $proteinCount = 0;#protein serial number
my $header = "";
my $seq = "";
my %result;#the first keys are the information type and the second keys are the serial numbers in the temp fasta file
while (my $line = <IN>){
	$line=~s/\r?\n$//;#similar to chomp function but better in the case of reading windows file in Linux (different line ending char)
	if ($line=~/^>/){
		unless (length $seq == 0){
			$seq=~s/\s+//g;
			$result{'need_all_species'}{$proteinCount} = $seq;
			$result{'sequence'}{$proteinCount} = $seq;
			$seq = "";
		}
		$proteinCount++;
		$header=substr($line,1);
		$result{'headers'}{$proteinCount}=$header;
		$result{'all_max_ident'}{$proteinCount} = -1; # max identity percentage 
		$result{'all_max_hit'}{$proteinCount} = ""; # max identity protein accession
		$result{'all_max_title'}{$proteinCount} = ""; # max identity protein description
		print TMP ">$proteinCount\n";
	}else{
       	$seq .= $line; # add sequence
       	print TMP "$line\n";
	}
}
$seq=~s/\s+//g;
$result{'need_all_species'}{$proteinCount} = $seq;
$result{'sequence'}{$proteinCount} = $seq;
close TMP;
#print "\n$proteinCount\n$result{'need_all_species'}{$proteinCount}\n";
#step 2 and 3
open OUT, ">$output";
print OUT "Serial\tProtein\tSequence";
foreach my $db(@dbs){
	print OUT "\t$db hit\t$db identity";
	my $blastFile = "blast_result_$db.tsv";
	system ("${cmdLocation}blastp -db $db -query $tmpFile $coreSetting -outfmt \"6 qseqid sacc stitle pident\" -max_target_seqs 3 -out $blastFile");
	&parseBLASTresult($db,$blastFile);
}
system ("$deleteCmd $tmpFile");
print OUT "\tBest hit from all searches\tBest identity from all searches\tHit titles\tAll species search needed\n";
#step 4
#now deal with sequences need to be blasted against all species
my %tmp = %{$result{'need_all_species'}};
my @tmp = sort {$a <=> $b} keys %tmp;
if (scalar @tmp>0){
	my $tmpFile = "all_species.fasta";
	my $blastFile = "all_species_result.tsv";
	open TMP, ">$tmpFile";
	foreach my $curr(@tmp){
		print TMP ">$curr\n$tmp{$curr}\n";
	}
	close TMP;
	system ("${cmdLocation}blastp -db ".FINAL." -query $tmpFile $coreSetting -outfmt \"6 qseqid sacc stitle pident\" -max_target_seqs 5 -out $blastFile");
	&parseBLASTresult(FINAL,$blastFile);
}
#step 5
#finish populating the result data structure, now do the output.
for (my $i=1;$i<=$proteinCount;$i++){
	print OUT "$i\t$result{'headers'}{$i}\t$result{'sequence'}{$i}";
	foreach my $db(@dbs){
		if (exists $result{$db}{$i}{'ident'}){
			print OUT "\t$result{$db}{$i}{'ident'}\t$result{$db}{$i}{'hit'}";
		}else{
			print OUT "\tNA\tNot Found";
		}
	}
	if(exists $result{'need_all_species'}{$i}){
		print "need all species: $i\n";
		if(exists $result{FINAL}{$i}{'ident'}){
			print OUT "\t$result{FINAL}{$i}{'ident'}\t$result{FINAL}{$i}{'hit'}\t$result{FINAL}{$i}{'title'}\tYes\n";
		}else{
			print OUT "\tNA\tNot Found\tNA\tYes\n";
		}
	}else{
		print OUT "\t$result{'all_max_ident'}{$i}\t$result{'all_max_hit'}{$i}\t$result{'all_max_title'}{$i}\tNo\n";
	}
}
close OUT;
#separate the result file into groups by the sequential seq ids
sub parseBLASTresult(){
	my ($db,$blastFile) = @_;
	open RESULT, "$blastFile";
	my $previous = 0;
	my @curr; 
	while(my $line=<RESULT>){
		chomp $line;
		#qseqid sacc stitle pident
		my ($qseqid) = split("\t",$line);
		if ($qseqid != $previous && $previous != 0){
			&dealWithOneProtein($previous,$db,join(";",@curr));
			@curr=();
		}
		$previous = $qseqid;
		push (@curr,$line);
	}
	close RESULT;
	&dealWithOneProtein($previous,$db,join(";",@curr));
}
#step 3 parse the BLAST result lines
sub dealWithOneProtein(){
	my $id = $_[0];
	my $db = $_[1];
	my @arr = split(";",$_[2]);
	my $line = shift @arr;
	my %tmp;
#	print "record $id\n$line\nremaining\n";
	my (undef,$acc,$title,$ident) = split("\t",$line);
	$result{$db}{$id}{'ident'} = $ident;
	$tmp{$acc} = $title;
	#based on blast result file is organized by descending identity order
	foreach my $line(@arr){
		(undef,$acc,$title,$ident) = split("\t",$line);
		if ($result{$db}{$id}{'ident'} == $ident){
			$tmp{$acc} = $title;
		}else{
			last;
		}
#		print "$line\n";
	}
	my $hitStr = "";
	my $titleStr = "";
	foreach my $abc (keys %tmp){
		$hitStr .= ";$abc";
		$titleStr .= ";$tmp{$abc}";
	}
	$result{$db}{$id}{'hit'}=substr($hitStr,1);
	$result{$db}{$id}{'title'} = substr($titleStr,1);

#	print "\nidentity:<$result{$db}{$id}{'ident'}> from protein <$result{$db}{$id}{'hit'}>\n\n";
	return if ($db eq FINAL);
		#do the judgement
	if ($result{$db}{$id}{'ident'} >= $threshold){
		#pass the threshold, no need to do all species search
		delete $result{'need_all_species'}{$id} if (exists $result{'need_all_species'}{$id}); 
		if ($result{$db}{$id}{'ident'} > $result{'all_max_ident'}{$id}){#ident from current database is greater than the saved one
			$result{'all_max_ident'}{$id} = $result{$db}{$id}{'ident'};
			$result{'all_max_hit'}{$id} = $result{$db}{$id}{'hit'};
			$result{'all_max_title'}{$id} = $result{$db}{$id}{'title'};
		}elsif($result{$db}{$id}{'ident'} == $result{'all_max_ident'}{$id}){
			$result{'all_max_hit'}{$id} .= ";$result{$db}{$id}{'hit'}";
			$result{'all_max_title'}{$id} .= ";$result{$db}{$id}{'title'}";
		}
	}else{
		delete $result{$db}{$id}{'ident'}; #use delete because when no hit for one sequence, $result{$db}{$id}{'ident'} is not initialized
#			$maxIdent = "NA";
#			$hits = "Not found";
	}
}

sub usage(){
	print "Description: This script calls a series of BLAST on the given species databases to decide which species does the protein sequences belong to. A threshold is required from the user.\n";
	print "Usage:perl speciesFinding.pl <protein fasta file> <threshold> <output> [species BLAST database 1] [species BLAST database 2] [...]\n";
	print "If no database is given, the default ".FINAL." will be BLASTed against.\n";
	&getAvailableBLASTdbs();
	&printAvailableBLASTdbs();
}

sub getAvailableBLASTdbs(){
	opendir DIR, "$blastDBdir" or die "Unable to open BLAST db folder <$blastDBdir>\n";
	my @files = readdir DIR;
	my %multiple;
	foreach my $file(@files){
		if ($file =~/\.phr$/){
			my $prefix = $`;
			if($prefix =~/^(.+)\.(\d+)$/){
#				print "db $1 part $2\n";
				push (@{$multiple{$1}},$2);
			}else{
				$availableDBs{$`}=1;
			}
		}
	}
	foreach my $db(keys %multiple){
		$availableDBs{$db} = 1;
#		do not bother to check whether the database has the continuous part file
#		my @arr = @{$multiple{$db}};
#		print "Series: @arr\n\n";
	}
	my $tmp = FINAL;
	unless (exists $availableDBs{$tmp}){
		die "Please make sure that there exists a BLAST db called ".FINAL." \n";
	}
}

sub printAvailableBLASTdbs(){
	print "Available BLAST databases:\n";
	foreach my $db(sort {$a cmp $b} keys %availableDBs){
		print "$db\n";
	}
}
