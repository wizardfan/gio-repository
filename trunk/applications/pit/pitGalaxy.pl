#!/usr/bin/perl -w
use strict;
use POSIX;

#my $argLen = scalar @ARGV;
#&usage() unless($argLen==4);

# the sam file
#my $samFile = "human.sam";
my $samFile = $ARGV[0];
# the result file from extractPeptides.txt which has the fixed header order, 1 peptide 2 protein 3 reverse 4 contaminant 5 score 6 m/l 7 h/l 8 h/m
#my $peptidesFile = "peptidesNew-extract.txt";
my $peptidesFile = $ARGV[1];
#quotemeta function maybe useful here http://perldoc.perl.org/functions/quotemeta.html
# my $argv = "^(comp\\d+_c\\d+_seq\\d+)";
#$argv="^(\\d+)_(\\d+)\\s";
my $pattern= $ARGV[2];
#the quantitation can be of any value
my $max_fold_change = $ARGV[3];
&usage() unless ($max_fold_change=~/^\d+$/);
#my $suffixLocation = rindex ($samFile,".");
#my $prefix;
#if($suffixLocation>-1){
#	$prefix = substr($samFile,0,$suffixLocation);
#}else{
#	$prefix = $samFile;
#}
my $gffFile = $ARGV[4];
my $samOutFile = $ARGV[5];
my $fastaFile = $ARGV[6];

#add sam definition comment here
#sam specification http://samtools.sourceforge.net/SAMv1.pdf
#tab-delimited text
#optional header, must be prior to the alignment, start with @ and two-letter record type code
#1-based coordinate system, closed interval, e.g. 3rd and 7th is [3,7]. The SAM and GFF are using 1-based system
#alignment 11 mandatory columns always appear in the same order
#1. QNAME String [!-?A-~]{1,255}
#3. RNAME String \*|[!-()+-<>-~][!-~]* Reference sequence NAME
#6. CIGAR String \*|([0-9]+[MIDNSHPX=])+
#10. SEQ String  \*|[A-Za-z=.]+
#All optional Fields follow the TAG:TYPE:VALUE format, TAG containing lowercase letters are reserved for end users, TYPE Z: Printable string including space
my $STOP = "-";
my %translation = (TTT=>"F", TTC=>"F", TCT=>"S", TCC=>"S", TAT=>"Y", TAC=>"Y", TGT=>"C", TGC=>"C", TTA=>"L", TCA=>"S", TAA=>$STOP, TGA=>$STOP, TTG=>"L", TCG=>"S", TAG=>$STOP, TGG=>"W", CTT=>"L", CTC=>"L", CCT=>"P", CCC=>"P", CAT=>"H", CAC=>"H", CGT=>"R", CGC=>"R", CTA=>"L", CTG=>"L", CCA=>"P", CCG=>"P", CAA=>"Q", CAG=>"Q", CGA=>"R", CGG=>"R", ATT=>"I", ATC=>"I", ACT=>"T", ACC=>"T", AAT=>"N", AAC=>"N", AGT=>"S", AGC=>"S", ATA=>"I", ACA=>"T", AAA=>"K", AGA=>"R", ATG=>"M", ACG=>"T", AAG=>"K", AGG=>"R", GTT=>"V", GTC=>"V", GCT=>"A", GCC=>"A", GAT=>"D", GAC=>"D", GGT=>"G", GGC=>"G", GTA=>"V", GTG=>"V", GCA=>"A", GCG=>"A", GAA=>"E", GAG=>"E", GGA=>"G", GGG=>"G");
my $optional_tag = "pt:Z:The peptides are "; #the optional tag 
my %sam; #the keys are ids and the values are sam records
my @samHeader; #store the headers in the sam file which starts with @
my @samorder; #the arrays keeping the original order of records in the original sam file which normally is ordered
my %totalORFs;
 
#read in the sam file
&readSam("$samFile");

my $maxConfidence = 0; #the maximum value of the confidence, for normalization purpose
my $confidenceIsPvalue = 1; # the flag indicating whether the confidence is represented by score (normally > 10 flag = 0) or p-values (significant must be < 0.001 flag = 1)

