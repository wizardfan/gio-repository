#!/usr/bin/perl -w
use strict;
use POSIX;
# the default values for the main ORF is 200 bps, start and stop codons
# Report ALL ORFs that meet the criteria in each frame. If no stop codon reached then yes, use the end of the mRNA as the stop.

# the default values for the upstream uORFs are length in the range of 7 -60 AAs (21-180 bps)
# the uORF might overlap with the main orf but it does not have to 
# it might be entirely upstream so it might be in the same frame

# For every main ORF go to the stop codon and then back up until you hit a methionine in either of the other two reading frames  
# and then translate until you hit a stop (again, at least 6 aa long). 
# The default values for the downstream ORFs is 6-unlimited AAs and overlapping.

#developed by Dr Jun Fan@qmul based on Dr David Matthews@bristol's original idea 
 
#global constant values
use constant { true => 1, false => 0 };

my $STOP = "-";
my %translation = (TTT=>"F", TTC=>"F", TCT=>"S", TCC=>"S", TAT=>"Y", TAC=>"Y", TGT=>"C", TGC=>"C", TTA=>"L", TCA=>"S", TAA=>$STOP, TGA=>$STOP, TTG=>"L", TCG=>"S", TAG=>$STOP, TGG=>"W", CTT=>"L", CTC=>"L", CCT=>"P", CCC=>"P", CAT=>"H", CAC=>"H", CGT=>"R", CGC=>"R", CTA=>"L", CTG=>"L", CCA=>"P", CCG=>"P", CAA=>"Q", CAG=>"Q", CGA=>"R", CGG=>"R", ATT=>"I", ATC=>"I", ACT=>"T", ACC=>"T", AAT=>"N", AAC=>"N", AGT=>"S", AGC=>"S", ATA=>"I", ACA=>"T", AAA=>"K", AGA=>"R", ATG=>"M", ACG=>"T", AAG=>"K", AGG=>"R", GTT=>"V", GTC=>"V", GCT=>"A", GCC=>"A", GAT=>"D", GAC=>"D", GGT=>"G", GGC=>"G", GTA=>"V", GTG=>"V", GCA=>"A", GCG=>"A", GAA=>"E", GAG=>"E", GGA=>"G", GGG=>"G");

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

my $infile = $ARGV[0];#the DNA/RNA sequence
my $outfile = $ARGV[1];#the main ORF result file
#default values
#for main ORF
my $minLength = 200;
my $start = "M";
my $stop = $STOP;
#for 5' uORF
my $need5uorf = false;
my $out5uorf = "";
my $max5 = 180;
my $min5 = 21;
my $distance5 = 300;
#for 3' uORF
my $need3uorf = false;
my $out3uorf = "";
my $min3 = 18;

#set by the command line parameters
for(my $i=2;$i<$lenARGV;$i+=2){
	my $name = lc($ARGV[$i]);
	if ($name eq "-minmain"){
		$minLength = $ARGV[$i+1];
	}elsif ($name eq "-start"){
		$start = $ARGV[$i+1];
	}elsif ($name eq "-stop"){
		$stop = $ARGV[$i+1];
	}elsif ($name eq "-uorf5output"){
		$need5uorf = true;
		$out5uorf = $ARGV[$i+1];
	}elsif ($name eq "-max5"){
		$max5 = $ARGV[$i+1];
	}elsif ($name eq "-min5"){
		$min5 = $ARGV[$i+1];
	}elsif ($name eq "-distance5"){
		$distance5 = $ARGV[$i+1];
	}elsif ($name eq "-uorf3output"){
		$need3uorf = true;
		$out3uorf = $ARGV[$i+1];
	}elsif ($name eq "-min3"){
		$min3 = $ARGV[$i+1];
	}else{
		print "Error: Unexpected parameter name $ARGV[$i]\n";
		&usage();
		exit 3;
	}
}
#print "minimum ORF length: $minLength\nStart codon: $start\nStop codon: $stop\n";
my $minAA = ceil($minLength/3);
my $min5AA = ceil($min5/3);
my $max5AA = floor($max5/3);
my $min3AA = ceil($min5/3);

