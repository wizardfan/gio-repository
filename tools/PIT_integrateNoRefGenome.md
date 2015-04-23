**Name:** Get sequences for identified proteins<br>
<b>Description:</b><br>
Get identified protein sequences<br>
<b>Input files:</b>
<ul><li>input   The list of identified proteins<br>
<b>Parameters:</b><br>
</li><li>Conditional element: database<br>
<ul><li>built_in<br>
</li><li>upload</li></ul></li></ul>

<b>Outputs:</b><br>
<ul><li>output with Type fasta<br>
<b>Details:</b><br>
This tool extracts fasta sequences for the identified protein from the fasta file used in the MS/MS search. It becomes handy when there is no protein sequence available in the result mzIdentML file from the MS/MS search, e.g. MS-GF+ search engine. The result mzIdentML file can first processed by Extract Peptide tool to generate a list of identified peptides (first column) and their corresponding proteins (second column). The list then is used as input of this tool to get the protein sequences.<br>
Of course, the user can manually create the list to be used with this tool as long as the list is in the tsv format with one-line header.In the PIT workflow, this tool can be used for the scenario when no reference genome is available for GMAP to map to the genome.<br>
<blockquote><br></blockquote></li></ul>
