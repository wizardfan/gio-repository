**Name:** PIT:Protein homology

**Description:**
Use BLAST to find protein homology and source species

**Input files:**
* The protein sequence file in fasta format

**Parameters:**
* The threshold: The cutoff value for the percentage of identity above which will be treated as a hit
  * Repeat element BLAST databases
**Outputs:**
* output in tabular format

**Details:**

	This tool BLASTs each sequence in the FASTA file against the list of selected species BLAST database(s) and determines whether the sequence comes from the species by comparing the identity percentage against the threshold. If no species is found from the given species list, the all-species BLAST database will be searched. The result tabular file has columns of protein sequence and its header, the name and identity percentage of top hit protein from each selected BLAST database and the highest identity protein and its protein description. Each row of the result table is for a protein sequence.
	
