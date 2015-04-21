#!/usr/bin/perl
use strict;

#parameter checking
my $lenArgv = scalar @ARGV;
unless( $lenArgv >1 && $lenArgv<9 ){
	print "Error: Wrong number of parameters\n";
	&usage();
	exit 1;
}
	
if($lenArgv%2==1){
	print "Error: Wrong pair of options\n";
	&usage();
	exit 2;
}

open IN,"$ARGV[0]" or die "Can not find the file $ARGV[0]";
open OUT,">$ARGV[1]" or die "Can not open the output file $ARGV[1]";
my $unique = 1;
my $maxLength = 10000;
my $minLength = 1;

for (my $i=2;$i<$lenArgv;$i+=2){
	if(lc($ARGV[$i]) eq "-unique"){
		if(lc($ARGV[$i+1]) eq "yes"){
			$unique = 1;
		}elsif(lc($ARGV[$i+1]) eq "no"){
			$unique = 0;
		}else{
			print "unrecognized option value for -unique: $ARGV[$i+1]\n";
			&usage();
			exit 4;
		}
	}elsif (lc($ARGV[$i]) eq "-maxlength"){
		$maxLength = $ARGV[$i+1];
	}elsif (lc($ARGV[$i]) eq "-minlength"){
		$minLength = $ARGV[$i+1];
	}else{
		print "Error: Unrecognized option: $ARGV[$i]\n";
		&usage();
		exit 3;
	}
}

if($minLength > $maxLength){
	print "Error: The minimum length is greater than the maximum length\n";
	exit 5;
}
#real business
my %peptides;
my %peptidesCount;
my $id;
my $seq="";
my $countProtein=0;
my $countPep=0;

while(my $line=<IN>){
	chomp $line;
	if($line=~/^>/){
		unless(length $seq==0){
			&digest($id,$seq);
			$countProtein++;
			$seq="";
		}
		$id=substr($line,1);
	}else{
        	$seq .= $line; # add sequence
	}
}
unless(length $seq==0){
	&digest($id,$seq);
	$countProtein++;
}

my @uniquePep = sort {
	if((length $a)<(length $b)) {return -1;}
	elsif((length $a)>(length $b)) {return 1;}
	else {return $a cmp $b}
}  keys %peptides;

my %distri;
foreach my $pep(@uniquePep){
	my $len = length $pep;
	last if ($len > $maxLength);
	next if ($len < $minLength);
	$distri{$len}++;
	next if($peptidesCount{$pep}>1 && $unique==1);
	print OUT ">$peptides{$pep}\n$pep\n";
}
close OUT;
print "Peptides distribution between the limit $minLength-$maxLength:\n";
my @lens = sort {$a<=>$b} keys %distri;
foreach (@lens){
	print "$_\t$distri{$_}\n";
}

sub digest(){
	my ($header,$seq) = @_;
	$header =~ s/\s.*//;#only keeps the part before the first white space
	$seq=~s/\s+//g;
	my @frags = split /(?<=[KR])(?=[^P])/,$seq;
	$countPep += scalar @frags;
	for(my $i=1;$i<=scalar @frags;$i++){
		my $pep = $frags[$i-1];
		if(exists $peptides{$pep}){ #not unique
			$peptidesCount{$pep}++;
			$peptides{$pep} .= ";$header-pep$i";
		}else{
			$peptidesCount{$pep} = 1;
			$peptides{$pep} = "$header-pep$i";
		}
	}
}

sub usage(){
	print "This script is to theoritically digest proteins into tryptic peptides\n";
	print "Usage: perl digest.pl <protein fasta file> <output peptide file> [options]\n";
	print "Options include:\n";
	print "-unique [yes|no]  whether only output proteotypic peptides. The default value is no\n";
	print "-maxLength integer to limit the maximum length of peptide, default is 10000 which means include every peptide.\n";
	print "-minLength integer to limit the minimum length of peptide, default is 1 which means include every peptide.\n";
	print "Example 1: perl digest.pl uniprot_sprot_human.fasta\t\t this will digest the human swissprot data and output all sequences\n";
	print "Example 2: perl digest.pl uniprot_sprot_human.fasta -unique yes -minLength 4 -maxLength 24\t\t this will only output proteotypic peptides having AA between 4 and 24 inclusive, which is more likely to be observed on a MS machine\n";
}