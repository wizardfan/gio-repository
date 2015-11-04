#!/usr/bin/perl
use strict;

my $water = 18.01056;
my %mw = ("A"=>71.03711,"C"=>103.00919,"D"=>115.02694,"E"=>129.04259,"F"=>147.06841,
	  "G"=>57.02146,"H"=>137.05891,"I"=>113.08406,"K"=>128.09496,"L"=>113.08406,
	  "M"=>131.04049,"N"=>114.04293,"P"=>97.05276,"Q"=>128.05858,"R"=>156.10111,
	  "S"=>87.03203,"T"=>101.04768,"V"=>99.06841,"W"=>186.07931,"Y"=>163.06333);
#my %hydro = (
#  'X'        => 0,     # unknown
#   'B'        => -1.2,  # Asparagine or aspartic acid
#   'Z'        => -0.9,  # Glutamine or glutamic acid.
#   'U'	      => 0,     # Selenocysteine
#   'O'        => 0,     # Pyrrolysine
#   'J'        => 8.4,   # leucine or isoleucine
#);
my %retentionCoefficient = ("A" => 0.8, "R" => -1.3, "N" => -1.2, "D" => -0.5, "C" => -0.8, 
			    "G" => -0.9, "E" => 0.0, "Q" => -0.9, "H" => -1.3, "I" => 8.4, 
			    "L" => 9.6, "K" => -1.9, "M" => 5.8, "F" => 10.5, "P" => 0.2, 
			    "S" => -0.8, "T" => 0.4, "W" => 11.0, "Y" => 4.0, "V" => 5.0);
my %retentionCoefficientNterm = ("A" => -1.5, "R" => 8.0, "N" => 5.0, "D" => 9.0, "C" => 4.0, 
				"G" => 5.0, "E" => 7.0, "Q" => 1.0, "H" => 4.0, "I" => -8.0, 
				"L" => -9.0, "K" => 4.6, "M" => -5.5, "F" => -7.0, "P" => 4.0, 
				"S" => 5.0, "T" => 5.0, "W" => -4.0, "Y" => -3.0, "V" => -5.5);
#my %rcnt = (
#   'X'        => 0,     # unknown
#   'B'        => 5.0,   # Asparagine or aspartic acid
#   'Z'        => 1.0,   # Glutamine or glutamic acid
#   'U'	      => 0,     # Selenocysteine
#   'O'        => 0,      # Pyrrolysine
#   'J'        => -8.0,   # leucine or isoleucine
#);

#parameter checking
my $lenArgv = scalar @ARGV;
unless( $lenArgv == 3 ){
	print "Wrong number of parameters\n";
	&usage();
	exit 1;
}

my $in = $ARGV[0];
my $type = $ARGV[1];
my $out = $ARGV[2];

unless ($type eq "fasta" || $type eq "tsv"){
	print "Wrong input file format selection, only can be fasta or tsv\n";
	exit 1;
}

open IN,"$in" or die "Can not find the file $in";
open OUT,">$out" or die "Can not open the output file $out";

if ($type eq "fasta"){
	print OUT "Protein\tPeptide\tMolecular weight\tHydrophobicity\n";
	my $id;
	my $seq="";

	while(my $line=<IN>){
		chomp $line;
		if($line=~/^>/){
			unless(length $seq==0){
				$seq=~s/\s+//g;
				my $mw = &calcMW($seq);
				my $hydro = &calcHydro($seq);
				print OUT "$id\t$seq\t$mw\t$hydro\n";
				$seq="";
			}
			$id=substr($line,1);
		}else{
        		$seq .= $line; # add sequence
		}
	}
	unless(length $seq==0){
		$seq=~s/\s+//g;
		my $mw = &calcMW($seq);
		my $hydro = &calcHydro($seq);
		print OUT "$id\t$seq\t$mw\t$hydro\n";
	}
}else{
	my $pepPosi = 1; #second column, index 1  which is the case in the new layout
	my $header = <IN>;
	chomp $header;
	my ($first) = split("\t",$header);
	$pepPosi = 0 if (lc($first) eq "peptide");#first column, index 0, which is the case in the old layout
	print OUT "$header\tMolecular weight\tHydrophobicity\n";

	while (my $line=<IN>){
		chomp $line;
		my ($first,$second) = split("\t", $line);
		my $pep;
		if ($pepPosi == 1){
			$pep = $second;
		}else{
			$pep = $first;
		}
		my $mw = &calcMW($pep);
		my $hydro = &calcHydro($pep);
		print OUT "$line\t$mw\t$hydro\n";
	}

}

sub calcMW(){
	my $seq = $_[0];
	my $mw=$water;
	my @aa = split("",$seq);
	foreach(@aa){
		$mw+=$mw{$_};
	}
	return $mw;
}

sub calcHydro(){
	my @aa = split("",$_[0]);
        my $sumRc = 0;
        foreach(@aa){
            $sumRc += $retentionCoefficient{$_};
        }
        my $correction;
        my $len = scalar @aa;
        if ($len<10){
        	$correction = 1-0.027*(10-$len);
        }elsif($len>20){
        	$correction = 1-0.014*($len-20);
        }else{
        	$correction = 1;
        }
        my $hydrophobicity = $correction*($sumRc+0.42*$retentionCoefficientNterm{$aa[0]}+
                0.22*$retentionCoefficientNterm{$aa[1]}+
                0.05*$retentionCoefficientNterm{$aa[2]});
        $hydrophobicity = $hydrophobicity - 0.3*($hydrophobicity-38) if ($hydrophobicity>38);
        return $hydrophobicity;
}

sub usage(){
	print "This script is to calculate peptide mass and hydrophobicity\n";
	print "Usage: perl pepMW.pl <input file> <input file format> <output result file>\n";
}
