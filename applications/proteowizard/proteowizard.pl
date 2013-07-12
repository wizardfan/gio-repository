#!/usr/bin/perl -w
use strict;

my $input = $ARGV[0];
my $type = $ARGV[1];
my $output = $ARGV[2];
my $id = $ARGV[3];
my $path = $ARGV[4];

#print "Input file: $input\n";
#print "Selected type: $type\n";
#print "Output file: $output\n";
#print "Output path: $path\n";
system("cp $input /$path/tmp_$id.$type");
system("./msconvert /$path/tmp_$id.$type --outfile tmp_$id.mzML -o $path");
system("mv /$path/tmp_$id.mzML $output");
system("rm /$path/tmp_$id.$type");

