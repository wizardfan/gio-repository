#!/usr/bin/perl -w
use strict;
#open IN,"pwd|";
#while(<IN>){
#	print "path:$_\n";
#}
my $input = $ARGV[0];
my $output = $ARGV[1];
my $id = $ARGV[2];
my $path = $ARGV[3];
my $paramStr = join (" ",@ARGV);
if($paramStr=~/FalseDiscoveryRate\s(.+)Threshold\s(-isPSM.+)ProteoGrouper\s(.+)$/){
	my $java = "java -Xms1024m -jar $path/../../../gio_applications/mzidlib/mzidlib-1.6-javaLib.jar ";
	my $fdr = "$java FalseDiscoveryRate $input $path/fdr_$id.mzid $1 -verboseOutput false";
	my $threshold = "$java Threshold $path/fdr_$id.mzid $path/threshold_$id.mzid $2 -verboseOutput false";
	my $proteogroup = "$java ProteoGrouper $path/threshold_$id.mzid $output $3 -verboseOutput false";

	print "$fdr\n";
	print "$threshold\n";
	print "$proteogroup\n";
	system($fdr);
	system($threshold);
	system($proteogroup);
}

