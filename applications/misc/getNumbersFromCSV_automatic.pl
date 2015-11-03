use strict;
my $numArg = scalar @ARGV;
unless ($numArg==1){
	print "Error: Wrong number of parameters\n";
	&usage();
}

my $file = $ARGV[0];
my %data;
my %sigs;
#at the moment, the hosts are known, limited to a small number of hosts, no cross species considered
my %knownHosts;
$knownHosts{'human'}=1;
$knownHosts{'pteal'}=1;
$knownHosts{'aedae'}=1;

die "Could not find the file $file\n" unless (-e $file);
#the parse is based on r541 07 Oct 2014 https://code.google.com/p/mzidentml-lib/source/browse/trunk/src/main/java/uk/ac/liv/mzidlib/converters/MzIdentMLToCSV.java
#line 209 if(exportOption.equals("exportPSMs"))
#line 211 header consists of spectrumHeader psmHeader scoreHeader and endPsmHeader
#line 48 offset 4 spectrumHeader = "Raw data location" + sep + "Spectrum ID" + sep + "Spectrum Title" + sep + "Retention Time (s)" + sep;
#line 49 the needed sequence and passThreshold are 7th (total 11) and 3rd (total 7) psmHeader = "PSM_ID" + sep + "rank" + sep + "Pass Threshold" + sep + "Calc m/z" + sep + "Exp m/z" + sep + "Charge" + sep + "Sequence" + sep + "Modifications"
#protein in the endPsmHeader line 54 sep + "proteinacc_start_stop_pre_post_;" + sep + "Is decoy";
open IN, "$file";
<IN>;#remove the header
while (my $line=<IN>){
	chomp $line;
	my @elmts = split(",",$line);
	my $passThreshold =  $elmts[6];
	next unless ($passThreshold eq "true");	#must pass threshold
	my $decoy = lc($elmts[-1]);
	next unless ($decoy eq "false");#not deal with decoy

	my $peptide = $elmts[10]; #11th element # line 439, wrapped by "\""
	$peptide = substr($peptide, 1, (length $peptide)-2); # substr(str, start, length) so last parameter is -2 removing two \"
		
	#line 490-506, wrapped with "\"", separated by ";" if multiple proteins. Each protein is accession_start_end_pre_post, be aware _ may exist in protein accession
	my $protein = $elmts[-2]; #last second
	$protein = substr($protein, 1, (length $protein)-2); # substr(str, start, length) so last parameter is -2 removing two \"
	my @tmp = split(";",$protein);
	foreach my $tmp(@tmp){
		my @aa = split("_",$tmp);
		splice (@aa,-4,4); #remove the last four elements from the array, i.e. remove _start_end_pre_post to only keep accession
		my $acc = join("_",@aa);
		my $species = lc($aa[-1]);#for uniprot protein, this will be the species
		if ($aa[1] eq "sig" && $aa[-2] eq "total"){ #signature
			$species = $acc;#for signature protein, use the whole protein name
			$sigs{$species}{'total'}=$aa[-1];
			$sigs{$species}{'type'}=$aa[0];
		} 
		$data{$species}{'peptide'}{$peptide}++;
		$data{$species}{'protein'}{$acc}{$peptide}++;
	}
}

my %message;
my %ordered;
my $isSig = 0;
print "Host\tFiltered Protein\tFilter Peptide\tOriginal Protein\tOriginal Peptide\n";
foreach my $species(keys %data){
	my %peptides = %{$data{$species}{'peptide'}};
	my %proteins = %{$data{$species}{'protein'}};
	my $numPep = scalar keys %peptides;
	my $numPro = scalar keys %proteins;
#	print "In species $species there are $numPep peptides and $numPro proteins without filtering\n";

	my %filterPeptides;
	my %filterProteins;
	foreach my $protein(keys %proteins){
		my %supportPeptides = %{$proteins{$protein}};
		my @supportPeptides = keys %supportPeptides;
		my $numOfSupportPeptides = scalar @supportPeptides;
		my $totalPeptides;
		my $flag = 0; #indicating whether the protein has peptide support
		if ($protein=~/_total_(\d+)/){
			$totalPeptides = $1;
			my $coverage = $numOfSupportPeptides/$totalPeptides;
			$flag = 1 if($coverage>0.1);
		}else{#for non-signature proteins
			$flag = 1  if ($numOfSupportPeptides > 1);
		}
		if($flag == 1){
			foreach my $pep(@supportPeptides){
				$filterPeptides{$pep}++;
			}
			$filterProteins{$protein}=1;
		}
	}

	my $numFilterPeptide = scalar keys %filterPeptides;
	my $numFilterProtein = scalar keys %filterProteins;
	if (exists $knownHosts{$species}){
#		print "Host $species has $numPep peptides and $numPro proteins origally\n";
#		print "and $numFilterPeptide peptides and $numFilterProtein proteins after removing single-peptide proteins\n\n";
		print "$species\t$numFilterProtein\t$numFilterPeptide\t$numPro\t$numPep\n";
		next;
	}
	next if ($numFilterProtein==0); #no protein left for that species
	if(exists $sigs{$species}){
		$isSig = 1;
		$message{$species}="$species\t$numFilterPeptide";
	}else{
		$message{$species}="$species\t$numFilterProtein\t$numFilterPeptide\t$numPro\t$numPep";
	}

	push(@{$ordered{$numFilterProtein}{$numFilterPeptide}},$species);
}

if ($isSig == 1){
	print "\nSignature\tObserved peptides\n";
}else{
	print "\nSpecies\tFiltered Protein\tFilter Peptide\tOriginal Protein\tOriginal Peptide\n";
}
my @ordered = sort {$b<=>$a} keys %ordered;
my $max = $ordered[0];
foreach my $numProtein(@ordered){
	my $ratio = $numProtein/$max;
	last if ($numProtein < 5 && $ratio < 0.1);
	my %tmp = %{$ordered{$numProtein}};
	foreach my $numPeptide(sort {$b<=>$a} keys %tmp){
		my @arr = @{$tmp{$numPeptide}};
		foreach my $species(@arr){
			print "$message{$species}\n";
		}
	}
}

sub usage(){
	print "Usage: perl getNumbersFromCSV_automatic.pl\n";
	print "The script is to get number of identified peptides and proteins for each species in the CSV result file and predict what is the host and what are possible infecting viruses according to the number of detected proteins\n";
	print "For signatures, the host code should always start with sig_, one signature host code can match multiple proteins";
	exit;
}