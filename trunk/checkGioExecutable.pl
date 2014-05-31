use strict;
use IPC::Open2;

my $appFolder = "$ENV{HOME}/gio_applications";
if (scalar @ARGV > 0){
	my $tmpFolder = $ARGV[0];
	print "The input folder $tmpFolder does not seem right, the default value $appFolder will be used\n"
}

print "GIO application folder is $appFolder\n";
my $result;

#GMAP		pit/gmap
print "\nGMAP: $appFolder/pit/gmap\n";
$result = `$appFolder/pit/gmap 2>&1`;
my $flagGmap = 0;
$flagGmap = 1 if($result=~/Usage: gmap/);
if ($flagGmap == 0){
	print "Error: GMAP cannot be executed\n";
}else{
	print "GMAP: ok\n";
}

#blastp		pit/blastp
print "\nBLASTP: $appFolder/pit/blastp\n";
$result = `$appFolder/pit/blastp 2>&1`;
my $flagBlast = 0;
$flagBlast = 1 if($result=~/database or subject/);
if ($flagBlast == 0){
	print "Error: BLAST cannot be executed\n";
}else{
	print "BLASTP: ok\n";
}

#msconvert	proteowizard/msconvert
print "\nmsconvert: $appFolder/proteowizard/msconvert\n";
my $flagMsconvert = 0;
if(-e "$appFolder/proteowizard/msconvert"){
	$result = `$appFolder/proteowizard/msconvert 2>&1`;
	$flagMsconvert = 1 if($result=~/Usage: msconvert/);
	if ($flagMsconvert == 0){
		print "Error: msconvert cannot be executed\n";
	}else{
		print "msconvert: ok\n";
	}
}else{
	print "msconvert not found on this server, therefore LWR must be used\n";
}

#omssacl		searchgui/SearchGUI/resources/OMSSA/omssa-2.1.9.linux
print "\nOMSSA: $appFolder/searchgui/SearchGUI/resources/OMSSA/omssa-2.1.9.linux/omssacl\n";
$result = `$appFolder/searchgui/SearchGUI/resources/OMSSA/omssa-2.1.9.linux/omssacl 2>&1`;
my $flagOMSSA = 0;
$flagOMSSA = 1 if($result=~/to print detailed descriptions/);
if ($flagOMSSA == 0){
	print "Error: OMSSA cannot be executed\n";
}else{
	print "OMSSA: ok\n";
}

#makeblastdb	searchgui/SearchGUI/resources/makeblastdb/linux/linux_64|32bit/makeblastdb
print "\nmakeblastdb 64bit: $appFolder/searchgui/SearchGUI/resources/makeblastdb/linux/linux_64bit/makeblastdb\n";
$result = `$appFolder/searchgui/SearchGUI/resources/makeblastdb/linux/linux_64bit/makeblastdb 2>&1`;
my $flagMakeblastdb = 0;
$flagMakeblastdb = 1 if($result=~/create BLAST databases/);
if ($flagMakeblastdb == 1){
	print "64bit makeblastdb: ok\n";
}else{
	print "\nmakeblastdb 32bit: $appFolder/searchgui/SearchGUI/resources/makeblastdb/linux/linux_32bit/makeblastdb\n";
	$result = `$appFolder/searchgui/SearchGUI/resources/makeblastdb/linux/linux_32bit/makeblastdb 2>&1`;
	$flagMakeblastdb = 1 if($result=~/create BLAST databases/);
	if ($flagMakeblastdb == 1){
		print "32bit makeblastdb: ok\n";
	}else{
		print "Error: makeblastdb cannot be executed\n";
	}
}

#tandem		searchgui/SearchGUI/resources/XTandem/linux_32bit
#tandem		searchgui/SearchGUI/resources/XTandem/linux_64bit
print "\nXTandem 64bit: $appFolder/searchgui/SearchGUI/resources/XTandem/linux_64bit/tandem\n";

my $in;
my $out;
open2 $out, $in, "$appFolder/searchgui/SearchGUI/resources/XTandem/linux_64bit/tandem 2>&1";
print $in "\n";
$result = "";
while (<$out>){
	$result .= $_;
}
my $flagTandem = 0;
$flagTandem = 1 if($result=~/USAGE: tandem/);
if ($flagTandem == 1){
	print "64bit tandem: ok\n";
}else{
	print "\nXTandem 32bit: $appFolder/searchgui/SearchGUI/resources/XTandem/linux_32bit/tandem\n";
	open2 $out, $in, "$appFolder/searchgui/SearchGUI/resources/XTandem/linux_32bit/tandem 2>&1";
	print $in "\n";
	$result = "";
	while (<$out>){
		$result .= $_;
	}
	#$result = `$appFolder/searchgui/SearchGUI/resources/XTandem/linux_32bit/tandem 2>&1`;
	$flagTandem = 1 if($result=~/USAGE: tandem/);
	if ($flagTandem == 1){
		print "32bit tandem: ok\n";
	}else{
		print "Error: tandem (neither 64 bit nor 32 bit) cannot be executed\n";
	}
}
