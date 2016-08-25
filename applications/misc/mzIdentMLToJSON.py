#!/usr/bin/env python

"""
Purpose 	: Convert mzIdentML to JSON
Description : This script invokes ProExtractor.jar java library to read mzIdentML file and
			  generates four json files which inclides protein, peptide,  PSM and metadata.
Date   		: Sep 2, 2016
@author     : Suresh Hewapathirana

usage       : mzIdentMLToJSON.py  --filename="$input" --datasetid=$__app__.security.encode_id($input.id) --root=$__root_dir__
"""
import optparse
import os
import subprocess
# python 2.7
import ConfigParser

def __main__():

	#parse command-line arguments
	parser = optparse.OptionParser()
	parser.add_option( '-F', '--filename', dest='filename', help='mzIdentML filename' )
	parser.add_option( '-D', '--datasetid', dest='datasetid', help='datasetid' )
	parser.add_option( '-R', '--root', dest='root', help='root directory of the galaxy instance' )
   	(options, args) = parser.parse_args()
	inputfile 		= options.filename
	datasetId 		= options.datasetid
	root 			= options.root
	print "ProViewer INFO:Root folder of the Galaxy: " + root

	# get settings from configuration settings file
	config 			= ConfigParser.ConfigParser()
	print config.read(root + '/config/proviewer_setttings.ini')
	outputfile 		= config.get('MzIdentML', 'output_dir')
	javalib 		= config.get('MzIdentML', 'javalib')
	multithreading 	= config.get('MzIdentML', 'multithreading')
	maxMemory		= config.get('MzIdentML', 'maxMemory')
	tempFile 		= outputfile + datasetId + "_protein.json"
	print "ProViewer INFO:java -jar " + javalib + " " + inputfile + " " + outputfile + " " + datasetId + " " + multithreading

	try:
		# if file not already exists
		if os.path.isfile(tempFile) == False:
			# execute ProExtractor java library as a seperate process(Command-line)
			return subprocess.call(['java', '-jar', maxMemory, javalib, inputfile, outputfile, datasetId, multithreading])
		else:
			print "ProViewer INFO: Data loaded from the cache!"
	except Exception as err:
		print("ProViewer ERROR: Java library execution error\n: {0}".format(err))

if __name__ == "__main__":
    __main__()
