#!/usr/bin/perl -w
use strict;
use POSIX;
#pitGalaxy is the galaxy version of pit, which specifies all output files in the command line
#my $argLen = scalar @ARGV;
#&usage() unless($argLen==4);
#result file: the longest ORF fasta file
#suffix "_nm": not mapping result in SAM file (GMAP), could indicate that the transcript is from another species rather than the one trying to be mapped in GMAP
#suffix "_np": the ORF is found in the transcript, but no identified peptide to support
#suffix "_wp": the ORF with identified peptide support

# the sam file
#my $samFile = "human.sam";
my $samFile = $ARGV[0];

# the result file from extractPeptides.txt which has the fixed header order, 1 peptide 2 protein 3 reverse 4 contaminant 5 score 6 m/l 7 h/l 8 h/m
#my $peptidesFile = "peptidesNew-extract.txt";
my $peptidesFile = $ARGV[1];

#quotemeta function maybe useful here http://perldoc.perl.org/functions/quotemeta.html
#my $pattern = "^(comp\\d+_c\\d+_seq\\d+)";
#$argv="^(\\d+)_(\\d+)\\s";
my $pattern= $ARGV[2];
print "pattern: $pattern\n";

my $fastaIn = $ARGV[3];

#the quantitation can be of any value
#my $max_fold_change = 2;
my $max_fold_change = $ARGV[4];
&usage() unless ($max_fold_change=~/^\d+$/);
#my $suffixLocation = rindex ($samFile,".");
#my $prefix;
#if($suffixLocation>-1){
#	$prefix = substr($samFile,0,$suffixLocation);
#}else{
#	$prefix = $samFile;
#}
my $gffFile = $ARGV[5];
my $samOutFile = $ARGV[6];
my $fastaFile = $ARGV[7];
my $tsvFile = $ARGV[8];
#my $gffFile = "result.gff3";
#my $samOutFile = "result.sam";
#my $fastaFile = "resultORFs.fasta";
#my $tsvFile = "resultTable.txt";
open TSV, ">$tsvFile";
print TSV "ORF id\tType\tORF seq\tTranscript seq\tIdentified peptide number\tIdentified peptide list\n";
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
#my %sam; #the keys are ids and the values are sam records
#my @samHeader; #store the headers in the sam file which starts with @
#my @samorder; #the arrays keeping the original order of records in the original sam file which normally is ordered
my %seqs; #stores the sequences from the ORF file
my %totalORFs;

