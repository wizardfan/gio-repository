#!/usr/bin/perl -w
use strict;

my $input = $ARGV[0];
my $type = $ARGV[1];
my $output = $ARGV[2];
my $id = $ARGV[3];
my $path = $ARGV[4];

my $os = lc($^O);
print "OS: $os\n";
#http://perldoc.perl.org/perlport.html#DOS-and-Derivatives
if($os eq "mswin32" || $os eq "cygwin" || $os eq "dos" || $os eq "os2"){
#	$deleteCmd = "del";
	my $tmpFolder = "C:\\lwr_staging\\tmp";
	
#	print ("copy $input $tmpFolder\\tmp_$id.$type\n");
	system("copy $input $tmpFolder\\tmp_$id.$type");
#	print ("msconvert $tmpFolder\\tmp_$id.$type --outfile tmp_$id.mzML -o $tmpFolder\n");
	system("msconvert $tmpFolder\\tmp_$id.$type --outfile tmp_$id.mzML -o $tmpFolder");
#	print ("move $tmpFolder\\tmp_$id.mzML $output\n");
	system("move $tmpFolder\\tmp_$id.mzML $output");
#	print ("del $tmpFolder\\tmp_$id.$type\n");
	system("del $tmpFolder\\tmp_$id.$type");
}else{
	system("cp $input /$path/tmp_$id.$type");
	system("/$path/../../../gio_applications/proteowizard/msconvert /$path/tmp_$id.$type --outfile tmp_$id.mzML -o $path");
	system("mv /$path/tmp_$id.mzML $output");
	system("rm /$path/tmp_$id.$type");
}

#print "Input file: $input\n";
#print "Selected type: $type\n";
#print "Output file: $output\n";
#print "Output path: $path\n";

