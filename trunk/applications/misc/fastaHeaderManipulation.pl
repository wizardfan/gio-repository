use strict;

#&debug();
sub debug(){
	my $aa = ">fake sp|P12821|ACE_HUMAN;sp|P12821-3|ACE_HUMAN";
	$aa = ">sp|P04058-2|ACES_TORCA Isoform T of Acetylcholinesterase OS=Torpedo californica GN=ache";
	$aa = ">gi|178344|gb|AAA98797.1| albumin [Homo sapiens]";
	$aa = ">IPI:IPI00000005.1|SWISS-PROT:P01111|TREMBL:Q5U091|ENSEMBL:ENSP00000358548|REFSEQ:NP_002515|VEGA:OTTHUMP00000013879 Tax_Id=9606 Gene_Symbol=NRAS GTPase NRas";
	$aa = ">comp2864_c0_seq3_ORF2_Frame_1_400-1584,comp2864_c0_seq1_ORF8_Frame_1_3784-4968";

	#my $bb = "\\|([OPQ][0-9][A-Z0-9]{3}[0-9]\|[A-NR-Z][0-9]([A-Z][A-Z0-9]{2}[0-9]){1,2})\\|";
	my $bb = qr/IPI:([^\| .]*)/; #uniprot
	print "$bb\n";

	my $cc;
	if($aa=~/$bb/){
		print "match $1\n";
		$cc .= "$1;";
		$aa = $';
		print "$aa\n";
	}
	$cc = substr($cc,0,-1);
	print "$cc\n";
	exit;
}

#predefined regular expression
my %re;
$re{1} = ">(.*)"; #everything after >
$re{2} = qr/>([^\s]*)/; #up to first white space
$re{3} = qr/(gi\|[0-9]*)/; #NCBI accession
$re{4} = qr/\|([OPQ][0-9][A-Z0-9]{3}[0-9](-\d)?)\|/; #Uniprot
$re{5} = qr/>([^\|]*)/; #up to first \ or |
$re{6} = qr/IPI:([^\| .]*)/; #IPI accession

my $argNum = scalar @ARGV;
my $file = $ARGV[0];
my $re;
my $map;

if($ARGV[1] == 0){
	unless ($argNum == 3 || $argNum == 4){
		print "Wrong number (expected as 3) of arguments for user-defined option\n";
		&usage();
	}
	$re = qr/($ARGV[2])/;
}elsif($ARGV[1] == -1){
	if ($argNum != 4){
		print "Wrong number (expected as 4) of arguments for change option\n";
		&usage();
	}
	$re = $ARGV[2];
	$map = $ARGV[3];
}else{
	unless ($argNum == 2 || $argNum == 3){
		print "Wrong number (expected as 2) of arguments for pre-defined option\n";
		&usage();
	}
	if(exists $re{$ARGV[1]}){
		$re = $re{$ARGV[1]};
	}else{
		print "Unrecognized regular expression index\n";
		&usage();
	}
} 
#print "$re\n";
#exit;

open IN, "$file";
my @mapping;
my $serial = 0;
while (my $line=<IN>){
	chomp $line;
	if ($line=~/^>/){
		my $newHeader;
		$serial++;
		if($ARGV[1] == -1){
			$newHeader = "$re"."_"."$serial";
			my $tmp = ">$newHeader\t$line";
			push (@mapping, $tmp);
		}else{
			my $match = $line;
			while($match=~/$re/){
				$newHeader .= "$1;";
				$match = $';
			}
			$newHeader = substr($newHeader,0,-1);
		}
		print ">$newHeader\n";
	}else{
		print "$line\n";
	}
}

if($ARGV[1] == -1){
	open OUT, ">$map";
	print OUT "New Header\tOriginal Header\n";
	foreach my $mapping(@mapping){
		print OUT "$mapping\n";
	}
	close OUT;
}
		
sub usage(){
	print "Usage: perl fastaheaderManipulation.pl <fasta file> <reg exp index> [reg exp|prefix] [mapping file]\n\n";
	print "fasta file is the file you want to change the header\n\n";
	print "regular expression index:\n1 for everything after > i.e. no change\n";
	print "2 for up to first white space\n3 for NCBI gi accession\n4 for Uniprot accession e.g. P01024\n";
	print "5 for up to first \\ or |\n6 for IPI accession\n";
	print "0 for user-defined regular expression which is expected as the third parameter\n";
	print "-1 for directly replace the original header with the artificial header in the format of prefix_serial\n\n";
	print "mapping file is the tab-separated file to store the mapping between the original header and the generated header\n";
	exit;
}