#!/usr/bin/perl -w
use strict;
#pre-defined parameter sets
#gff:	# 0 3
#sam:	@ 2 3
#vcf:	# 0 1
##test part
#my @arr = ("12","44","5","53");
#@arr = ("chr1","chrY", "chr12","chr2","chrX","chr4","chr12","chrX");
#@arr=("aj","hivba","hiv","bai");
#@arr=("12","X","1","Y");

#@arr = &removeDuplicate(@arr);
#print "@arr\n";
#my @result = sort sorting @arr;
#print "Original: @arr\nSorted: @result\n";
#exit;

#validate the parameters
#length
my $argNum = scalar @ARGV;
unless ($argNum == 4 || $argNum == 5){
	print "Wrong number of arguments\n";
	&usage();
}
#must be numbers for column index
my $chrCol = $ARGV[2];
my $startCol = $ARGV[3];
unless ($chrCol=~/^\d+$/){
	print "Chromosome column must be a number\n";
	&usage();
}
unless ($startCol=~/^\d+$/){
	print "Start coordinate column must be a number\n";
	&usage();
}
#check keep value is either 1 or 0
my $keep = 0;
$keep = $ARGV[4] if ($argNum == 5);
unless ($keep=~/^[0|1]$/){
	print "Unrecognized parameter for keep the duplicate parameter, only 0 or 1 are allowed\n";
	&usage();
}

open IN, "$ARGV[0]" or die "Cannot find the specified file $ARGV[0]";
my $line;
#just print the headers defined as lines start with the comment sign ($ARGV[1])
while ($line = <IN>){
	chomp $line;
	last unless (substr($line,0,1) eq $ARGV[1]);
	print "$line\n";
}
#save content into the hash, the first keys are the values in the chromosome column and the second keys are the values in the start coordinate column
my %hash;
do{
	chomp $line;
	my @elmts = split(/\t/, $line);
	my $chr = $elmts[$chrCol];
	my $start = $elmts[$startCol];
	$start =~s/,//g;
	push (@{$hash{$chr}{$start}},$line);
}while($line=<IN>);
close IN;
#get the sortable part of chromosome string, e.g. X for chrX
#by removing the leading consensus part, e.g. turn chrX to X
#the first step is to work out what the consensus part is
#"*" is a special case which means no match in SAM file
my @chrs = keys %hash;
my $consLen = length $chrs[0];
my $consStr = $chrs[0];
foreach my $one(@chrs){
	next if($one eq "*");
	for (my $i = $consLen;$i > 0;$i--){
		last if(substr($one, 0, $i) eq $consStr);
		$consLen--;
 		$consStr = substr($consStr,0,$consLen);
	}
	last if ($consLen == 0);
}
#print "$consLen\n";
#create the mapping between the original chromosome string (values) and the string removing the consensus part (keys)
my %mapping;
foreach my $one(@chrs){
	if($one eq "*"){
		$mapping{"*"}="*";
		next;
	}
	$mapping{substr($one,$consLen)} = $one;
}
#sort the sortable part, numbers goes before letters
my @sorted = sort sorting keys %mapping;
foreach my $chr(@sorted){
	my $original = $mapping{$chr};
	my %chrSpecific = %{$hash{$original}}; #keys are start coordinates
	foreach my $start(sort {$a<=>$b} keys %chrSpecific){
		my @lines = @{$chrSpecific{$start}};
		@lines = &removeDuplicate(@lines) if ($keep == 0);
		foreach my $line(@lines){
			print "$line\n";
		}
	}
}

sub removeDuplicate(){
	my @data = @_;
	my %done;
	my @result;
	foreach my $curr(@data){
		unless (exists $done{$curr}){
			push (@result, $curr);
			$done{$curr} = 1;
		}
	}
	return @result;
}

sub usage(){
	print "Usage: perl sortChromo.pl <tabular file> <comment sign> <chromosome column> <start coordinate column> [keep the duplicate 0(default) or 1]\n";
	print "The script is design to order the entries in the tabular file, e.g. SAM file, GFF3 file, according to the chromosome position\n";
	print "The difficulty of this is that there is no certain pattern for chromosome, which can be just numbers and letters (e.g. 12, X) or with prefix(e.g. chr1, contig_2341.1).\n";
	print "Please bear in mind that the script is not supposed to sort the mixed type, i.e. chromosomes represented in both numbers and letters and with prefix types\n";
	print "The beginning lines starting with the <comment sign> will be kept untouched\n";
	print "The remaining lines will be ordered by <chromosome column>, then the <start coordinate column>\n";
	print "Sometimes there are identical lines in the file, the optional parameter [keep the duplicate] indicates whether to keep the duplicate[1] or not (0, i.e. delete duplicate)\n";
	exit;
}
#seqid in gff: [a-zA-Z0-9.:^*$@!+_?-|]+
#rname in sam: \*|[!-()+-<>-~][!-~]*

sub sorting(){
	if ($a eq "*"){
		return 0 if($b eq "*");
		return 1;
	}
	return -1 if($b eq "*");
	
	if($a=~/^\d+$/){
		if($b=~/^\d+$/){
			return $a <=> $b;
		}else{
			return -1;
		}
	}else{
		if($b=~/^\d+$/){
			return 1;
		}else{
			return $a cmp $b;
		}
	}
}
