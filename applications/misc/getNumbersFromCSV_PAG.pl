use strict;
use Text::CSV;

my $numArg = scalar @ARGV;
unless ($numArg==1){
	print "Error: Wrong number of parameters\n";
	&usage();
}

my $file = $ARGV[0];

#at the moment, the hosts are known, limited to a small number of hosts, no cross species considered
my %knownHosts;
$knownHosts{'human'}=1;
$knownHosts{'pteal'}=1;
$knownHosts{'aedae'}=1;

die "Could not find the file $file\n" unless (-e $file);
#the parse is based on r541 07 Oct 2014 https://github.com/fghali/mzidlib/blob/master/src/main/java/uk/ac/liv/mzidlib/converters/MzIdentMLToCSV.java
#new based on export PAG option
#line 297 
#header consists of pagHeader, pScoreHeader, spectrumHeader + psmHeader + scoreHeader, endPsmHeader
#which is pagHeader+pScoreHeader+all PSM option headers
#line 47 pagHeader = "PAG ID" + sep + "PAG score" + sep + "protein accession" + sep + "Pass Threshold (Protein)" + sep + "description" + sep + "group membership" + sep;
#line 50, 51 pScoreHeader and scoreHeader are determined after reading in the file
#so location of psmHeader can only be determined by search the header
my $csv = Text::CSV->new ({
	binary    => 1, # Allow special character. Always set this
	auto_diag => 1, # Report irregularities immediately
});

open my $fh, "<", $file or die "$file: $!";
my $headerRef = $csv->getline($fh);
my @headers = @$headerRef;
my $idx = 0;
my $found = 0;
for($idx = 0; $idx<scalar @headers;$idx++){
	if ($headers[$idx] eq "Spectrum ID"){
		$found = 1;
		last;
	}
}
die "Not a CSV file exported using PAG option\n" unless ($headers[0] eq "PAG ID");
die "Could not locate the position of Spectrum ID in the header\n" if($found == 0);

#my %data;
my %pdhData;
my %sigs;
#my %proteinPAGmapping;
my %pdhPAGmapping;
while (my $row = $csv->getline ($fh)) {
	my @elmts = @$row;
#line 49 the passThreshold is 3rd, which is offset 5 from spectrum ID psmHeader = "PSM_ID" + sep + "rank" + sep + "Pass Threshold" + sep + "Calc m/z" + sep + "Exp m/z" + sep + "Charge" + sep + "Sequence" + sep + "Modifications"
#line 211 header consists of spectrumHeader psmHeader scoreHeader and endPsmHeader
#line 48 spectrumHeader = "Raw data location" + sep + "Spectrum ID" + sep + "Spectrum Title" + sep + "Retention Time (s)" + sep;
#line 49 the needed sequence and passThreshold are 7th (offset 9) and 3rd (offset 5)  psmHeader = "PSM_ID" + sep + "rank" + sep + "Pass Threshold" + sep + "Calc m/z" + sep + "Exp m/z" + sep + "Charge" + sep + "Sequence" + sep + "Modifications"
#protein in the endPsmHeader line 54 sep + "proteinacc_start_stop_pre_post_;" + sep + "Is decoy";
	my $passThreshold =  lc($elmts[$idx+5]);
	next unless ($passThreshold eq "true");	#must pass threshold
	my $decoy = lc($elmts[-1]);
	next unless ($decoy eq "false");#not deal with decoy
	my $pag = $elmts[0];
	my $pdh = $elmts[2];
	$pdhPAGmapping{$pdh} = $pag;
	my $peptide = $elmts[$idx+9]; 
		
	#line 490-506, wrapped with "\"", separated by ";" if multiple proteins. Each protein is accession_start_end_pre_post, be aware _ may exist in protein accession
#	my $protein = $elmts[-2]; #last second
#	print "<$pag>\t<$elmts[$idx]>\t<$peptide>\t<$protein>\n";
#	my @tmp = split(";",$protein);
#	foreach my $tmp(@tmp){
#		my @aa = split("_",$tmp);
#		splice (@aa,-4,4); #remove the last four elements from the array, i.e. remove _start_end_pre_post to only keep accession
#		my $acc = join("_",@aa);
#		my $species = lc($aa[-1]);#for uniprot protein, this will be the species
#		if ($aa[1] eq "sig" && $aa[-2] eq "total"){ #signature
#			$species = $acc;#for signature protein, use the whole protein name
#			$sigs{$species}=1;
#			$sigs{$species}{'total'}=$aa[-1];
#			$sigs{$species}{'type'}=$aa[0];
#		} 
#		$data{$species}{'peptide'}{$peptide}++;
#		$data{$species}{'protein'}{$acc}{$peptide}++;
#		$data{$species}{'PAG'}{$pag}=1;
#		$proteinPAGmapping{$acc}{$pag}=1;
#	}

	my $pdhSpecies;
	my @abc = split("_",$pdh);
	if(scalar @abc > 2){
		$pdhSpecies = $pdh;
		$sigs{$pdhSpecies}=1;
	}else{
		$pdhSpecies = lc($abc[1]);
	}
	$pdhData{$pdhSpecies}{'peptide'}{$peptide}=1;
	$pdhData{$pdhSpecies}{'protein'}{$pdh}{$peptide}=1;
	$pdhData{$pdhSpecies}{'PAG'}{$pag}=1;
}

