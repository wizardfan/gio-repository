**Name:** PIT:Integrate<br>
<b>Description:</b><br>
The tool links sam file from GMAP to the peptide identification file with the defined regular expression<br>
<b>Input files:</b>
<ul><li>sam   Input sam file<br>
</li><li>peptide   Input peptide file<br>
<b>Parameters:</b><br>
</li><li>pattern   Regular expression<br>
</li><li>maxFold   The maximum fold change to be capped<br>
<b>Outputs:</b><br>
</li><li>outputGff with Type gff3<br>
</li><li>outputFasta with Type fasta<br>
</li><li>outputSam with Type sam<br>
<b>Details:</b><br>
This tool is the core part of PIT technology. It combines the reference genome mapping information from the SAM file and the identified peptides and quantitation values from the TSV file by parsing the CIGAR value in the SAM file to locate the exact coordinates of coding DNA for the identified peptides. The tool generates three output files: 1) the gff3 file each row of which represents one identified peptide and related genome coordinates, quantitation, coding DNA sequence etc, 2) the SAM file which is the input SAM file plus the annotation of proteomics data in the optional column with tag pt:Z, and 3) the fasta file containing the longest ORFs associated with the identified peptide.<br>
References<br>
V.C. Evans et al.  De novo derivation of proteomes from transcriptomes for transcript and protein identification   Nature Method 2012 9:1207-1211<br>
</li></ul><blockquote><br></blockquote>
