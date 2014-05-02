#!/usr/bin/perl -w
use strict;

my $len = scalar @ARGV;
die "usage : perl show.pl <input file 1> [input file 2] ... <output file>" if ($len < 2);
open (OUT, ">$ARGV[$len-1]");

for(my $i=0;$i<=$len-2;$i++){
	open (IN, "<$ARGV[$i]");
#	print OUT "$ARGV[$i]\n";
	while (my $line = <IN>) {
            print OUT $line;
        }
	close( IN );
	print OUT "\n";
}
close( OUT );
