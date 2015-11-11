#!/usr/bin/perl
use strict;

my $in = $ARGV[0];
my $type = $ARGV[1];
my $job_id = $ARGV[2];
my $pregoPath = $ARGV[3];
my $out = $ARGV[4];

my $tmp_outfile = "prego_tmp_${job_id}_result.txt";
#for tsv, extract protein and peptide from input tsv, execute the tool, add result to the end of each line in original tsv
#for fasta, execute the tool, add heading
if ($type eq "fasta"){
	system ("$pregoPath/classify -f -r $tmp_outfile $in");
	#as fasta input, no original tsv file, create a new file
	open IN, "$tmp_outfile";
	open OUT, ">$out";
	print OUT "Protein\tPeptide\tPrego rank\tPrego score\n";
	<IN>;#remove the header in the tmp file
	while (my $line=<IN>){
		chomp $line;
		my ($pro,$rank,$pep,$score) = split("\t",$line);
		print OUT "$pro\t$pep\t$rank\t$score\n";
	}
	close OUT;
}else{#tsv input file
	#extract protein peptide from input tsv file and save into a new file
	my $tmp_file = "prego_tmp_${job_id}.tsv";
	my $pepPosi = 1; #second column, index 1  which is the case in the new layout
	open IN, "$in";
	open TMP,">$tmp_file";
	my $header = <IN>;
	chomp $header;
	my ($first) = split("\t",$header);
	$pepPosi = 0 if (lc($first) eq "peptide");#first column, index 0, which is the case in the old layout

	while (my $line=<IN>){
		chomp $line;
		my ($pro,$pep) = split("\t", $line);
		if ($pepPosi == 0){
			my $tmp = $pro;					
			$pro = $pep;
			$pep = $tmp;
		}
		if ($pro=~/^\S+/){
			$pro = $&;
		}
		print TMP "$pro\t$pep\n";
	}
	close TMP;

	#run the analyses and read the result
	system ("$pregoPath/classify -r $tmp_outfile $tmp_file");
	my %prego;
	open IN, "$tmp_outfile";
	<IN>;
#	print OUT "\n\nNow dealing with tmp output\n";
	while (my $line=<IN>){
		chomp $line;
		my ($pro,$rank,$pep,$score) = split("\t",$line);
#		print OUT "Protein <$pro>\tPeptide <$pep>\tRank <$rank>\tScore <$score>\n";
		$prego{$pro}{$pep}{'rank'}=$rank;
		$prego{$pro}{$pep}{'score'}=$score;
	}

	#add prego result to the input tsv file to form the new tsv file
	open IN, "$in";
	$header = <IN>;
	chomp $header;
	open OUT, ">$out";
	
	print OUT "$header\tPrego rank\tPrego score\n";
	while (my $line=<IN>){
		chomp $line;
		my ($pro,$pep) = split("\t", $line);
		if ($pepPosi == 0){
			my $tmp = $pro;					
			$pro = $pep;
			$pep = $tmp;
		}
		if ($pro=~/^\S+/){#in the middle file, the sequence header has already been dealt with, not the original one.
			$pro = $&;
		}

		my $rank = $prego{$pro}{$pep}{'rank'};
		my $score = $prego{$pro}{$pep}{'score'};
		print OUT "$line\t$rank\t$score\n";
	}
}

sub usage(){
	print "Usage: prego.pl <input file> <input format> <job id> <prego path> <output file>\n";
}
