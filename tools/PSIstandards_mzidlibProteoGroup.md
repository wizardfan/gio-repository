**Name:** mzIdLib:ProteoGrouper

**Description:**
Using mzIdentML-Lib to perform sequence-based protein inference

**Input files:**
* Input file in mzid format

**Parameters:**
* Input name: cvAccForSIIScore
* Input name: logTransScore
**Outputs:**
* output in mzid format

**Details:**

	ProteoGrouper performs sequence-based protein inference, based on a set of PSMs. It should be parameterized with the CV accession for the PSM score used to create a protein score. The tool also needs to know whether the score should be log transformed (true for e/p-values etc.) to create a positive protein score.
	