open IN,"$infile";
my $header="";
my $seq="";
my $totalCount = 0;
my %totalORF;
my %total5uorf;
my %total3uorf;
my @noORFtranscripts;
open OUT,">$outfile";
while(my $line=<IN>){
	chomp $line;
	if($line=~/^>/){
		unless(length $seq==0){
			&doORF($header,$seq);
			$totalCount++;
			$seq="";
		}
		$header=substr($line,1);
	}else{
        	$seq .= $line; # add sequence
	}
}
unless(length $seq==0){
	&doORF($header,$seq);
	$totalCount++;
	$seq="";
}

foreach my $pep(sort {$a cmp $b} keys %totalORF){
	print OUT ">$totalORF{$pep}\n$pep\n";
}
close OUT;

print "Total number of transcripts without ORFs: ".(scalar @noORFtranscripts)." within total $totalCount transcipts\n";
foreach my $transcript(@noORFtranscripts){
	print "$transcript\n";
}

if($need5uorf){
	open OUT,">$out5uorf";
	foreach my $rna(sort {$a cmp $b} keys %total5uorf){
		print OUT ">$total5uorf{$rna}\n$rna\n";
	}
	close OUT;
}

if($need3uorf){
	open OUT,">$out3uorf";
	foreach my $rna(sort {$a cmp $b} keys %total3uorf){
		print OUT ">$total3uorf{$rna}\n$rna\n";
	}
	close OUT;
}

sub translate(){
	my $dna = $_[0];
	my $len = length $dna;
	my $peptide = "";
	for (my $i=0;$i<$len-2;$i+=3){
		my $codon = substr($dna,$i,3);
		if(exists $translation{$codon}){
			$peptide .= $translation{$codon};
		}else{
			$peptide .= "X";
		}
	}
	return $peptide;
}

