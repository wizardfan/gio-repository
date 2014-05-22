#!/usr/bin/perl -w
use strict;

my $lenArg = scalar @ARGV;
my $output = $ARGV[0];
my $id = $ARGV[1];
my $path = $ARGV[2];
my $decoyRegex = $ARGV[3];
my $decoyValue = $ARGV[4];
my $cmd = "java -Xms1024m -jar $path/../../../gio_applications/mzidlib/mzidlib-1.6.8-javaLib.jar CombineSearchEngines ";
$cmd .= "-firstFile $ARGV[5] -firstSearchEngine s1 -firstcvTerm $ARGV[6] ";
$cmd .= "-firstbetterScoresAreLower true ";
$cmd .= "-secondFile $ARGV[7] -secondSearchEngine s2 -secondcvTerm $ARGV[8] ";
$cmd .= "-secondbetterScoresAreLower true ";
if ($lenArg > 10){
	$cmd .= "-thirdFile $ARGV[9] -thirdSearchEngine s3 -thirdcvTerm $ARGV[10] ";
	$cmd .= "-thirdbetterScoresAreLower true ";
}
$cmd .= "-decoyRatio $decoyValue -rank 3 -outputFile $path/mzidlibMerge-${id}.mzid -debugFile $path/mzidlibMerge-${id}-debug.txt -decoyRegex $decoyRegex -compress false";

#print "$cmd\n";
system($cmd);
system("mv $path/mzidlibMerge-${id}.mzid $output");
system("rm $path/mzidlibMerge-${id}-debug.txt");

#not used in the current list as all entries are lower value better match
sub determineBetterAreLower(){
	my $cv = $_[0];
	return "true";	
}