# the header in the format-pre-defined file in the order of
# 0 peptide, 1 proteins, 2 Reverse, 3 Contamination, 4 Confidence value (could be score, p-value etc), 5 quantitation value, 6+ optional
open IN, "$peptidesFile" or die "Can not find the specified identification file $peptidesFile";
#the header line
my $headerLine = <IN>;
chomp $headerLine;
#save the optional header into the array
my (undef,undef,undef,undef,undef,undef,@optionalHeader) = split(/\t/, $headerLine);
my $optionalHeaderLen = scalar @ optionalHeader;
my %hits;#keys are the id (protein matching the pattern) used in sam, values are arrays of $peptide_info
while (my $line = <IN>){
	chomp $line;
	my @elmts = split(/\t/, $line);
	#next if ($elmts[2] eq '+' || $elmts[3] eq '+');#2 Reverse 3 contaminant, if true that record should not be used
	#in the form of peptide, confidence, quantitation and optional values (in the format for GFF3 output)
	my $peptide_info = "$elmts[0] confidence $elmts[4] quantitation $elmts[5] ";
	for (my $i = 0;$i< $optionalHeaderLen;$i++){
		$peptide_info .= lc($optionalHeader[$i])."=$elmts[$i+6];";
	}

	my $protein_name = $elmts[1];#Protein, e.g. >96407_5 [2245 - 587] (REVERSE SENSE);>96409_5 [2116 - 566] (REVERSE SENSE);>96408_5 [2043 - 613] (REVERSE SENSE),96410_5 [2172 - 742] (REVERSE SENSE)
	$protein_name =~ s/,/>/g; #replace , with >
	my @protein_entries = split(/>/, $protein_name); #some elements may have ; at the end which does not matter due to the RE
	for (my $i=1;$i<scalar @protein_entries;$i++){#start from index 1 as the first element is always empty due to the fasta header format
		my $current = $protein_entries[$i];
		if($current=~/$pattern/){
			push (@{$hits{$&}},$peptide_info);
#			push (@{$hits{$1}},$peptide_info);
		}
	}
	if ($elmts[4] > 10){#confidence
		$maxConfidence = 0 if ($confidenceIsPvalue == 1);
		$confidenceIsPvalue = 0 ;
	}
	if($confidenceIsPvalue==0){
		$maxConfidence = $elmts[4] if($elmts[4]>$maxConfidence);
	}else{
		my $score = -log($elmts[4])/log(10);
		$maxConfidence = $score if ($score>$maxConfidence);
	}
}
#print "max confidence value $maxConfidence\n";

#output the new sam which combines the identification/quantitation from the search result with the original sam file
#open OUT, ">new_$samFile";
open OUT, ">$samOutFile";
open GFF, ">$gffFile";
print GFF "##gff-version 3\n";
foreach my $header(@samHeader){
	print OUT "$header\n";
}
foreach my $sam (@samorder){
	print OUT "$sam{$sam}";
	if(exists $hits{$sam}){#has the identified peptides
		my $fullSam = $sam{$sam};
		print OUT "\t$optional_tag";
		$fullSam .= "\t$optional_tag";
		my @arr = @{$hits{$sam}};
		foreach my $tmp(@arr){
			print OUT " $tmp<br>";#keep it consistent which makes the codes re-usable to parse the generated sam file directly
			$fullSam .= " $tmp<br>";
		}
		&cigar_analysis($fullSam);
	}
	print OUT "\n";
}
close(OUT);
close(IN);
open ORF,">$fastaFile";
foreach my $orf(sort {$a cmp $b} keys %totalORFs){
	print ORF "$totalORFs{$orf}\n$orf\n";
}
close ORF;

