**Name:** Protein homology<br>
<b>Description:</b><br>
Use BLAST to find protein homology and source species<br>
<b>Input files:</b>
<ul><li>input   The protein sequence file<br>
<b>Parameters:</b><br>
</li><li>threshold   The threshold The cutoff value for the percentage of identity above which will be treated as a hit<br>
</li><li>Repeat element BLAST databases<br>
<b>Outputs:</b><br>
</li><li>output with Type tabular<br>
<b>Details:</b><br>
</li></ul><blockquote>This tool BLASTs each sequence in the FASTA file against the list of selected species BLAST database(s) and determines whether the sequence comes from the species by comparing the identity percentage against the threshold. If no species is found from the given species list, the all-species BLAST database will be searched. The result tabular file has columns of protein sequence and its header, the name and identity percentage of top hit protein from each selected BLAST database and the highest identity protein and its protein description. Each row of the result table is for a protein sequence.<br>
<br></blockquote>