#my %message; #the output messages keys are species
#my %ordered; #the species are ordered by the number of proteins and peptides
my %pdhMessage; #the output messages keys are species
my %pdhOrdered; #the species are ordered by the number of proteins and peptides
#my %humanFilteredProtein;

my $isSig = 0; #the flag indicating whether there is signature in the data
print "Host\tFiltered PAG\tFiltered Protein\tFiltered Peptide\tOriginal PAG\tOriginal Protein\tOriginal Peptide\n";
foreach my $species(keys %pdhData){
#	my %peptides = %{$data{$species}{'peptide'}};
#	my %proteins = %{$data{$species}{'protein'}};
#	my %pags = %{$data{$species}{'PAG'}};
#	my $numPep = scalar keys %peptides;
#	my $numPro = scalar keys %proteins;
#	my $numPag = scalar keys %pags;
#	print "In species $species there are $numPep peptides and $numPro proteins without filtering\n";
	my %pdhPeptides = %{$pdhData{$species}{'peptide'}};
	my %pdhProteins = %{$pdhData{$species}{'protein'}};
	my %pdhPags = %{$pdhData{$species}{'PAG'}};
	my $numPdhPep = scalar keys %pdhPeptides;
	my $numPdhPro = scalar keys %pdhProteins;
	my $numPdhPag = scalar keys %pdhPags;

#	my %filterPeptides;
#	my %filterProteins;
#	my %filterPAGs;
#	foreach my $protein(keys %proteins){
#		my %supportPeptides = %{$proteins{$protein}};
#		my @supportPeptides = keys %supportPeptides;
#		my $numOfSupportPeptides = scalar @supportPeptides;
#		my $totalPeptides;
#		my $flag = 0; #indicating whether the protein has peptide support
#		if ($protein=~/_total_(\d+)/){
#			$totalPeptides = $1;
#			my $coverage = $numOfSupportPeptides/$totalPeptides;
#			$flag = 1 if($coverage>0.1);
#		}else{#for non-signature proteins
#			$flag = 1  if ($numOfSupportPeptides > 1);
#		}
#		if($flag == 1){
#			foreach my $pep(@supportPeptides){
#				$filterPeptides{$pep}++;
#			}
#			$filterProteins{$protein}=1;
#			my %pags = %{$proteinPAGmapping{$protein}};
#			foreach my $pag(keys %pags){
#				$filterPAGs{$pag}=1;
#			}
#		}
#	}

	my %filterPdhPeptides;
	my %filterPdhProteins;
	my %filterPdhPAGs;
	foreach my $protein(keys %pdhProteins){
		my %supportPeptides = %{$pdhProteins{$protein}};
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
				$filterPdhPeptides{$pep}++;
			}
			$filterPdhProteins{$protein}=1;
			my $pag = $pdhPAGmapping{$protein};
			$filterPdhPAGs{$pag}=1;
		}
	}