sub cigar_analysis(){
# The main algorithm
# 1. find and export the orf
# 2. find the distance from the peptide start to the transcript start using the equation distance = start of orf + (index of peptide - 1)*3
# 3. locate the part where the peptide start should locate, record the index and type. The types cannot contain the peptide start include D, H, N, P, i.e. allowing include M, I, S, X, =
# 4. calculate the actual coordinate for the peptide start
	# a. CIGAR type affect the reference location before index DN +, SI -, HPM=X ignore to work out offset
	# b. use the equation start position = transcript start (in the sam) + distance + offset - 1

	#one sam record from the newly generated sam file
	my $sam=$_[0];
	my @sam = split("\t",$sam);
	my $id = $sam[0];
	my $chr = $sam[2];
	my $transcript_start = uc($sam[3]);
	my $cigar = $sam[5];
	my $transcript_seq = $sam[9];
	#print "$id\n$chr\n$transcript_start\n$cigar\n$transcript_seq\n";

	#retrieve the identified peptides
	my @peptides;
	my %peptideInfo;
	my $hitString = $sam[-1];
	$hitString = substr($hitString,length($optional_tag));#remove the optional tag
	my @tmp = split("<br>",$hitString); # the last element contains the identified peptides separated by <br> tag
	my %uniquePeptideHit; #one protein can have multiple ORFs containing the same peptide, so there may be multiple entries in the protein list for the same protein
	my %orfSeqs;#it is very likely that all peptides are from the same ORF and it only needs to be outputed once
	my %orfFrames;
	
	foreach my $tmp(@tmp){
		next if (exists $uniquePeptideHit{$tmp});
		$uniquePeptideHit{$tmp}++;
		#the output format used in the output "$elmts[0] confidence $elmts[4] quantitation $elmts[5]";
		#peptide only \w, confidence could be double or scientific expression, quant could be double or special string, eg NA, NaN etc
		if($tmp=~/(\w+) confidence ([\w\.-]+) quantitation ([\w\.]+) /){
			push(@peptides,$1);
			$peptideInfo{$1}{'score'} = $2;
			$peptideInfo{$1}{'quant'} = $3;
			$peptideInfo{$1}{'rest'} = $';
		}
	}
	# foreach (keys %uniquePeptideHit){
		# print "$_: $uniquePeptideHit{$_}\n";
	# }
	# print "Peptides: @peptides\n";
	# exit;
	#six frames translation
	my %frames; # this variable is introduced only because to reuse the codes of deciphering CIGAR for both + and - strands
	my $len = length $transcript_seq;
	#5'->3' + strand
	for(my $offset = 1;$offset<4;$offset++){
		my $translation = "";
		for (my $i=-1+$offset;$i<$len-2;$i+=3){
			my $codon = substr($transcript_seq,$i,3);
			$translation.= $translation{$codon};
		}
		$frames{$offset} = $translation;
		# print "Frame $offset:\n$translation\n";
	}
	#3'->5' - strand
	my $reversecomp = reverse $transcript_seq;
	$reversecomp =~ tr/ACGT/TGCA/;	
	for(my $offset = 1;$offset<4;$offset++){
		my $translation = "";
		for (my $i=-1+$offset;$i<$len-2;$i+=3){
			my $codon = substr($reversecomp,$i,3);
			$translation.= $translation{$codon};
		}
		$frames{-$offset} = $translation;
		# print "Frame -$offset:\n$translation\n";
	}
	# print "peptides: @peptides\n";
	#find the peptide-corresponding transcript location in the mapped genome sequence and output the ORFs
	my %peptideStart;#keys are peptide sequence, values are arrays of value in the form of strand_start position
	foreach my $frame(keys %frames){
		my $translation = $frames{$frame};
		my @segments = split($STOP,$translation);#for orf determination as orf must have a stop codon or at the end of translation
		foreach my $peptide(@peptides){
			#check whether the identified peptide is in the current frame by splitting the translation
			#if more than one in the array, means yes
			#the special only one element case is that the peptide is at the end of translation, which only generate one element which is the whole sequence without the splitting peptide
			my @hits = split("$peptide",$translation);
			my $hitsLen = scalar @hits;
			next unless ($hitsLen > 1 || $hits[0] ne $translation);
			#locate the DNA position for the peptide
			my $pepLen = length $peptide;
			if($frame>0){ #+ strand
				my $firstLen = $frame+ (length $hits[0])*3 - 1;
				my $currStart = $firstLen;
				if($hitsLen==1){ #the special case that the peptide locates at the end of frame translation
					# my $dna = substr($transcript_seq,$currStart,$pepLen*3);
					# print "start position: $currStart\n";
					push(@{$peptideStart{$peptide}},"+_$currStart");
				}else{
					for(my $i=1;$i<scalar @hits;$i++){
						# my $dna = substr($transcript_seq,$currStart,$pepLen*3);
						# print "start position: $currStart\n";
						push(@{$peptideStart{$peptide}},"+_$currStart");
						$currStart += ((length $hits[$i])+$pepLen)*3;
					}
				}
			}else{ #- strand
				my $firstLen = $len + $frame - (length $hits[0])*3;
				my $currStart = $firstLen;
				if($hitsLen==1){
					my $currEnd = $currStart - $pepLen*3 + 1;
					#my $dna = substr($transcript_seq,$currEnd,$pepLen*3);
					# print "start position: $currEnd\n";
					push(@{$peptideStart{$peptide}},"-_$currEnd");
				}else{
					for(my $i = 1;$i<scalar @hits;$i++){
						my $currEnd = $currStart - $pepLen*3 + 1;
						#my $dna = substr($transcript_seq,$currEnd,$pepLen*3);
						# print "start position: $currEnd\n";
						push(@{$peptideStart{$peptide}},"-_$currEnd");
						$currStart -= ((length $hits[$i])+$pepLen)*3;
					}
				}
			}
			#find the orfs
			my $segment = $segments[0];
			my $idxPeptide = index($segment,$peptide);#whether contain the peptide
			if($idxPeptide>-1){#contains the identified peptide, potential orf
				#print "peptide location $idxPeptide\n";
				my $orf;
				my $idxM = index($segment,"M");
				#print "M location: $idxM\n";
				if($idxM<0){
					$orf = $segment;
				}elsif($idxM<=$idxPeptide){
					$orf = substr($segment,$idxM);
				}else{
					$orf = $segment;
				}
				# print "first $frame\t$peptide\n$orf\n\n";
				$orfSeqs{$orf}{$peptide}++;
				$orfFrames{$orf}=$frame;
			}
			for (my $i = 1;$i<scalar @segments;$i++){
				$segment = $segments[$i];
				$idxPeptide = index($segment,$peptide);
				if($idxPeptide>-1){#contains the identified peptide, potential orf
					my $idxM = index($segment,"M");
					my $orf;
					if($idxM > -1){#assuming M must be before the peptide, otherwise the peptide won't be in the ORF in the first place
						$orf = substr($segment,$idxM);
					}else{
						$orf = $segment;
					}
					# print "others $frame\t$peptide\n$orf\n\n";
					$orfSeqs{$orf}{$peptide}++;
					$orfFrames{$orf}=$frame;
				}
			}
		}
	}#end of %frame
	#exit;
	
	#the CIGAR string is for the transcript, not only for the identified peptide, so only needs to be parsed once
	#if cigar string is "18M13852N132M1063N110M4003N103M", then @cigar is 18,M,13852,N,...,103,M
	my @cigar = split(/(M|I|D|N|S|H|P|X|=)/, $cigar);
	my $cigarLen = (scalar @cigar)/2; #the number of cigar entries, one cigar entry is composed of a number (even index 0,2,...) and a type (odd index 1,3,...)
	my $remain = (scalar @cigar) % 2;
	#validate the cigar string, not empty, not *
	#if this is the case, means not mapping to the genome, could be from another species etc., output ORFs only
	if($cigarLen==0 || $remain == 1){
		my @orfs = sort {$a cmp $b} keys %orfSeqs;
		my $orfIndex = 0;
		for (my $i=0;$i<scalar @orfs;$i++){
			my $orf= $orfs[$i];
			$orfIndex++;
			my $orfId = "${id}_orf${orfIndex}_nm";
			if (exists $totalORFs{$orf}){
				$totalORFs{$orf}.=";$orfId";
			}else{
				$totalORFs{$orf} = ">$orfId";
			}
		}
		return; 
	}
	# print "do cigar analysis\n";
	#algorithm step 3 locate the part where the peptide start should locate, record the index and type. The types cannot contain the peptide start include D, H, N, P, i.e. allowing include M, I, S, X, =
	#as one sam record has one CIGAR string and possible several peptides, so do all CIGAR calculation first
	my @distance;#the coordinate in the transcript, types D, H, N, P have no effect, i.e. allowing include M, I, S, X, =
	my @offset;#DN +, SI -, HPM=X ignore
	my @exons;
	my $distance = 0;
	my $offset = 0;
	my $exon = 1;
	for(my $i=0;$i<$cigarLen;$i++){
		if($cigar[2*$i+1]=~/[MISX=]/){
			$distance += $cigar[2*$i];
		}
		$distance[$i] = $distance;
		
		if($cigar[2*$i+1]=~/[DN]/){
			$offset += $cigar[2*$i];
		}elsif($cigar[2*$i+1]=~/[SI]/){
			$offset -= $cigar[2*$i];
		}
		$offset[$i] = $offset;
		
		$exon++ if ($cigar[2*$i+1] eq "N");
		$exons[$i]=$exon;
	}
	
	# for(my $i=0;$i<$cigarLen;$i++){
		# print "cigar: $cigar[2*$i]$cigar[2*$i+1]\tdistance: $distance[$i]\toffset $offset[$i]\texon $exons[$i]\n";
	# }

	#do the calculation for each peptide
	my %peptideInGff;
	foreach my $peptide(@peptides){
		next unless (exists $peptideStart{$peptide});
		#get all locations of peptides in the frame
		my @start = @{$peptideStart{$peptide}};
		foreach my $current(@start){
			my ($strand,$start) = split("_",$current);
			#print "Peptide: $peptide\tstrand: $strand\tStart: $start\n";
			for (my $i=0;$i<$cigarLen;$i++){
				if($distance[$i]>$start){#found
					# print "$peptide: $cigar[$i*2]$cigar[$i*2+1] $offset[$i]\n";
					next if ($cigar[$i*2+1] eq "S");#if the sequence locates in the S which means not mapped to the reference genome, so skip
					$peptideInGff{$peptide} = 1;
					my $genomeStart = $transcript_start + $start + $offset[$i];
					my $dnaLen = (length $peptide)*3;
					my $dna = substr ($transcript_seq,$start,$dnaLen);#get the peptide-coding transcript
					my $genomeEnd;
					my $end = $start + $dnaLen - 1;
					my $cigarMatch; #for the Gap attribute in the GFF3, CIGAR like string
					my $exonStr;
					if ($end <= $distance[$i]){#the end position also locates within the same cigar segment
						$genomeEnd = $genomeStart + $dnaLen - 1;
						$cigarMatch = "M${dnaLen}";
						$exonStr = "exon=$exons[$i]";
					}else{#not in the same cigar segment as the start
						$cigarMatch = "M".($distance[$i]-$start);
						for (my $j=$i+1;$j<$cigarLen;$j++){
							if ($distance[$j]>$end){
								$genomeEnd = $transcript_start + $end + $offset[$j];
								$cigarMatch .= " M".($end-$distance[$j-1]+1);
								$exonStr = "exons=$exons[$i]-$exons[$j]";
								last;
							}else{
								$cigarMatch .= " $cigar[$j*2+1]$cigar[$j*2]";
							}
						}
					}
					$cigarMatch =~ tr/N/D/;	#in GFF, only 5 types M, I, D, and other two for protein-DNA alignment which do not apply here
#color the feature according to the confidence level and quantitation value
# a.	Convert the confidence as getting the maximum confidence value above, divided by the maximum value got in step 1-c to get the normalized confidence, assign to S (value between 0.5 and 1)
					my $r;
					my $g;
					my $b; 
					if($peptideInfo{$peptide}{'quant'}=~/\d*\.*\d+/){
						my $confidenceValue = $peptideInfo{$peptide}{'score'};
						$confidenceValue = -log($peptideInfo{$peptide}{'score'})/log(10) if ($confidenceIsPvalue == 1);
						my $s = $confidenceValue/$maxConfidence/2+0.5;#scale s to between 0.5-1 to avoid the feature invisiable
						#my $s = 1;#set s=1 first to do quantitation first
# b.	For the quantitation value H (between 0 and 2). Because it’s a ratio, need to take logs.
# 	i.	apply the equation log(value)/log(max_fold_change)+1 to get H’
# 	ii.	if H’ is great than 2, assign H = 2
# 		if H’ is less than 0, assign H=0
# 		else assign H = H’
						my $quantValue = log($peptideInfo{$peptide}{'quant'})/log($max_fold_change)+1;
						my $h;
						if($quantValue>2){
							$h = 2;
						}elsif($quantValue<0){
							$h = 0;
						}else{
							$h = $quantValue;
						}
# c.	Calculate the RGB value
# i.	If H<1: R’=1; G’=(S*H)+1-S; B’=1-S
# ii.	If H>=1:R’=(S*(2-H))+1-S;G’=1;B’=1-S
# iii.	Multiple 255 to all R’, G’, B’ and round to the integer to get R, G, B correspondingly
						if ($h < 1){
							$r = 255;
							$g = ceil(($s*$h+1-$s)*255);
						}else{
							$r = ceil(($s*(2-$h)+1-$s)*255);
							$g = 255;
						}
						$b = ceil((1-$s)*255);
					}else{
						$r=0;
						$g=0;
						$b=0;
					}
#Ready to output the GFF3
#GFF3 definition http://www.sequenceontology.org/gff3.shtml
# nine-column, tab-delimited, plain text files
#1. seqid: [a-zA-Z0-9.:^*$@!+_?-|]	in sam column 3 RNAME \*|[!-()+-<>-~][!-~]*, 
#2. source: name of the software or database name, will be "pit" as the software
#3. type/method: each row is an identified peptides, could be use "cds"
#4 and 5. start and end coordinate  Start is always less than or equal to end. 
#6. score
#7. strand 
#8. phase as the start position is always the start of the codons, should be 0 always
#9. attributes: A list of feature attributes in the format tag=value. Multiple tag=value pairs are separated by semicolons.
#   All attributes that begin with an uppercase letter are reserved for later use. Attributes that begin with a lowercase letter can be used freely by applications.
					print GFF "$chr\tPIT\tcDNA_match\t$genomeStart\t$genomeEnd\t0\t$strand\t0\tName=$id;peptide=$peptide;transcript=$dna;color=$r,$g,$b;score=$peptideInfo{$peptide}{'score'};quantitation=$peptideInfo{$peptide}{'quant'};Gap=$cigarMatch;$peptideInfo{$peptide}{'rest'}$exonStr\n";
					# print "$peptide: $chr $transcript_start start $start offset $offset[$i] $genomeStart $genomeEnd with sequence $dna $exonStr\n";
					last;
				}
			}
		}
	}#end of foreach @peptides genome location calculation
	#put the detected orf into the total ORFs
	#only when it can be mapped onto the genome i.e. having valid cigar string
	my @orfs = sort {$a cmp $b} keys %orfSeqs;
	my @candidates;
	my @noSupport;
	for(my $i=0;$i<scalar @orfs;$i++){
		my $orf = $orfs[$i];
		my %fromPeptides = %{$orfSeqs{$orf}};
		my $flag = 0;
		foreach my $pep(keys %fromPeptides){
			if (exists $peptideInGff{$pep}){
				$flag = 1;#having identified peptide support
				last;
			}
		}
		if($flag==1){
			for (my $j=0;$j<scalar @orfs;$j++){
				next if ($i == $j); #the same orf
				my $another = $orfs[$j];
				if ($orfFrames{$orf} == $orfFrames{$another}){ # the same frame, then judge whether the substring of the other one, if so, discard the current orf
					if (index($another,$orf)>-1){#is substring
						$flag = 2;
						last;
					}
				}
			}
		}
		push (@candidates,$orf) if ($flag == 1);
		push (@noSupport,$orf) if ($flag == 0);
	}
	my $orfIndex = 0;
	for (my $i=0;$i<scalar @candidates;$i++){
		my $orf= $candidates[$i];
		$orfIndex++;
		my $orfId = "${id}_orf${orfIndex}_wp";
		if (exists $totalORFs{$orf}){
			$totalORFs{$orf}.=";$orfId";
		}else{
			$totalORFs{$orf} = ">$orfId";
		}
	}
	for (my $i=0;$i<scalar @noSupport;$i++){
		my $orf = $noSupport[$i];
		$orfIndex++;
		my $orfId = "${id}_orf${orfIndex}_np";
		#print "$orfId\n";
		if (exists $totalORFs{$orf}){
			$totalORFs{$orf}.=";$orfId";
		}else{
			$totalORFs{$orf} = ">$orfId";
		}
	}
}

sub readSam(){
	open IN, "$_[0]" or die "Can not find the specified sam file $_[0]";
	my $line;
	#skip headers
	while ($line = <IN>){
		last unless ($line=~/^@/);
		push(@samHeader,$line);
	}

	do{
		chomp $line;
		my @elmts = split(/\t/, $line);
		$sam{$elmts[0]} = "$line";
		push(@samorder,$elmts[0]);
	}while($line=<IN>);
	close IN;
}

sub usage(){
	print "Usage: perl pit.pl <sam file> <identification file in the tsv format> <matching pattern> <max fold change>\n\n";
	print "The script uses the given pattern to link the identified peptides in the identification file with the transcripts which have been mapped to the reference genomes";
	print "calculates the exact location for the identified peptides and outputs the ORF and GFF3 files. The latter can be visualized in IGV.\n";
	print "The sam file provides the reference=genome-mapping information\n";
	print "The identification file can be converted from mzIdentML or the sub-file extracted from a MaxQuant result file\n";
	print "The pattern is the regular expression pattern which can describe the transcript id in the sam file\n";
	print "The max fold change is an integer, which is used to cap the quantitation fold change\n";
	exit;
}
