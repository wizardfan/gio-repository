**Name:** PIT:Get sequences for identified proteins

**Description:**
Get identified protein sequences

**Input files:**
* The list of identified proteins in tabular format

**Parameters:**
* Conditional element: Input name: database
  * built_in
  * upload

**Outputs:**
* output in fasta format

**Details:**

This tool extracts fasta sequences for the identified protein from the fasta file used in the MS/MS search. It becomes handy when there is no protein sequence available in the result mzIdentML file from the MS/MS search, e.g. MS-GF+ search engine. The result mzIdentML file can first processed by Extract Peptide tool to generate a list of identified peptides (first column) and their corresponding proteins (second column). The list then is used as input of this tool to get the protein sequences.
Of course, the user can manually create the list to be used with this tool as long as the list is in the tsv format with one-line header.In the PIT workflow, this tool can be used for the scenario when no reference genome is available for GMAP to map to the genome.
    
