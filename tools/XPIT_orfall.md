**Name:** PIT:ORFall

**Description:**
The ORF prediction tool

**Input files:**
* Input DNA file in fasta format

**Parameters:**
* the minimum length for the main ORFs in bps
* Start type
* Stop type
* Conditional element: Input name: u5orf
  * true
  * false

* Conditional element: Input name: u3orf
  * true
  * false


**Outputs:**
* output in fasta format

**Details:**

	This tool does the normal ORF prediction from the DNA sequences as well as detects the uORF which allows the user to do further analysis to see the effect uORFs bring to the protein expression level. There will be each result file for main ORFs, 5'-uORFs and 3'-uORFs.
**The brief main algorithm**
1) Translate each DNA/RNA sequence into six frames
2) For each frame, the translation was split by the stop codon into segments
3) For each segment, find the left most start codon
4) If that ORF is bigger than the minimum ORF length, report it

	
