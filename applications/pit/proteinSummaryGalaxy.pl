#!/usr/bin/perl -w
use strict;
use POSIX;

#developed by Dr Jun Fan@qmul
 
#global constant values
use constant { true => 1, false => 0 };
# 1. Total number of unique fasta entries.
# 2. Total number of amino acids.
# 3. Average length.
# 4. N50 (i.e. length of fasta entry where 50% are longer and 50% are shorter).
# 5. Number of transcripts for which no ORFS are returned
# 6. Anything else you think might be useful.
use constant { NUM_RECORDS => "Total entries", NUM_AA => "Total amino acids", AVG_LENGTH => "Average length", N50 => "N50 value", LONGEST => "Longest length", SHORTEST => "Shortest length"}; 
my @fields = (NUM_RECORDS,NUM_AA,AVG_LENGTH,N50, LONGEST, SHORTEST);

#parameter length check
my $lenARGV = scalar @ARGV;
if($lenARGV<3){
	print "Error: Missing mandatory parameters for input file and display name\n";
	&usage();
	exit 1;
}
if(($lenARGV % 2)==0){
	print "Error: Unrecognized pair of parameter names and values\n";
	&usage();
	exit 2;
}

my $out = $ARGV[-1];
open OUT,">$out";
my @files;
my @display;
my %display;
for(my $i=0;$i<$lenARGV-1;$i+=2){
#	print OUT "$i file $ARGV[$i] display $ARGV[$i+1]\n";
	push (@files,$ARGV[$i]);
	push (@display,$ARGV[$i+1]);
	if(exists $display{$ARGV[$i+1]}){
		print "Duplicate display name $ARGV[$i+1]\n";
		exit 3;
	}
	$display{$ARGV[$i+1]}++;
}

my %data;
for(my $i=0;$i < scalar @files;$i++){
#	&summary($files[$i],$display[$i]);
	&summary($files[$i]);
}

print OUT "Dataset";
foreach my $display(@display){
	print OUT "\t$display";
}
print OUT "\n";

foreach my $field(@fields){
	print OUT "$field";
	#my @row = keys %data;
	my @row = @{$data{$field}};
	foreach my $value(@row){
		print OUT "\t$value";
	}
	print OUT "\n";
}
close OUT;

# open OUT,">$outfile";

# foreach my $pep(sort {$a cmp $b} keys %){
	# print OUT ">$ {$pep}\n$pep\n";
# }
# close OUT;

sub summary(){
# 1. Total number of unique fasta entries.
# 2. Total number of amino acids.
# 3. Average length.
# 4. N50 (i.e. length of fasta entry where 50% are longer and 50% are shorter).
	my $infile = $_[0];
	# my $display = $_[1];
	my %lenDistr;
	my %seq;
	my $count = 0;
	open IN,"$infile";
	#my $header="";
	my $seq="";
	while(my $line=<IN>){
		chomp $line;
		if($line=~/^>/){
			unless(length $seq==0){
				$seq=~s/\s//g;
				unless (exists $seq{$seq}){
					$count++ ;
					my $len = length $seq;
					$lenDistr{$len}++;
				}
				$seq{$seq}++;
				$seq="";
			}
			#$header=substr($line,1);
		}else{
			 $seq .= $line; # add sequence
		}
	}
	$seq=~s/\s//g;
	unless (exists $seq{$seq}){
		$count++ ;
		my $len = length $seq;
		$lenDistr{$len}++;
	}
	$seq{$seq}++;
#	print "count $count\tseq entries ".(scalar keys %seq)."\n";
	my $curr = NUM_RECORDS;
	push (@{$data{$curr}},$count);
	my @lens = sort {$a <=> $b} keys %lenDistr;
#	print "Number of different length: ".(scalar @lens)."\n";
	my $totalLen = 0;
	my $n50Threshold = $count/2;
	my $n50Count = 0;
	my $n50found = 0;
	my $n50Len;
	for (my $i=0;$i<scalar @lens;$i++){
		my $len = $lens[$i];
#	foreach my $len(@lens){
		$totalLen += $len*$lenDistr{$len};
		$n50Count += $lenDistr{$len};
		if($n50found == 0 && $n50Count >= $n50Threshold){
			$n50found = 1;
			$n50Len = $len;
		}
		#$n50Len = $len if ($n50Count <= $n50Threshold);
		#print "current length $len\n";
	}
	my $avgLen = $totalLen/$count;
#	print "Total amino acid: $totalLen\nAverage: $avgLen\nN50 $n50Len\n";
	$curr = NUM_AA;
	push (@{$data{$curr}},$totalLen);
	$curr = AVG_LENGTH;
	push (@{$data{$curr}},$avgLen);
	$curr = N50;	
	push (@{$data{$curr}},$n50Len);
	$curr = LONGEST;
	push (@{$data{$curr}},$lens[-1]);
	$curr = SHORTEST;
	push (@{$data{$curr}},$lens[0]);
}

sub usage(){
	print "Usage: perl proteinSummary.pl <fasta file 1> <display name 1> [fasta-display pair 1]  [fasta-display pair 2] [...]\n";
	print "Each fasta-display pair consists of a fasta file and a display name as the column header in the result file\n";
	print "Note: there should be no space within the displays\n";
	print "Example: perl proteinSummary.pl human_swissprot.fasta human\n";
}
