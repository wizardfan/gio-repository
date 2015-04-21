#!/usr/bin/perl -w
use strict;
my $inputSize = (scalar @ARGV)-5;
print "input size $inputSize\n";
my $type = $ARGV[$inputSize+0];
my $output = $ARGV[$inputSize+1];
my $outputType = $ARGV[$inputSize+2];
my $id = $ARGV[$inputSize+3];
my $path = $ARGV[$inputSize+4];

my $os = lc($^O);
print "OS: $os\n";
#http://perldoc.perl.org/perlport.html#DOS-and-Derivatives
my $removeCmd = "";
if($os eq "mswin32" || $os eq "cygwin" || $os eq "dos" || $os eq "os2"){
	my $tmpFolder = "C:\\lwr_staging\\tmp";
	if($inputSize == 1){
		system("copy $ARGV[0] $tmpFolder\\tmp_$id.$type");
		system("msconvert $tmpFolder\\tmp_$id.$type --$outputType --outfile tmp_$id.$outputType -o $tmpFolder");
		$removeCmd = "del $tmpFolder\\tmp_$id.$type" unless ($type eq $outputType);
	}else{
		my $convertCmd = "msconvert";
		$removeCmd = "del";
		for(my $i=0;$i<$inputSize;$i++){
			system("copy $ARGV[$i] $tmpFolder\\tmp_${id}_$i.$type");
			$convertCmd .= " $tmpFolder\\tmp_${id}_$i.$type";
			$removeCmd .= " $tmpFolder\\tmp_${id}_$i.$type";
		}
		$convertCmd .= " --merge --$outputType --outfile tmp_$id.$outputType -o $tmpFolder";
		system($convertCmd);
	}
	system("move $tmpFolder\\tmp_$id.$outputType $output");
	system($removeCmd) if((length $removeCmd)!=0);
}else{#linux
	if($inputSize == 1){
		system("cp $ARGV[0] /$path/tmp_$id.$type");
		system("/$path/../../../gio_applications/proteowizard/msconvert /$path/tmp_$id.$type --$outputType --outfile tmp_$id.$outputType -o $path");
		$removeCmd = "rm /$path/tmp_$id.$type" unless ($type eq $outputType);
	}else{
		my $convertCmd = "/$path/../../../gio_applications/proteowizard/msconvert";
		$removeCmd = "rm";
		for(my $i=0;$i<$inputSize;$i++){
#			print ("cp $ARGV[$i] /$path/tmp_${id}_$i.$type\n");
			system("cp $ARGV[$i] /$path/tmp_${id}_$i.$type");
			$convertCmd .= " /$path/tmp_${id}_$i.$type";
			$removeCmd .= " /$path/tmp_${id}_$i.$type";
		}
		$convertCmd .= " --merge --$outputType --outfile tmp_$id.$outputType -o $path";
#		print "convert command: $convertCmd\n";
		system($convertCmd);
	}
	system("mv /$path/tmp_$id.$outputType $output");
#	print("mv /$path/tmp_$id.$outputType $output\n");
#	print "remove command: $removeCmd\n";
	system($removeCmd) if((length $removeCmd)!=0);
}

#print "Input file: $input\n";
#print "Selected type: $type\n";
#print "Output file: $output\n";
#print "Output path: $path\n";