&readFasta($fastaIn);
#&cigar_analysis("CUFF.20243.1	0	2	108487161	40	3245H2218M	*	0	0	GGTTCTTCTAATACAGAATTTAAGTCAACCAAAGAAGGATTTTCCATCCCTGTGTCTGCTGATGGATTTAAATTTGGCATTTCGGAACCAGGAAATCAAGAAAAGAAAAGTGAAAAGCCTCTTGAAAATGGTACTGGCTTCCAGGCTCAGGATATTAGTGGCCAGAAGAATGGCCGTGGTGTGATTTTTGGCCAAACAAGTAGCACTTTTACATTTGCAGATCTTGCAAAATCAACTTCAGGAGAAGGATTTCAGTTTGGCAAAAAAGACCCCAATTTCAAGGGATTTTCAGGTGCTGGAGAAAAATTATTCTCATCACAATACGGTAAAATGGCCAATAAAGCAAACACTTCCGGTGACTTTGAGAAAGATGATGATGCCTATAAGACTGAGGACAGCGATGACATCCATTTTGAACCAGTAGTTCAAATGCCCGAAAAAGTAGAACTTGTAACAGGAGAAGAAGATGAAAAAGTTCTGTATTCACAGCGGGTAAAACTATTTAGATTTGATGCTGAGGTAAGTCAGTGGAAAGAAAGGGGCTTGGGGAACTTAAAAATTCTCAAAAACGAGGTCAATGGCAAACTAAGAATGCTGATGCGAAGAGAACAAGTACTAAAAGTGTGTGCTAATCATTGGATAACGACTACGATGAACCTGAAGCCTCTCTCTGGATCAGATAGAGCATGGATGTGGTTAGCCAGTGATTTCTCTGATGGTGATGCCAAACTAGAGCAGTTGGCAGCAAAATTTAAAACACCAGAGCTGGCTGAAGAATTCAAGCAGAAATTTGAGGAATGCCAGCGGCTTCTGTTAGACATACCACTTCAAACTCCCCATAAACTTGTAGATACTGGCAGAGCTGCCAAGTTAATACAGAGAGCTGAAGAAATGAAGAGTGGACTGAAAGATTTCAAAACATTTTTGACAAATGATCAAACAAAAGTCACTGAGGAAGAAAATAAGGGTTCAGGTACAGGTGCGGCCGGTGCCTCAGACACAACAATAAAACCCAATCCTGAAAACACTGGGCCCACATTAGAATGGGATAACTATGATTTAAGGGAAGATGCTTTGGATGATAGTGTCAGTAGTAGCTCAGTACATGCTTCTCCATTGGCAAGTAGCCCTGTGAGAAAAAATCTTTTCCGTTTTGGTGAGTCAACAACAGGATTTAACTTCAGTTTTAAATCTGCTTTGAGTCCATCTAAGTCTCCTGCCAAGTTGAATCAGAGTGGGACTTCAGTTGGCACTGATGAAGAATCTGATGTTACTCAAGAAGAAGAGAGAGATGGACAGTACTTTGAACCTGTTGTTCCTTTACCTGATCTAGTTGAAGTATCCAGTGGTGAGGAAAATGAACAAGTTGTTTTTAGTCACAGGGCAAAACTCTACAGATATGATAAAGATGTTGGTCAATGGAAAGAAAGGGGCATTGGTGATATAAAGATTTTACAGAATTATGATAATAAGCAAGTTCGTATAGTGATGAGAAGGGACCAAGTATTAAAACTTTGTGCCAATCACAGAATAACTCCAGACATGACTTTGCAAAATATGAAAGGGACAGAAAGAGTATGGTTGTGGACTGCATGTGATTTTGCAGATGGAGAAAGAAAAGTAGAGCATTTAGCTGTTCGTTTTAAACTACAGGATGTTGCAGACTCGTTTAAGAAAATTTTTGATGAAGCAAAAACAGCCCAGGAAAAAGATTCTTTGATAACACCTCATGTTTCTCGGTCAAGCACTCCCAGAGAGTCACCATGTGGCAAAATTGCTGTAGCTGTATTAGAAGAAACCACAAGAGAGAGGACAGATGTTATTCAGGGTGATGATGTAGCAGATGCAACTTCAGAAGTTGAAGTGTCTAGCACATCTGAAACAACACCAAAAGCAGTGGTTTCTCCTCCAAAGTTTGTATTTGGTTCAGAGTCTGTTAAAAGCATTTTTAGTAGTGAAAAATCAAAACCATTTGCATTCGGCAACAGTTCAGCCACTGGGTCTTTGTTTGGATTTAGTTTTAATGCACCTTTGAAAAGTAACAATAGTGAAACTAGTTCAGTAGCCCAGAGTGGATCTGAAAGCAAAGTGGAACCTAAAAAATGTGAACTGTCAAAGAACTCTGATATCGAACAGTCTTCAGATAGCAAAGTCAAAAATCTCTTTGCTTCCTTTCCAACGGAAGAATCTTCAATCAACTACACATTTAAAACACCAG	*	MD:Z:105G24A91G99G111T19T11G22G34G61C63A14C2G28C38G3A64A248G95A23C187A23G141C17G34G266G38A55A35T11T36T16C118C14T38	NH:i:19	HI:i:1	NM:i:34	SM:i:40	XQ:i:40	X2:i:0	XO:Z:UT	XT:Z:GG-AG,0.00,1.00,3245..3245	PG:Z:M	pt:Z:The peptides are  ITPDMTLQNMK confidence 4.1206065E-4 quantitation 1 ms-gf:specevalue=2.0675467E-11 ORF CUFF.20243.1_ORF8_Frame_3_57-5462<br> SNNSETSSVAQSGSESK confidence 3.1412476E-8 quantitation 1 ms-gf:specevalue=1.5590609E-15 ORF CUFF.20243.1_ORF8_Frame_3_57-5462<br> ILQNYDNKQVR confidence 4.197988E-5 quantitation 1 ms-gf:specevalue=2.1063735E-12 ORF CUFF.20243.1_ORF8_Frame_3_57-5462<br> ELVGPPLAETVFTPK confidence 1.1228497E-7 quantitation 1 ms-gf:specevalue=5.589079E-15 ORF CUFF.20243.1_ORF8_Frame_3_57-5462<br> FGTSETSKAPK confidence 0.0026715533 quantitation 1 ms-gf:specevalue=1.3404729E-10 ORF CUFF.20243.1_ORF8_Frame_3_57-5462<br> QNQTTSAVSTPASSETSK confidence 4.0880364E-5 quantitation 1 ms-gf:specevalue=2.0263674E-12 ORF CUFF.20243.1_ORF8_Frame_3_57-5462<br> LHDSSGSQVGTGFK confidence 2.7241316E-5 quantitation 1 ms-gf:specevalue=1.3582062E-12;ORF=CUFF.20243.1_ORF8_Frame_3_57-5462<br> SNNSETSSVAQSGSESKVEPK confidence 3.9055948E-7 quantitation 1 ms-gf:specevalue=1.929342E-14 ORF CUFF.20243.1_ORF8_Frame_3_57-5462<br> SGSSFVHQASFK confidence 1.9898128E-7 quantitation 1 ms-gf:specevalue=9.960201E-15 ORF CUFF.20243.1_ORF8_Frame_3_57-5462<br> APGTNVAMASNQAVR confidence 3.3309543E-6 quantitation 1 ms-gf:specevalue=1.6580106E-13 ORF CUFF.20243.1_ORF8_Frame_3_57-5462<br>");
#exit;
 
