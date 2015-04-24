**Name:** Digest

**Description:**
Theoretically digest all protein sequences from a FASTA file by trypsin

**Input files:**
* Input file in fasta format

**Parameters:**
* the minimum length for the digested peptides to be included in the result file
* the maximum length for the digested peptides to be included in the result file
* Only keeps proteotypic peptides?

**Outputs:**
* output in fasta format

**Details:**

	     This tool digests protein sequences passed to in FASTA format and outputs the results of this digest as individual entries in a new FASTA file where the entries are named <protein>-pep<peptide_number>.  The additional filters for peptide length and proteotypic peptides are useful for SRM (Selected Reaction Monitoring) to filter out the peptides won't be observed on a specific MS/MS instrument.
	
