# Defines background class for intercalc
# Interferents for given peptides are determined by interograting this class
# using the interference method.
# Attributes are massaccuary and peakwidth.

class Background:
  
  # __init__ initialises newly created background objects by loading background data
  def __init__(self, backgroundfile, massaccuracy, peakwidth, verbose):
    # copy parameter values to object attributes
    self.massaccuracy = massaccuracy
    self.peakwidth = peakwidth
    # load background peptides into a list
    import csv
    self.peplist = list(csv.reader(open(backgroundfile),dialect='excel-tab'))
    # remove header row
    del self.peplist[0]
    if verbose:
      print "\nBackground object created from", len(self.peplist), "peptides."

  # guassian in a private function for approximating peptide peak shapes
  def __gaussian(self, targetH, x, variance2):
    import math
    return (1/math.sqrt(2*variance2*math.pi))*math.exp(-((targetH-x)**2)/(2*variance2))

  # interference method returns total interference information for a given parameter set
  def interference(self, mass, targetz, h, z1pc, z2pc, z3pc, verbose):
    from constants import *
    # calculate mass boundaries from the parameters
    
    # correct mass for charge state
    # no need to add hydrogens to anything because all masses are one hydrogen down
    mass = mass/targetz
    minmass = mass - self.massaccuracy
    maxmass = mass + self.massaccuracy

    ip = [0,0,0,0]  # declare array to store interferent probability
    # calculate contributon from each background charge state
    for z in range(1,4):
      # create a new peptide list containing only those peptides that might interfere   
      filteredlist = [pep for pep in self.peplist if ((float(pep[MOLWEIGHT_COL])/z >= minmass) and (float(pep[MOLWEIGHT_COL])/z <= maxmass))]
      if verbose:
        print "Target has", len(filteredlist), "potentially interfering", z, "+ peptides."

      # step through each matching peptide and work out the probability of each peptide at the specified hydrophobiticy
      for pep in filteredlist:
        # number of proteins associated with each peptide found by number of separators (;) in accession list
        numproteins = 1 + pep[PROTEIN_COL].count(";")
        ip[z] += self.__gaussian(h,float(pep[HYDRO_COL]),self.peakwidth)*numproteins
      ptotal = ip[1]*z1pc + ip[2]*z2pc + ip[3]*z3pc
    return ptotal

  