#read in the sam file
#&readSam("$samFile");

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
	#now the last char of peptide_info is ";", which is removed in the next line
	$peptide_info = substr($peptide_info, 0, (length $peptide_info) - 1);
	
	my $protein_name = $elmts[1];#Protein, e.g. >96407_5 [2245 - 587] (REVERSE SENSE);>96409_5 [2116 - 566] (REVERSE SENSE);>96408_5 [2043 - 613] (REVERSE SENSE),96410_5 [2172 - 742] (REVERSE SENSE)
	$protein_name =~ s/,/>/g; #replace , with > 
	$protein_name =~ s/;/>/g; #replace , with > 
#	print "proteins: $protein_name\npeptide info $peptide_info";
	#The , and ; can be caused by two situations: from ORF tool (e.g. ORFall, same ORF predicted from multiple transcripts) or from identification (identified peptide exists in more than one protein, then multiple transcript involved)
	#sam file is transcript based, so needs to be split 
	my @protein_entries = split(/>/, $protein_name); 
	for (my $i=0;$i<scalar @protein_entries;$i++){
		my $current = $protein_entries[$i];
		if($current=~/$pattern/){
			$hits{$&}{"$peptide_info;ORF=$current"}++; #peptides maybe have different modification status, then cause multiple entries => use hash instead of array
#			push (@{$hits{$&}},"$peptide_info ORF $current");
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
open IN, "$samFile" or die "Can not find the specified sam file $samFile";
my $line;
my %predictedCount;#must be global variable, as one transcript can be mapped to different regions, more than one of which needs to predict ORFs
#headers
while ($line = <IN>){
	chomp $line;
	last unless ($line=~/^@/);
	print OUT "$line\n";
}

do{
	chomp $line;
	print OUT "$line";
	my @elmts = split(/\t/, $line);
	if(exists $hits{$elmts[0]}){#has the identified peptides
		my $fullSam = $line;
		print OUT "\t$optional_tag";
		$fullSam .= "\t$optional_tag";
		my @arr = keys %{$hits{$elmts[0]}};
		foreach my $tmp(@arr){
			print OUT " $tmp<br>";#keep it consistent which makes the codes re-usable to parse the generated sam file directly
			$fullSam .= " $tmp<br>";
		}
		&cigar_analysis($fullSam);
	}
	print OUT "\n";
}while($line=<IN>);

close IN;
close(OUT);
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
	my $transcript_start = $sam[3];
	my $cigar = $sam[5];
	my $transcript_seq = uc($sam[9]);
	#print "$id\n$chr\n$transcript_start\n$cigar\n$transcript_seq\n";

	#retrieve the identified peptides
	my @peptides;
	my %peptideInfo;
	my %orfSeqs; #keys are orf names, i.e. the protein name in the identification file and fasta header e.g. CUFF.38.1_ORF1_***, values are the sequences retrieved from the fasta file
	my $hitString = $sam[-1];
	$hitString = substr($hitString,length($optional_tag));#remove the optional tag
	my @tmp = split("<br>",$hitString); # the last element contains the identified peptides separated by <br> tag
	my %uniquePeptideHit; #one protein can have multiple ORFs containing the same peptide, so there may be multiple entries in the protein list for the same protein
	#convert plain hit information into data structure %peptideInfo hash of hash first key is the peptide sequence, the second keys are pre-defined score, quant and rest
	foreach my $tmp(@tmp){
		next if (exists $uniquePeptideHit{$tmp});
		$uniquePeptideHit{$tmp}++;
		#the output format used in the output "$elmts[0] confidence $elmts[4] quantitation $elmts[5]";
		#peptide only \w, confidence could be double or scientific expression, quant could be double or special string, eg NA, NaN etc
		if($tmp=~/(\w+) confidence ([\w\.-]+) quantitation ([\w\.]+) /){
			my $peptide = $1;
			push(@peptides,$peptide);
			$peptideInfo{$peptide}{'score'} = $2;
			$peptideInfo{$peptide}{'quant'} = $3;
			my $rest = $';
			$peptideInfo{$peptide}{'rest'} = $rest;
			#print "Rest: $rest\n";
			if ($rest=~/;ORF=(.+)$/){
				$peptideInfo{$peptide}{'orf'} = $1;
				unless (exists $orfSeqs{$1}){ 
					if (exists $seqs{$1}){
						$orfSeqs{$1} = $seqs{$1};
					}else{
						print "Error: protein $1 cannot be found in the fasta file $fastaIn\n";
					}
				}
			}
		}
	}
	# foreach (keys %uniquePeptideHit){
		# print "$_: $uniquePeptideHit{$_}\n";
	# }
	# print "Peptides: @peptides\n";
#	foreach my $peptide(@peptides){
#		print "$peptide:\nscore $peptideInfo{$peptide}{'score'}\nquant $peptideInfo{$peptide}{'quant'}\n";
#		print "ORF $peptideInfo{$peptide}{'orf'}\nother $peptideInfo{$peptide}{'rest'}\n\n";
#	}
#	foreach my $orf(keys %orfSeqs){
#		print "ORF $orf\n$orfSeqs{$orf}\n";
#	}

	#six frames translation
	my %frames; # this variable is introduced only for the purpose of reusing the codes of deciphering CIGAR for both + and - strands
	my @foundFrames;
	my $len = length $transcript_seq;
	#5'->3' + strand
	for(my $offset = 1;$offset<4;$offset++){
		my $translation = "";
		for (my $i=-1+$offset;$i<$len-2;$i+=3){
			my $codon = substr($transcript_seq,$i,3);
			if(exists $translation{$codon}){
				$translation.= $translation{$codon};
			}else{
				print "Error: codon $codon not found, in sam line $sam\n";
			}
		}
		#only keep the frame which contains the identified ORF
		my $found = 0;
		foreach (values %orfSeqs){
			if (index($translation, $_)>-1){
				$found = 1;
				last;
			}
		}
		push (@foundFrames,$offset) if ($found == 1);
		$frames{$offset} = $translation;
#		print "Frame $offset:\n$translation\n";
	}
	#3'->5' - strand
	my $reversecomp = reverse $transcript_seq;
	$reversecomp =~ tr/ACGT/TGCA/;	
	for(my $offset = 1;$offset<4;$offset++){
		my $translation = "";
		for (my $i=-1+$offset;$i<$len-2;$i+=3){
			my $codon = substr($reversecomp,$i,3);
			if(exists $translation{$codon}){
				$translation.= $translation{$codon};
			}else{
				print "Error: codon $codon not found, in sam line $sam\n";
			}
		}
		my $found = 0;
		foreach (values %orfSeqs){
			if (index($translation, $_)>-1){
				$found = 1;
				last;
			}
		}
		push (@foundFrames,-$offset) if ($found == 1);
		$frames{-$offset} = $translation;
#		print "Frame -$offset:\n$translation\n";
	}
#	foreach (sort {$a<=>$b} keys %frames){
#		print "Frame $_:\n$frames{$_}\n";
#	}
#	print "peptides: @peptides\n";

	#find the peptide-corresponding transcript location in the mapped genome sequence and output the ORFs
	#link ORF translated from the transcript with identified peptides
	my %peptideStart;#keys are peptide sequence, values are arrays of value in the form of strand_start position
	#it is very likely that all peptides are from the same ORF and it only needs to be outputted once
	my %orfPeptides; # keys are orfs names and values are hashes with keys as peptides and values as count of peptides.
	my %orfFrames; # keys are orf names and values are array of frames the orf is found, which could happen in multiple frames
#	my %predictedORF;
	
	if ((scalar @foundFrames) == 0){ #need to predict ORF from transcript sequence in SAM
#		my $predictCount = 1;
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
				my $orfSeq;
				#first segment
				if($idxPeptide>-1){#contains the identified peptide, potential orf
					#print "peptide location $idxPeptide\n";
					
					my $idxM = index($segment,"M");
					#print "M location: $idxM\n";
					if($idxM<0){#no M found
						$orfSeq = $segment;
					}elsif($idxM<=$idxPeptide){#M in front of the peptide
						$orfSeq = substr($segment,$idxM);
					}else{#M behind the peptide, no use, whole segment
						$orfSeq = $segment;
					}
					# print "first $frame\t$peptide\n$orf\n\n";
					
					unless (exists $predictedCount{$id}){#first time to deal with this transcript
						$predictedCount{$id}{'count'} = 1;
						my $name = "$id-predicted-1";
						$predictedCount{$id}{$orfSeq} = $name;
						$orfSeqs{$name} = $orfSeq;
#						print "first A: $name $orfSeq\n";
					}else{
						unless (exists $predictedCount{$id}{$orfSeq}){#the transcript has been dealt with before, but not this orf seq
							my $count = $predictedCount{$id}{'count'}+1;
							my $name = "$id-predicted-$count";
							$predictedCount{$id}{'count'} = $count;
							$predictedCount{$id}{$orfSeq} = $name;
							$orfSeqs{$name} = $orfSeq;
#							print "next A: $name $orfSeq\n";
						}
					}
					my $orfName=$predictedCount{$id}{$orfSeq};
					$orfPeptides{$orfName}{$peptide}++;
					push (@{$orfFrames{$orfName}},$frame);
				}
				for (my $i = 1;$i<scalar @segments;$i++){
					$segment = $segments[$i];
					$idxPeptide = index($segment,$peptide);
					if($idxPeptide>-1){#contains the identified peptide, potential orf
						my $idxM = index($segment,"M");
						my $orfSeq = "";
						if($idxM > -1){#assuming M must be before the peptide, otherwise the peptide won't be in the ORF in the first place
							$orfSeq = substr($segment,$idxM);
						}
						if ((length $orfSeq)>0){
							unless (exists $predictedCount{$id}){#first time to deal with this transcript
								$predictedCount{$id}{'count'} = 1;
								my $name = "$id-predicted-1";
								$predictedCount{$id}{$orfSeq} = $name;
								$orfSeqs{$name} = $orfSeq;
#								print "first B: $name $orfSeq\n";
							}else{
								unless (exists $predictedCount{$id}{$orfSeq}){#the transcript has been dealt with before, but not this orf seq
									my $count = $predictedCount{$id}{'count'}+1;
									my $name = "$id-predicted-$count";
#									print "next B: $name $orfSeq\n";
									$predictedCount{$id}{'count'} = $count;
									$predictedCount{$id}{$orfSeq} = $name;
									$orfSeqs{$name} = $orfSeq;
								}
							}
							my $orfName=$predictedCount{$id}{$orfSeq};
							$orfPeptides{$orfName}{$peptide}++;
							push (@{$orfFrames{$orfName}},$frame);
						}
					}
				}
			}
		}#end of %frame
	}else{
		foreach my $frame(@foundFrames){
			my $translation = $frames{$frame};
			my @orfInFrame;
			my @orfInFrameSeqs;
			foreach my $orfName(keys %orfSeqs){
				if (index($translation, $orfSeqs{$orfName})>-1){
					push (@orfInFrame, $orfName);
					push (@orfInFrameSeqs, $orfSeqs{$orfName});
					push (@{$orfFrames{$orfName}},$frame);
				}
			}
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

				for (my $i=0;$i<@orfInFrame;$i++){
					if (index($orfInFrameSeqs[$i], $peptide)>-1){
						$orfPeptides{$orfInFrame[$i]}{$peptide}++;
					}
				}
			}
		}#end of %frame
	}
