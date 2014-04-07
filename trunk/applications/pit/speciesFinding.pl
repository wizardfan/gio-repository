#!/usr/bin/perl -w
use strict;
use POSIX;
use constant {BLASTDB => "BLASTDB", MIDDLE => "blastMiddleFiles", SPROT => "swissprot"};
my $blastDBdir = "";
my $deleteCmd = "";
my $cmdLocation = "";
my $coreSetting = "";

my $argLen = scalar @ARGV;
if($argLen < 3){
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
	$cmdLocation = "$abc/gio_applications/pit/";
	close IN;
	
	open IN, "$abc/gio_applications/coreSetting.conf";
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

my @dbs;
#print "Fasta file: $file\n";
#print "Threshold: $threshold\n";
$"="\n";
#check whether the selected BLAST database is available on the server to use
foreach my $db(@dbsIn){
	unless(exists $availableDBs{$db}){
		print "The given database $db is not available on this server\n";
		&printAvailableBLASTdbs();
		exit 4;
	}
	push (@dbs, $db) unless ($db eq SPROT);
}
#push (@dbs, SPROT);
print "BLAST databases:\n@dbs\n";

#start real business here
#1.	For each sequence in the fasta file, generate a temp fasta file only containing one sequence with an incremental sequence id
#2.	For each database in the list excluding  the all-species one
#	a.	BLAST all one-sequence fasta files
#	b.	Get the top hit(s) and the highest identity percentage. 
#		i.	If the score is no less than the threshold, 1) record the identity percentage and the hit protein 2) remove from the list for all-species BLAST. If more than one hit sharing the same highest identity percentage, keep all of them, separate by “,”
#		ii.	If the score is below the threshold, record NA for both protein hit and identity percentage
#3.	Output the result
#	a.	The header is sequence id, protein sequence, species 1 hit proteins, species 1 hit identity percentage, …, all-species hit protein, all-species hit identity percentage, all-species search needed
#	b.	For those with at least one significant hit from the selected species BLASTs, output the corresponding data before the column of all-species hit protein
#	c.	Assign the value of No to column all-species search needed
#	d.	Get the highest identity percentage from all available species BLAST search and assign as the value for column of all-species hit identity percentage with the corresponding hit protein
#4.	For each remaining sequence in the list of all-species BLAST, do BLAST against the all-species swissprot database, record the top hit(s) and the score to be assigned to all-species hit and identity percentage, assign Yes to column All-species search needed, NA to all species search column.

#open OUT, ">species_finding_result_$file.tsv";
open OUT, ">$output";
print OUT "Serial\tProtein\tSequence";
foreach my $db(@dbs){
	print OUT "\t$db hit\t$db identity";
}
print OUT "\tAll species hit\tAll sepcies identity\tHit titles\tAll species search needed\n";
my $proteinCount = 0;#protein serial number
open IN, "$file";
my $header = "";
my $seq = "";
while (my $line = <IN>){
	chomp $line;
	if ($line=~/^>/){
		unless (length $seq == 0){
			$proteinCount++;
			$seq=~s/\s+//g;
			&doBLAST($proteinCount,$header,$seq);
			$seq = "";
		}
		$header=substr($line,1);
	}else{
       	$seq .= $line; # add sequence
	}
}
$proteinCount++;
$seq=~s/\s+//g;
&doBLAST($proteinCount,$header,$seq);

sub doBLAST(){
	my ($proteinCount,$header,$seq) = @_;
#step 1 generate the individual fasta file
	my $fastaFile = "seq_$proteinCount.fasta";
	open FASTA,">$fastaFile";
#	print FASTA ">$header\n";
	print FASTA "$seq\n";
	close FASTA;

	print OUT "$proteinCount\t$header\t$seq";
	my $foundSpecies = 0;
	my $allMaxIdent = -1;
	my $allMaxHits;
	my $allMaxTitles;
#do the actual BLAST
#2.	For each database in the list excluding  the all-species one
	foreach my $db(@dbs){
#	a.	BLAST all one-sequence fasta files
		my $blastFile = "seq_${proteinCount}_blast_result_$db.tsv";
#		system ("blastp -db $db -query $fastaFile -outfmt \"6 sacc stitle qlen qstart qend slen sstart send evalue score pident\" -out $blastFile");
		system ("${cmdLocation}blastp -db $db -query $fastaFile $coreSetting -outfmt \"6 sacc stitle pident\" -out $blastFile");
#	b.	Get the top hit(s) and the highest identity percentage. 
#		i.	If the score is no less than the threshold, 1) record the identity percentage and the hit protein 2) remove from the list for all-species BLAST. If more than one hit sharing the same highest identity percentage, keep all of them, separate by “;”
#		ii.	If the score is below the threshold, record NA for both protein hit and identity percentage
		#get the data
		open RESULT, "$blastFile";
		my $maxIdent = -1; #no identity will be below 0, which indicates no identity saved
		my $hits = "";
		my $titles = "";
		while(my $line=<RESULT>){
			chomp $line;
			my @elmts = split("\t",$line);
			my $ident = $elmts[-1];
			if($maxIdent==-1){ # first line
				$maxIdent = $ident;
				$hits = $elmts[0];
				$titles = $elmts[1];
			}elsif ($maxIdent == $ident){
				$hits .= ";$elmts[0]";
				$titles .= ";$elmts[1]";
			}else{
				last;
			}
		}
		close RESULT;
		#do the judgement
		if ($maxIdent >= $threshold){
			$foundSpecies = 1;
			if ($maxIdent > $allMaxIdent){
				$allMaxIdent = $maxIdent;
				$allMaxHits = $hits;
				$allMaxTitles = $titles;
			}elsif($maxIdent == $allMaxIdent){
				$allMaxHits .= ";$hits";
				$allMaxTitles .= ";$titles";
			}
		}else{
			$maxIdent = "NA";
			$hits = "Not found";
		}
		print OUT "\t$hits\t$maxIdent";
		my $clear = "$deleteCmd $blastFile";
		system($clear);
	}
	if($foundSpecies > 0){
		print OUT "\t$allMaxHits\t$allMaxIdent\t$allMaxTitles\tNo\n";
	}else{
		my $blastFile = "seq_${proteinCount}_blast_result_swissprot.tsv";
#		my $cmd = "blastp -db ".SPROT." -query $fastaFile $coreSetting -outfmt \"6 sacc qlen qstart qend slen sstart send evalue score pident\" -out $blastFile";
		my $cmd = "${cmdLocation}blastp -db ".SPROT." -query $fastaFile -outfmt \"6 sacc stitle pident\" -out $blastFile";
		system ($cmd);
		open RESULT, "$blastFile";
		my $maxIdent = -1; 
		my $hits = "";
		my $titles = "";
		while(my $line=<RESULT>){
			chomp $line;
			my @elmts = split("\t",$line);
			my $ident = $elmts[-1];
			if($maxIdent==-1){ # first line
				$maxIdent = $ident;
				$hits = $elmts[0];
				$titles = $elmts[1];
			}elsif ($maxIdent == $ident){
				$hits .= ";$elmts[0]";
				$titles = ";$elmts[1]";
			}else{
				last;
			}
		}
		close RESULT;
		if($maxIdent == -1){
			$maxIdent = "NA";
			$hits = "Not found";
			$titles = "Not found";
		}
		print OUT "\t$hits\t$maxIdent\t$titles\tYes\n";
		my $clear = "$deleteCmd $blastFile";
		system($clear);
	}
	my $clear = "$deleteCmd $fastaFile";
	system($clear);
}

#blastp -db $db -queue $fasta -outfmt \"6 sacc qlen qstart qend slen sstart send evalue score pident" -out $out.tsv
sub usage(){
	print "Description: This script calls a series of BLAST on the given species databases to decide which species does the protein sequences belong to. A threshold is required from the user.\n";
	print "Usage:perl speciesFinding.pl <protein fasta file> <threshold> <output> [species BLAST database 1] [species BLAST database 2] [...]\n";
	print "If no database is given, the default swissprot will be BLASTed against.\n";
	&printAvailableBLASTdbs();
}

sub getAvailableBLASTdbs(){
	opendir DIR, "$blastDBdir" or die "Unable to open BLAST db folder $blastDBdir\n";
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
	my $tmp = SPROT;
	unless (exists $availableDBs{$tmp}){
		die "Please make sure that there exists a BLAST db called ".SPROT." \n";
	}
}

sub printAvailableBLASTdbs(){
	print "Available BLAST databases:\n";
	foreach my $db(sort {$a cmp $b} keys %availableDBs){
		print "$db\n";
	}
}
