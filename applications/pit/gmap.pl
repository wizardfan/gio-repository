#!/usr/bin/perl -w
use strict;
#parameter length check
my $lenARGV = scalar @ARGV;
if($lenARGV<4){
	&usage();
	exit 1;
}

my $input = $ARGV[0];
my $output = $ARGV[1];
my $species = $ARGV[2];
my $path = $ARGV[3];
my $appPath = "$path/../gio_applications";
open IN, "$appPath/coreSetting.conf";
my $core="";
while (my $line=<IN>){
	next if($line=~/^#/);
	chomp ($line);
	my ($program,$number) = split("\t",$line);
	if($program eq "gmap") {
		$core = "-t $number";
		last;	
	}
}
system("$appPath/pit/gmap -D $path/tool-data/data -d $species $core -f samse $input > $output 2> /dev/null");

sub usage(){
	print "Usage: perl gmap.pl <input DNA/RNA file> <output file> <species data name> <galaxy root path>\n";
	print "Example: perl gmap.pl in out hg19 /home/galaxy/galaxy-dist\n";
}