#	print "peptideStart\n";
#	foreach (sort keys %peptideStart){
#		print "Peptide: $_\t@{$peptideStart{$_}}\n";
#	}
#	print "orfPeptides\n";
#	foreach my $aa(sort keys %orfPeptides){
#		my %tmp = %{$orfPeptides{$aa}};
#		print "orf: $aa\n";
#		foreach my $bb(sort keys %tmp){
#			print "peptide $bb\t count $tmp{$bb}\n";
#		}
#		print "Frame: @{$orfFrames{$aa}}\n";
#	}
#	exit;
	
	#the CIGAR string is for the transcript, not only for the identified peptide, so only needs to be parsed once
	#if cigar string is "18M13852N132M1063N110M4003N103M", then @cigar is 18,M,13852,N,...,103,M
	my @cigar = split(/(M|I|D|N|S|H|P|X|=)/, $cigar);
	my $cigarLen = (scalar @cigar)/2; #the number of cigar entries, one cigar entry is composed of a number (even index 0,2,...) and a type (odd index 1,3,...)
	my $remain = (scalar @cigar) % 2;
	#validate the cigar string, not empty, not *
	#if this is the case, means not mapping to the genome, could be from another species etc., output ORFs only
	if($cigarLen==0 || $remain == 1){
		my @orfNames = sort {$a cmp $b} keys %orfPeptides;
		for (my $i=0;$i<scalar @orfNames;$i++){
			if (exists $orfSeqs{$orfNames[$i]}){#not in the ORF file used to search => decoy sequence
				my $orf= "${orfNames[$i]}_nm";
				my $orfSeq = $orfSeqs{$orfNames[$i]};
				if (exists $totalORFs{$orfSeq}){
					$totalORFs{$orfSeq}.=";$orf";
				}else{
					$totalORFs{$orfSeq} = ">$orf";
				}
				my @peps = keys %{$orfPeptides{$orf}};
				my $numPeps = scalar @peps;
				my $peps = join (",",@peps);
				print TSV "$orf\tNot mapped to genome\t$orfSeq\t$transcript_seq\t$numPeps\t$peps\n";
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
	my %peptideInGff;#keys are peptides and values are flag to indicate whether the peptide will be exported in gff3 file, i.e. found in the genome
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
					print GFF "$chr\tPIT\tcDNA_match\t$genomeStart\t$genomeEnd\t0\t$strand\t0\tName=$id;peptide=$peptide;transcript=$dna;color=$r,$g,$b;score=$peptideInfo{$peptide}{'score'};quantitation=$peptideInfo{$peptide}{'quant'};Gap=$cigarMatch;$peptideInfo{$peptide}{'rest'};$exonStr\n";
					# print "$peptide: $chr $transcript_start start $start offset $offset[$i] $genomeStart $genomeEnd with sequence $dna $exonStr\n";
					last;
				}
			}
		}
	}#end of foreach @peptides genome location calculation
	#put the detected orf into the total ORFs
	#only when it can be mapped onto the genome i.e. having valid cigar string
	my @orfs = sort {$a cmp $b} keys %orfPeptides;#keys are orf names, values are peptides with corresponding count
	my %candidates;
	my @noSupport;
	for(my $i=0;$i<scalar @orfs;$i++){
		my $orfName = $orfs[$i];
		my %fromPeptides = %{$orfPeptides{$orfName}};#keys are peptides from the ORF, values are the counts
		my $identifiedPeptideCount = 0;
		my @peps;
		foreach my $pep(keys %fromPeptides){
			if (exists $peptideInGff{$pep}){
				$identifiedPeptideCount++ ;#having identified peptide support
				push (@peps,$pep);
			}
		} 
#		my $notSubstrFlag = 1;
#		for (my $j=0;$j<scalar @orfs;$j++){
#			next if ($i == $j); #the same orf
#			my $another = $orfs[$j];
#			if ($orfFrames{$orf} == $orfFrames{$another}){ # the same frame, then judge whether the substring of the other one, if so, discard the current orf
#				if (index($another,$orf)>-1){#is substring
#					$notSubstrFlag = 0;
#					last;
#				}
#			}
#		}

#		if ($notSubstrFlag == 1 && $identifiedPeptideCount > 0){
		if ($identifiedPeptideCount > 0){
			$candidates{$orfName}{'count'} = $identifiedPeptideCount ;
			@{$candidates{$orfName}{'peptides'}} = @peps;
		}
		push (@noSupport,$orfName) if ($identifiedPeptideCount == 0);
	}

	foreach my $orfName (sort {$a cmp $b} keys %candidates){
		#my $orf= $candidates[$i];
		if (exists $orfSeqs{$orfName}){#not in the ORF file used to search => decoy sequence
			my $count = $candidates{$orfName}{'count'};
			my @peps = @{$candidates{$orfName}{'peptides'}};
			@peps = sort {$a cmp $b} @peps;
			my $peptides = join(",",@peps);
			my $orfId = "${orfName}_wp";
			my $orfSeq = $orfSeqs{$orfName};
			unless (exists $orfSeqs{$orfName}){
				print "NOT found $orfName\n";
			}
			if (exists $totalORFs{$orfSeq}){
				$totalORFs{$orfSeq}.=";$orfId";
			}else{
				$totalORFs{$orfSeq} = ">$orfId";
			}
			print TSV "$orfId\tIdentified peptides in transcript\t$orfSeq\t$transcript_seq\t$count\t$peptides\n";
		}
	}
	
	for (my $i=0;$i<scalar @noSupport;$i++){
		my $orf = $noSupport[$i];
		if (exists $orfSeqs{$orf}){#not in the ORF file used to search => decoy sequence
			my $orfId = "${orf}_np";
			my $orfSeq = $orfSeqs{$orf};
			if (exists $totalORFs{$orfSeq}){
				$totalORFs{$orfSeq}.=";$orfId";
			}else{
				$totalORFs{$orfSeq} = ">$orfId";
			}
			print TSV "$orfId\tNo identified peptides\t$orfSeq\t$transcript_seq\t0\t\n";
		}
	}
}

