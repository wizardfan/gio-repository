**Name:** Sort by chromosome

**Description:**

		Sort various tabular files according to the chromosome and start coordinate
	

**Input files:**

**Parameters:**
* Conditional element: Input name: type
  * \# 0 3
  * \@ 2 3
  * \# 0 1

* Delete duplicate entries?

**Outputs:**
* output

**Details:**

This tool is designed to sort the entries in the tabular genomic file, e.g. SAM file, GFF3 file, according to the chromosome then start position. The difficulty of this is that there is no certain pattern for chromosome, which can be just numbers and letters (e.g. 12, X) or with prefix(e.g. chr1, contig_2341.1).Please bear in mind that the script is not supposed to sort the mixed type, i.e. chromosomes represented in both numbers and letters and with prefix types.
	
