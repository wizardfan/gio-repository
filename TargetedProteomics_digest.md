**Name:** Digest<br>
<b>Description:</b><br>
Theoretically digest all protein sequences from a FASTA file by trypsin<br>
<b>Input files:</b>
<ul><li>input   Input file<br>
<b>Parameters:</b><br>
</li><li>minLength   the minimum length for the digested peptides to be included in the result file<br>
</li><li>maxLength   the maximum length for the digested peptides to be included in the result file<br>
</li><li>unique   Only keeps proteotypic peptides?<br>
<b>Outputs:</b><br>
</li><li>output with Type fasta<br>
<b>Details:</b><br>
<blockquote>This tool digests protein sequences passed to in FASTA format and outputs the results of this digest as individual entries in a new FASTA file where the entries are named <br>
<br>
<protein><br>
<br>
-pep<br>
<br>
<peptide_number><br>
<br>
.  The additional filters for peptide length and proteotypic peptides are useful for SRM (Selected Reaction Monitoring) to filter out the peptides won't be observed on a specific MS/MS instrument.<br>
</blockquote></li></ul><blockquote><br></blockquote>
