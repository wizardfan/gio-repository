**Name:** Calculate interference

**Description:**
Tool for calculating possible background interference for a set of target peptides

**Input files:**
* Input file containing target peptides in tabular format
* Input file containing background peptides in tabular format

**Parameters:**
* mass accuracy in Daltons
* width of eluction peaks in hydrophobicity units
**Outputs:**
* output in tabular format

**Details:**


**What it does**

This tool calculates the interference between target and background peptides. All files are TSV format, where each row is a target/background peptide and columns are:

1. Peptide sequence
2. Name of protein to which sequence belongs
3. Molecular weight
4. Hydrophobicity
5. Interferent score (present in ouput file only)

The input files are expected to be the output files of Peptide MW and hydrophobicity tool which generates the exact order of the required columns.
	
