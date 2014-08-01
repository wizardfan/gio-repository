use strict;
my $alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
my $lenAlpha = length $alphabet;
my $numArg = scalar @ARGV;
&usage() if ($numArg < 2);
my $type = $ARGV[0];

for (my $i=1;$i<$numArg;$i++){
	open IN, "$ARGV[$i]" or die "Can not find the specified fasta file: $ARGV[$i]\n";
	my $prefix = "";
	if ($type == 1){
		$prefix = "Dataset_${i}_";
	}elsif($type == 2){
		my $letter = &num2letter($i);
		$prefix = "Dataset_${letter}_";
	}
	while (my $line = <IN>){
		if ($line=~/^>/){
			print ">$prefix$'";
		}else{
			print $line;
		}
	}
}
		
sub usage(){
	print "Usage: perl combineFastaFiles.pl <type> <fasta file1> [fasta file 2 ...]\n";
	print "Combines sequences from multiple fasta files and print out to the screeen\n\n";
	print "Type indicates the type of header manipulation, only values of 0, 1, and 2 are allowed\n";
	print "0 for no change, i.e. use the original headers in the source fasta files\n";
	print "1 for adding Dataset_NUMBER SERIAL_ prior to original headers\n";
	print "2 for adding Dataset_ALPHABET SERIAL_ prior to original headers\n";
	exit;
}

sub num2letter(){
	my $num = $_[0];
	my @letters;
	my $remainder = $num % $lenAlpha;
	my $left = ($num - $remainder)/$lenAlpha;
	$left -= 1 if ($remainder == 0);
	print "remainder $remainder\tleft $left\tletter ".substr($alphabet, $remainder-1, 1)."\n";
	unshift (@letters, substr($alphabet, $remainder-1, 1));
	while ($left > 0){
		$remainder = $left % $lenAlpha;
		$left = ($left - $remainder)/$lenAlpha;
		$left -= 1 if ($remainder == 0);
		print "remainder $remainder\tleft $left\tletter ".substr($alphabet, $remainder-1, 1)."\n";
		unshift (@letters, substr($alphabet, $remainder-1, 1));
	}
	my $result = join ("",@letters);
	return $result;
}