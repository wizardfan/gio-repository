#!/usr/bin/env python

"""
Convert mzIdentML to JSON

This script invokes mzidParser.jar java library to read mzIdentML file and generate four json files
which inclides protein, peptide,  PSM and metadata.

usage: ProViewer.py  --filename="$input" --datasetid=$__app__.security.encode_id($input.id)
"""
import optparse
import os
import subprocess


def __main__():

	#parse command-line arguments
	parser = optparse.OptionParser()
	parser.add_option( '-F', '--filename', dest='filename', help='mzIdentML filename' )
	parser.add_option( '-D', '--datasetid', dest='datasetid', help='datasetid' )
   	(options, args) = parser.parse_args()
	inputfile = options.filename
	datasetId = options.datasetid
	print os.getcwd()
	# navigate to <your galaxy directory> and append paths
	outputfile = os.path.join(os.path.abspath('../../../../..'),  "config/plugins/visualizations/protviewer/static/data/")
	tempFile = os.path.join(os.path.abspath('../../../../..'),  "config/plugins/visualizations/protviewer/static/data/", datasetId, "_protein.json")
#	libraryLocation = os.path.join(os.path.abspath('../../../../..'),  "tools/mzIdentMLToJSON/mzIdentMLExtractor.jar")
	libraryLocation = os.path.join(os.path.abspath('../../../../../../'),  "gio_applications/misc/mzIdentMLExtractor.jar")
	multithreading = "true"

	try:
		# if file not already exists
		if os.path.isfile(tempFile) == False:
			return subprocess.call(['java', '-jar',libraryLocation, inputfile, outputfile, datasetId, multithreading])
		else:
			print "Info: Data loaded from the cache!"
	except Exception as err:
		print("ERROR: Java library execution error\n: {0}".format(err))

if __name__ == "__main__":
    __main__()