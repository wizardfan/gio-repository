#!/usr/bin/perl
use strict;
use Cwd;

my $path = cwd();
my $in = $ARGV[0];
my $job_id = $ARGV[1];
my $mcpredPath = $ARGV[2];
my $out = $ARGV[3];
my $javaCmd = "java -Djava.library.path=. Mcpred";
my $tmp_outfile = "mcpred_tmp_${job_id}_result.txt";
print "IN $in\n";
print "OUT $out\n";

chdir($mcpredPath);

#for tsv, extract protein and peptide from input tsv and save to a temp fasta file, execute the tool, add result to the end of each line in original tsv
#for fasta, execute the tool, replace the header
#if ($type eq "fasta"){
	system ("$javaCmd $in > $tmp_outfile");
	#as fasta input, no original tsv file, create a new file
	open IN, "$tmp_outfile";
	open OUT, ">$out";
	print OUT "Protein\tPeptide\tN-term miscleavage score\tC-term miscleavage score\n";
	<IN>;#remove the header in the tmp file
	while (my $line=<IN>){
		chomp $line;
		print OUT "$line\n";
	}
	close OUT;
	system ("rm $tmp_outfile");
#}else{#tsv input file
#}

sub usage(){
	print "Usage: mcpred.pl <input fasta file> <job id> <MC:pred executable folder> <output file>\n";
}
