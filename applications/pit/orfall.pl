#!/usr/bin/perl -w
use strict;
use POSIX;
# the default values for the main ORF is 200 bps, start and stop codons
# Report ALL ORFs that meet the criteria in each frame. If no stop codon reached then yes, use the end of the mRNA as the stop.

# For each ORF reported go to the initiating methionine and look upstream in the other two reading frames for an initiating methionine. 
# If you find one then simply translate it and report it as a possible uORF (so long as the length is at least 6 amino acids - no upper limit). 
# This will report all possible instances where two open reading frames may interfere with each other. This is very broad, be as inclusive as possible
# the default values for the upstream uORFs are length in the range of 7 -60 AAs (21-180 bps) and overlapping with the main ORF
# the uORF might overlap with the main orf but it does not have to 
# it might be entirely upstream so it might be in the same frame

# For every main ORF go to the stop codon and then back up until you hit a methionine in either of the other two reading frames  
# and then translate until you hit a stop (again, at least 6 aa long). 
# The default values for the downstream ORFs is 6-unlimited AAs and overlapping.

#developed by Dr Jun Fan@qmul based on Dr David Matthews@bristol's original idea 
 
#global constant values
my $STOP = "-";
my %translation = (TTT=>"F", TTC=>"F", TCT=>"S", TCC=>"S", TAT=>"Y", TAC=>"Y", TGT=>"C", TGC=>"C", TTA=>"L", TCA=>"S", TAA=>$STOP, TGA=>$STOP, TTG=>"L", TCG=>"S", TAG=>$STOP, TGG=>"W", CTT=>"L", CTC=>"L", CCT=>"P", CCC=>"P", CAT=>"H", CAC=>"H", CGT=>"R", CGC=>"R", CTA=>"L", CTG=>"L", CCA=>"P", CCG=>"P", CAA=>"Q", CAG=>"Q", CGA=>"R", CGG=>"R", ATT=>"I", ATC=>"I", ACT=>"T", ACC=>"T", AAT=>"N", AAC=>"N", AGT=>"S", AGC=>"S", ATA=>"I", ACA=>"T", AAA=>"K", AGA=>"R", ATG=>"M", ACG=>"T", AAG=>"K", AGG=>"R", GTT=>"V", GTC=>"V", GCT=>"A", GCC=>"A", GAT=>"D", GAC=>"D", GGT=>"G", GGC=>"G", GTA=>"V", GTG=>"V", GCA=>"A", GCG=>"A", GAA=>"E", GAG=>"E", GGA=>"G", GGG=>"G");
#my %rev_translation = (GGC=>"A", ACT=>"S", TCA=>"*", ACA=>"C", TCG=>"R", GAT=>"I", GTT=>"N", GCT=>"S", GTA=>"Y", TGT=>"T", CGA=>"S", CGG=>"P", CAG=>"L", TGC=>"A", CAC=>"V", CTT=>"K", AAC=>"V", GTG=>"H", TCT=>"R", GGT=>"T", TGG=>"P", CCA=>"W", GAG=>"L", GCG=>"R", CAA=>"L", TTA=>"*", CTG=>"Q", CGT=>"T", CAT=>"M", TTT=>"K", TAC=>"V", CTA=>"*", AAG=>"L", TCC=>"G", GAC=>"V", GCA=>"C", TGA=>"S", AAT=>"I", ATA=>"Y", ATT=>"N", AGT=>"T", TTG=>"Q", GTC=>"D", ACC=>"G", GGA=>"S", AAA=>"F", CCT=>"R", ACG=>"R", CCG=>"R", ATG=>"H", TAT=>"I", GGG=>"P", CCC=>"G", TAA=>"L", CTC=>"E", TAG=>"L", ATC=>"D", AGA=>"S", GAA=>"F", CGC=>"A", GCC=>"G", AGC=>"A", TTC=>"E", AGG=>"P");
#my %base_pair = (G=>"A", A=>"T", T=>"A", C=>"G");

# the parameters (particularly need to think about wrapping in Galaxy) will be <input file> <output file> [parameter1] [parameter2] [...]
#parameter length check
#testMRNA.fasta mainORFs.fasta -minMain
my $lenARGV = scalar @ARGV;
if($lenARGV<2){
	print "Error: Missing mandatory parameters for input/output files\n";
	&usage();
	exit 1;
}
if(($lenARGV % 2)==1){
	print "Error: Unrecognized pair of parameter names and values\n";
	&usage();
	exit 2;
}

my $infile = $ARGV[0];
my $outfile = $ARGV[1];
#default values
my $minLength = 200;
my $start = "M";
my $stop = $STOP;
#set by the command line parameters
for(my $i=2;$i<$lenARGV;$i+=2){
	my $name = lc($ARGV[$i]);
	if ($name eq "-minmain"){
		$minLength = $ARGV[$i+1];
	}elsif ($name eq "-start"){
		$start = $ARGV[$i+1];
	}elsif ($name eq "-stop"){
		$stop = $ARGV[$i+1];
	}else{
		print "Error: Unexpected parameter name $ARGV[$i]\n";
		&usage();
		exit 3;
	}
}
#print "minimum ORF length: $minLength\nStart codon: $start\nStop codon: $stop\n";
my $minAA = ceil($minLength/3);