#	%humanFilteredProtein = %filterPdhProteins if ($species eq "human");
#	my $numFilterPeptide = scalar keys %filterPeptides;
#	my $numFilterProtein = scalar keys %filterProteins;
#	my $numFilterPAG = scalar keys %filterPAGs;
	my $numFilterPdhPeptide = scalar keys %filterPdhPeptides;
	my $numFilterPdhProtein = scalar keys %filterPdhProteins;
	my $numFilterPdhPAG = scalar keys %filterPdhPAGs;
	if (exists $knownHosts{$species}){
#		print "PSM:\t";
#		print "$species\t$numFilterPAG\t$numFilterProtein\t$numFilterPeptide\t$numPag\t$numPro\t$numPep\n";
#		print "PDH:\t";
		print "$species\t$numFilterPdhPAG\t$numFilterPdhProtein\t$numFilterPdhPeptide\t$numPdhPag\t$numPdhPro\t$numPdhPep\n";
		next;
	}
#	next if ($numFilterProtein==0); #no protein left for that species
#	unless ($numFilterProtein==0){ #no protein left for that species
#		if(exists $sigs{$species}){
#			$isSig = 1;
#			$message{$species}="PSM\t$species\t$numFilterPeptide";
#		}else{
#			$message{$species}="PSM\t$species\t$numFilterPAG\t$numFilterProtein\t$numFilterPeptide\t$numPag\t$numPro\t$numPep";
#		}

#		push(@{$ordered{$numFilterPAG}{$numFilterPeptide}},$species);
#	}

	unless ($numFilterPdhProtein==0){ #no protein left for that species
		if(exists $sigs{$species}){
			$isSig = 1;
			$pdhMessage{$species}="$species\t$numFilterPdhPeptide";
		}else{
			$pdhMessage{$species}="$species\t$numFilterPdhPAG\t$numFilterPdhProtein\t$numFilterPdhPeptide\t$numPdhPag\t$numPdhPro\t$numPdhPep";
		}

		push(@{$pdhOrdered{$numFilterPdhPAG}{$numFilterPdhPeptide}},$species);
	}
}

if ($isSig == 1){
	print "\nSignature\tObserved peptides\n";
}else{
	print "\nSpecies\tFiltered PAG\tFiltered Protein\tFiltered Peptide\tOriginal PAG\tOriginal Protein\tOriginal Peptide\n";
}
#my @ordered = sort {$b<=>$a} keys %ordered;
#my $max = $ordered[0];
#foreach my $numProtein(@ordered){
#	my $ratio = $numProtein/$max;
#	last if ($numProtein < 5 && $ratio < 0.1);#discard the not-to-significant entries
#	my %tmp = %{$ordered{$numProtein}};
#	foreach my $numPeptide(sort {$b<=>$a} keys %tmp){
#		my @arr = @{$tmp{$numPeptide}};
#		foreach my $species(@arr){
#			print "$message{$species}\n";
#		}
#	}
#}

my @ordered = sort {$b<=>$a} keys %pdhOrdered;
my $max = $ordered[0];
foreach my $numProtein(@ordered){
	my $ratio = $numProtein/$max;
	last if ($numProtein < 5 && $ratio < 0.1);#discard the not-to-significant entries
	my %tmp = %{$pdhOrdered{$numProtein}};
	foreach my $numPeptide(sort {$b<=>$a} keys %tmp){
		my @arr = @{$tmp{$numPeptide}};
		foreach my $species(@arr){
			print "$pdhMessage{$species}\n";
		}
	}
}

#print "\n\n";
#my $species="ade41";
#my @testPSMprotein = keys %{$data{$species}{'protein'}};
#print "@testPSMprotein\n";
#my @testPDHprotein = keys %humanFilteredProtein;
#foreach my $pro(@testPDHprotein){
#	print "$pro\t$pdhPAGmapping{$pro}\n";
#}

sub usage(){
	print "Usage: perl getNumbersFromCSV_PAG.pl <PAG list result CSV file>\n";
	print "The script is to get number of identified peptides, proteins and protein group for each species in the CSV result file(s)\n"; 
	print "and predict what is the host and what are possible infecting viruses according to the number of detected proteins/protein groups\n";
	print "The input CSV file is generated by mzidlib converter with the option of exporting PAG.\n";
	print "Note: the database used in the MS search engine must be either Uniprot compatiable or Proviral signatures or the combination of them\n";
	exit;
}