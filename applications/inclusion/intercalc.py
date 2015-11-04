# LC-MS Interferent Calculator
# Developed with Python 2.7.8

# public library imports
import argparse

# local imports
from background import *
from constants import *

# define and parse command line parameters
parser = argparse.ArgumentParser()
parser.add_argument("targetfile", help="input file containing target peptides")
parser.add_argument("backgroundfile", help="input file containing background peptides")
parser.add_argument("outputfile", help="output file containing target peptides with interference information")
parser.add_argument("massaccuracy", help="mass accuracy in Daltons", type=float)
parser.add_argument("peakwidth", help="width of eluction peaks in hydrophobicity units", type=float)
parser.add_argument("targetz", help="charge state of target peptides (integer)", type=int)
parser.add_argument("z1pc", help="proportion of background peptides expected to singly charged", type=float)
parser.add_argument("z2pc", help="proportion of background peptides expected to doubly charged", type=float)
parser.add_argument("z3pc", help="proportion of background peptides expected to triply charged", type=float)
parser.add_argument("-v", "--verbose", action="store_true", help="print progress information to console")
args = parser.parse_args()

if args.verbose:
  print "\nCreating background object ..."

# create background object by reading interferent file
b = Background(args.backgroundfile, args.massaccuracy, args.peakwidth, args.verbose)

# open new file (to write results to)
outfile = open(args.outputfile, "w")  # output always called intercalc.tsv

# open target file (read only)
infile = open(args.targetfile, "r")

# append interferent probablity column heading
outfile.write(infile.readline().rstrip()+"\tInterferent score\n")
if args.verbose:
  print "Annotating targets with interference data "

# step through target peptides one by one and append calcualted interferent probability
for line in infile:
  # extract mass and hydrophobicity from line (could there be a one line way to do this?)
  splitline = line.split("\t")
  mass = float(splitline[MOLWEIGHT_COL])
  h = float(splitline[HYDRO_COL])
  # ask background object for peptide-specific interfrence information
  ptotal = b.interference(mass, args.targetz, h, args.z1pc, args.z2pc, args.z3pc, args.verbose)
  # write peptide line with appended ptotal to new file
  outfile.write(line.rstrip() + "\t" + str(ptotal) + "\n")

infile.close()
outfile.close()