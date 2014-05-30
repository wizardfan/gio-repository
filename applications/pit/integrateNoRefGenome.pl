#!/usr/bin/perl -w
use strict;
use POSIX;

my $argLen = scalar @ARGV;
&usage() unless($argLen==3);

# the fasta file used in the search engine
my $fastaFile = $ARGV[0];
# the result file from extract peptides which has the fixed header order, 1 peptide 2 protein 3 reverse 4 contaminant 5 score 6 quant 7 ... optional
my $peptidesFile = $ARGV[1];
# the output file name
my $outFile = $ARGV[2];

my %seqs = %{&readFasta($fastaFile)};
my %proteins;
# the header in the format-pre-defined file in the order of
# 0 peptide, 1 proteins, 2 Reverse, 3 Contamination, 4 Confidence value (could be score, p-value etc), 5 quantitation value, 6+ optional
open IN, "$peptidesFile" or die "Can not find the specified identification file $peptidesFile";
#the header line
my $headerLine = <IN>;
while (my $line = <IN>){
	chomp $line;
	my @elmts = split(/\t/, $line);
	#next if ($elmts[2] eq '+' || $elmts[3] eq '+');#2 Reverse 3 contaminant, if true that record should not be used
	my $peptide = $elmts[0];
	my $protein_name = $elmts[1];#Protein, e.g. >96407_5 [2245 - 587] (REVERSE SENSE);>96409_5 [2116 - 566] (REVERSE SENSE);>96408_5 [2043 - 613] (REVERSE SENSE),96410_5 [2172 - 742] (REVERSE SENSE)
	next if (length $protein_name == 0);#decoy hit in MS-GF+
	$protein_name =~ s/,/>/g; #replace , with >
	my @protein_entries = split(/>/, $protein_name); #some elements may have ; at the end which does not matter due to the RE
	for (my $i=1;$i<scalar @protein_entries;$i++){#start from index 1 as the first element is always empty due to the fasta header format
		my $current = $protein_entries[$i];
		$proteins{$current}{$peptide}++;
	}
}

my %result;
my $printed = 1;
foreach my $protein (keys %proteins){
	my $seq;
	if(exists $seqs{$protein}){
		$seq = $seqs{$protein};
	}else{
		if($printed == 1){
			$printed = 0;
			print "The known reasons for the unfound protein include: it could be decoy sequence, the original header has been altered due to its length or characters\n";
		}
		print "Protein $protein not in the sequences\n";
		next;
	}
	if(exists $result{$seq}){
		$result{$seq} .= ",$protein";
	}else{
		$result{$seq} = "$protein";
	}
}

open OUT, ">$outFile";
foreach my $seq(sort {$a cmp $b} keys %result){
	print OUT ">$result{$seq}\n$seq\n";
}
close(OUT);

sub readFasta(){
	open IN, "$_[0]" or die "Can not find the specified fasta file $_[0]";
	my $header;
	my $seq="";
	my %seqs;
	while(my $line=<IN>){
		chomp $line;
		if($line=~/^>/){
			unless(length $seq==0){
				$header =~ s/,/>/g; #replace , with >
				my @tmp = split(/>/, $header); 
				for (my $i=0;$i<scalar @tmp;$i++){#start from index 1 as the first element is always empty due to the fasta header format
					#in the mzIdentML file only the first part may be used as accession
					my $id = $tmp[$i];
					$seqs{$id}=$seq;
					my ($first) = split(" ",$id);
					$seqs{$first} = $seq;
				}
				$seq="";
			}
			$header=substr($line,1);
		}else{
			$seq .= $line; # add sequence
		}
	}
	unless(length $seq==0){
		$header =~ s/,/>/g; #replace , with >
		my @tmp = split(/>/, $header); 
		for (my $i=0;$i<scalar @tmp;$i++){#start from index 1 as the first element is always empty due to the fasta header format
			my $id = $tmp[$i];
			$seqs{$id}=$seq;
			my ($first) = split(" ",$id);
			$seqs{$first} = $seq;
		}
	}
	close IN;
	return \%seqs;
}

sub usage(){
	print "Usage: perl integrateNoRefGenomepit.pl <fasta file> <identification file in the tsv format> <output file>\n\n";
	print "The fasta file is the file used in the MS/MS search, which is supposed to contain sequences for all identified proteins\n";
	print "The identification file can be converted from mzIdentML or the sub-file extracted from a MaxQuant result file\n";
	exit;
}
