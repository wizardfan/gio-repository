**Name:** PIT:Integrate

**Description:**
The tool links sam file to the peptide identification file with the defined regular expression

**Input files:**
* Input sam file in sam format
* Input peptide file in tabular format
* The protein sequence file used in the MS/MS search engine in fasta format

**Parameters:**
* Conditional element: Input name: type
  * 0
  * comp\\d+_c\\d+_seq\\d+
  * CUFF\\.\\d+\\.\\d+

* The maximum fold change to be capped
**Outputs:**
* outputGff in gff3 format
* outputFasta in fasta format
* outputSam in sam format
* outputTsv in tabular format

**Details:**
The regular expression should be able to match the first column in the sam file