open IN,"$infile";
my $header="";
my $seq="";
my %totalORF;
open OUT,">$outfile";
while(my $line=<IN>){
	chomp $line;
	if($line=~/^>/){
		unless(length $seq==0){
			&doORF($header,$seq);
			$seq="";
		}
		$header=substr($line,1);
	}else{
        	 $seq .= $line; # add sequence
	}
}
unless(length $seq==0){
	&doORF($header,$seq);
	$seq="";
}

foreach my $pep(sort {$a cmp $b} keys %totalORF){
	print OUT ">$totalORF{$pep}\n$pep\n";
}
sub doORF(){
	my $header = $_[0];
	$header =~ s/\s.*//;#only keeps the part before the first white space
	my $seq = $_[1];
	$seq=~s/\s+//g;
	my $len = length $seq;
	my %frame;
	#5'->3' + strand
	for(my $offset = 1;$offset<4;$offset++){
		for (my $i=-1+$offset;$i<$len-2;$i+=3){
			my $codon = substr($seq,$i,3);
			$frame{$offset}.= $translation{$codon};
		}
	}
	#3'->5' - strand
	my $reversecomp = reverse $seq;
	$reversecomp =~ tr/ACGT/TGCA/;	
	for(my $offset = 1;$offset<4;$offset++){
		for (my $i=-1+$offset;$i<$len-2;$i+=3){
			my $codon = substr($reversecomp,$i,3);
			$frame{-$offset}.= $translation{$codon};
		}
	}
	my @orfs;
	my %orfs;
	my $orfCount = 0;
	for my $frame(sort {$a<=>$b} keys %frame){
		my $orfStart = $frame; #original dna position
		my $strand = 1;
		if ($frame<0){
			$orfStart = $len + $frame + 1;#because when calculating the frame, it was calculated as -1+$offset, so frame -1 start from the last, frame -2, start from the second to last
			$strand = -1;
		}
		my $aa = $frame{$frame};
		my @segments = split($start,$aa);#
		$orfStart += (length $segments[0])*3*$strand;
		my $orf = $start; #@segments does not have the start codon after splitting
		my $segLen = 3; #should change whenever $orf changes
		for(my $i=1;$i<scalar @segments;$i++){
			my $pos = index($segments[$i],$stop);#locate the stop codon
			$segLen += (length $segments[$i])*3;
			if($pos >-1){ #if found, judge the length
				my $orfLen = (length $orf)+$pos;
				if($orfLen >= $minAA){#main orf found
					$orf .= substr($segments[$i],0,$pos);
					$orfCount++;
					$orfs{$orfCount}{"frame"}=$frame;
					$orfs{$orfCount}{"orf"}=$orf;
					$orfs{$orfCount}{"start"}=$orfStart;
					my $orfStop = $orfStart + $strand*((length $orf)*3-1);
					$orfs{$orfCount}{"stop"}=$orfStop;
					push (@orfs,$orf);
				}
				$orfStart = $orfStart+$segLen*$strand;
				$orf = $start;
				$segLen = 3;
			}else{#if no stop codon found, extend to next segment
				$orf .= "$segments[$i]$start"; 
				$segLen += 3;
			}
		}
		if ((length $orf)>=$minAA){#if no stop codon found in the last one, treat it as an ORF (if found, the value held in $orf will be only the start codon
			$orf = substr($orf,0,(length $orf)-1);
			$orfCount++;
			$orfs{$orfCount}{"frame"}=$frame;
			$orfs{$orfCount}{"orf"}=$orf;
			$orfs{$orfCount}{"start"}=$orfStart;
			my $orfStop;
			$orfStop = $orfStart+((length $orf)*3-1)*$strand;
			$orfs{$orfCount}{"stop"}=$orfStop;
			push (@orfs,$orf); 
		}
	}

	foreach my $index(sort {$a<=>$b} keys %orfs){
#		print "ORF $index\n";
#		print "Frame: $orfs{$index}{'frame'}\n";
#		print "Sequence: $orfs{$index}{'orf'}\n";
#		print "Start: $orfs{$index}{'start'}\n";
#		print "Stop: $orfs{$index}{'stop'}\n";
#		print OUT ">${header}_ORF${index}_Frame_$orfs{$index}{'frame'}_$orfs{$index}{'start'}-$orfs{$index}{'stop'}\n$orfs{$index}{'orf'}\n";
		if(exists $totalORF{$orfs{$index}{'orf'}}){
			$totalORF{$orfs{$index}{'orf'}} .= ",${header}_ORF${index}_Frame_$orfs{$index}{'frame'}_$orfs{$index}{'start'}-$orfs{$index}{'stop'}";
		}else{
			$totalORF{$orfs{$index}{'orf'}} = "${header}_ORF${index}_Frame_$orfs{$index}{'frame'}_$orfs{$index}{'start'}-$orfs{$index}{'stop'}";
		}
		
	}
}

sub usage(){
	print "Usage: perl ORFall.pl <input file> <output file> [parameter1]  [parameter2] [...]\n";
	print "Each parameter is a pair of name and corresponding value, in the form of <-parameterName> <parameterValue>\n";
	print "The expected parameter names only include:\n";
	print "-minMain: the minimum length of the main ORF, the default value is 200bps\n";
	print "-start: the start codon used to search for ORFs, the default value is M (methionine, corresponding to codon ATG)\n";
	print "-stop: the stop codon used to search for ORFs, the default value is $STOP (corresponding to codons TAA, TAG and TGA)\n";
}