sub doORF(){
	my $header = $_[0];
	$header =~ s/\s.*//;#only keeps the part before the first white space
	my $seq = uc($_[1]);
	$seq=~s/\s+//g;
	my $len = length $seq;
	my %frame;
	#5'->3' + strand
	for(my $offset = 1;$offset<4;$offset++){
		for (my $i=-1+$offset;$i<$len-2;$i+=3){
			my $codon = substr($seq,$i,3);
			my $aa;
			if(exists $translation{$codon}){
				$aa = $translation{$codon};
			}else{
				$aa = "X";
			}
			$frame{$offset}.= $aa;
		}
	}
	#3'->5' - strand
	my $reversecomp = reverse $seq;
	$reversecomp =~ tr/ACGT/TGCA/;	
	for(my $offset = 1;$offset<4;$offset++){
		for (my $i=-1+$offset;$i<$len-2;$i+=3){
			my $codon = substr($reversecomp,$i,3);
			my $aa;
			if(exists $translation{$codon}){
				$aa = $translation{$codon};
			}else{
				$aa = "X";
			}
			$frame{-$offset}.= $aa;
		}
	}
	my @orfs;
	my %orfs;
	my $orfCount = 0;
	my $orfNegaMaxIndex = 0;#as frame is checked in the order of -3,-2,-1,1,2,3
	my %uorf5;
	my $u5count = 0;
	my $u5orfNegaMaxIndex = 0;
	my %uorf3;
	my $u3count = 0;
	my $u3orfNegaMaxIndex = 0;

	for my $frame(sort {$a<=>$b} keys %frame){
		my $currStopPosi = $frame - 1; #the end position for the current stop codon
		my $strand = 1;
		if ($frame<0){
			$currStopPosi = $len + $frame + 2;#because when calculating the frame, it was calculated as -1+$offset, so frame -1 start from the last, frame -2, start from the second to last
			$strand = -1;
		}
		my $aa = $frame{$frame};
		my @segments = split($stop,$aa);#
		for(my $i=0;$i<scalar @segments;$i++){
			$currStopPosi += ((length $segments[$i])+1)*3*$strand;
			my $pos = index($segments[$i],$start);#locate the first start codon, which should be the longest ORF for the current stop codon
			if($pos >-1){ #if found, the current segment has both start and stop codon, could be an ORF, judge the length
				my $orfLen = (length $segments[$i])-$pos;#because $pos is the actual value - 1
				if($orfLen >= $minAA){#main orf found
					my $orf = substr($segments[$i],$pos);
					$orfCount++;
					$orfNegaMaxIndex = $orfCount if ($frame < 0); 
					$orfs{$orfCount}{"frame"}=$frame;
					$orfs{$orfCount}{"orf"}=$orf;
					my $orfStart = $currStopPosi - $strand*((length $orf)*3+3-1);
					$orfs{$orfCount}{"start"}=$orfStart;
					$orfs{$orfCount}{"stop"}=$currStopPosi-3*$strand;#the stop codon is not accounted in the orf
					push (@orfs,$orf);
				}

				if($need5uorf && $orfLen >= $min5AA && $orfLen <= $max5AA){
					$u5count++;
					$u5orfNegaMaxIndex = $u5count if ($frame < 0);
					$uorf5{$u5count}{"frame"}=$frame;
					my $uorfStart = $currStopPosi - $strand*(((length $segments[$i])-$pos)*3+3-1);
					$uorf5{$u5count}{"start"}=$uorfStart;
					$uorf5{$u5count}{"stop"}=$currStopPosi;#as uorf focus on dna/rna, better to keep the actual stop codon
					if($frame>0){
#						$uorf5{$u5count}{"orf"}=substr($seq,$uorfStart-1, ((length $segments[$i])-$pos)*3+3);
						my $coding = substr($seq,$uorfStart-1, ((length $segments[$i])-$pos)*3);
						my $pep = &translate($coding);
						$uorf5{$u5count}{"orf"}=$pep;
					}else{
#						$uorf5{$u5count}{"orf"}=substr($reversecomp,$len-$uorfStart,((length $segments[$i])-$pos)*3+3);
						$uorf5{$u5count}{"orf"}=&translate(substr($reversecomp,$len-$uorfStart,((length $segments[$i])-$pos)*3));
					}
				}
				if($need3uorf && $orfLen >= $min3AA){
					$u3count++;
					$u3orfNegaMaxIndex = $u3count if ($frame < 0);
					$uorf3{$u3count}{"frame"}=$frame;
					my $uorfStart = $currStopPosi - $strand*(((length $segments[$i])-$pos)*3+3-1);
					$uorf3{$u3count}{"start"}=$uorfStart;
					$uorf3{$u3count}{"stop"}=$currStopPosi;#as uorf focus on dna/rna, better to keep the actual stop codon
					if($frame>0){
#						$uorf3{$u3count}{"orf"}=substr($seq,$uorfStart-1, ((length $segments[$i])-$pos)*3+3);
						$uorf3{$u3count}{"orf"}=&translate(substr($seq,$uorfStart-1, ((length $segments[$i])-$pos)*3));
					}else{
#						$uorf3{$u3count}{"orf"}=substr($reversecomp,$len-$uorfStart,((length $segments[$i])-$pos)*3+3);
						$uorf3{$u3count}{"orf"}=&translate(substr($reversecomp,$len-$uorfStart,((length $segments[$i])-$pos)*3));
					}
				}
			}
#			#5'uorf for one stop codon multiple start codons need to be detected separately
#			my $remaining = $segments[$i];
#			while ($pos > -1){
#				$remaining = substr($remaining, $pos);
#			}
		}
	}
#	foreach my $index(sort {$a<=>$b} keys %uorf5){
#		print "uORFs $index\n";
#		print "Frame: $uorf5{$index}{'frame'}\n";
#		print "Sequence: $uorf5{$index}{'orf'} length: ".(length $uorf5{$index}{'orf'})."\n";
#		print "Start: $uorf5{$index}{'start'}\n";
#		print "Stop: $uorf5{$index}{'stop'}\n";
#	}

#	foreach my $index(sort {$a<=>$b} keys %uorf5){
#		for(my $i=1;$i<=$orfCount;$i++){
#			my $strand = 1;
#			$strand = -1 if ($uorf5{$index}{'frame'}<0);
#			next if (($orfs{$i}{'frame'}*$uorf5{$index}{'frame'})<0);
#			next unless (($orfs{$i}{'start'}-$uorf5{$index}{'start'})*$strand>0);#uorf start must be less than orf start
#			next unless (($orfs{$i}{'start'}-$uorf5{$index}{'stop'})*$strand<$distance5);#uorf stop must be within distance of orf start
#			print "could be uorf for ORF${i}_$orfs{$i}{'frame'}_$orfs{$i}{'start'}_$orfs{$i}{'stop'}\n";
#		}
#		print "\n";
#	}
	if($orfCount==0){
		push (@noORFtranscripts, $header);
		return;
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

		if($need5uorf){
			my $startIndex = 1;
			my $endIndex = $u5orfNegaMaxIndex;
			my $strand = -1;
			if($orfs{$index}{'frame'}>0){
				$startIndex = $u5orfNegaMaxIndex + 1;
				$endIndex = $u5count;
				$strand = 1;
			}

			for (my $i=$startIndex;$i<=$endIndex;$i++){
				next unless (($orfs{$index}{'start'}-$uorf5{$i}{'start'})*$strand>0);#uorf start must be less than orf start
				next unless (($orfs{$index}{'start'}-$uorf5{$i}{'stop'})*$strand<$distance5);#uorf stop must be within distance of orf start
				my $u5orfHeader = "${header}_u5orf${i}_($uorf5{$i}{'frame'}_$uorf5{$i}{'start'}_$uorf5{$i}{'stop'})_for_ORF${index}_($orfs{$index}{'frame'}_$orfs{$index}{'start'}_$orfs{$index}{'stop'})";
#				print ">$u5orfHeader\n$uorf5{$i}{'orf'}\n";
				if(exists $total5uorf{$uorf5{$i}{'orf'}}){
					$total5uorf{$uorf5{$i}{'orf'}} .= ",$u5orfHeader";
				}else{
					$total5uorf{$uorf5{$i}{'orf'}} = "$u5orfHeader";
				}
			}
		}

		if($need3uorf){
			my $startIndex = 1;
			my $endIndex = $u3orfNegaMaxIndex;
			my $strand = -1;
			if($orfs{$index}{'frame'}>0){
				$startIndex = $u3orfNegaMaxIndex + 1;
				$endIndex = $u3count;
				$strand = 1;
			}

			for (my $i=$startIndex;$i<=$endIndex;$i++){
				next unless (($orfs{$index}{'frame'}*$uorf3{$i}{'frame'})>0 && ($orfs{$index}{'frame'}!=$uorf3{$i}{'frame'}));#must be the same direction (
				next unless (($orfs{$index}{'stop'}-$uorf3{$i}{'stop'})*$strand<0);
				next unless (($orfs{$index}{'start'}-$uorf3{$i}{'start'})*$strand<0);
				next unless (($orfs{$index}{'stop'}-$uorf3{$i}{'start'})*$strand>0);
				my $u3orfHeader = "${header}_u3orf${i}_($uorf3{$i}{'frame'}_$uorf3{$i}{'start'}_$uorf3{$i}{'stop'})_for_ORF${index}_($orfs{$index}{'frame'}_$orfs{$index}{'start'}_$orfs{$index}{'stop'})";
#				print "$u3orfHeader\n";
				if(exists $total3uorf{$uorf3{$i}{'orf'}}){
					$total3uorf{$uorf3{$i}{'orf'}} .= ",$u3orfHeader";
				}else{
					$total3uorf{$uorf3{$i}{'orf'}} = "$u3orfHeader";
				}
			}
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
	print "-uorf5output: the file name of the list of 5' uORFs, this also indicates that 5 uORFs is required\n";
	print "-max5: the maximum length of 5' uORFs, only works when -uorf5output is set\n";
	print "-min5: the minimum length of 5' uORFs, only works when -uorf5output is set\n";
	print "-distance5: the maximum distance between the end position of 5' uORF and the start position of its corresponding main ORF, only works when -uorf5output is set. When this value is set to 0, means that uORF must overlap with the main ORF\n";
	print "-uorf3output: the file name of the list of 3' uORFs, this also indicates that 3 uORFs is required\n";
	print "-min3: the minimum length of 3' uORFs, only works when -uorf3output is set\n";
}