sub usage(){
	print "Usage: perl pit.pl <sam file> <identification file in the tsv format> <matching pattern> <fasta file> <max fold change>\n\n";
	print "The script uses the given pattern to link the identified peptides in the identification file with the transcripts which have been mapped to the reference genomes";
	print "calculates the exact location for the identified peptides and outputs the ORF and GFF3 files. The latter can be visualized in IGV.\n";
	print "The sam file provides the reference=genome-mapping information\n";
	print "The identification file can be converted from mzIdentML or the sub-file extracted from a MaxQuant result file\n";
	print "The pattern is the regular expression pattern which can describe the transcript id in the sam file\n";
	print "The max fold change is an integer, which is used to cap the quantitation fold change\n";
	exit;
}

sub readFasta(){
	my $in = $_[0];
	open IN, "$in";
	my $header;
	my $seq = "";
	while(my $line=<IN>){
		chomp($line);
		if ($line=~/^>/){
			if (length $seq > 0){
				&process($header,$seq);
			}
			$header = substr($line,1);
			$seq = "";
		}else{
			$seq.=$line;
		}
	}
	&process($header,$seq);
}

sub process(){
	my ($header, $seq) = @_;
	$header =~s/,/;/g;
	#$header = substr($header,1) if ($header=~/^>/);
	my @header = split(";", $header);
	foreach my $header(@header){
		$seqs{$header} = $seq;
	}
}
