**Name:** mzIdLib:FDR<br>
<b>Description:</b><br>
Using mzIdentML-Lib to calculate False Discovery Rate<br>
<b>Input files:</b>
<ul><li>input   Input file<br>
<b>Parameters:</b><br>
</li><li>Conditional element: fdrType<br>
<ul><li>PSM<br>
</li><li>Peptide<br>
</li><li>ProteinGroup</li></ul></li></ul>

<ul><li>decoyRegex<br>
</li><li>decoyValue<br>
</li><li>cvTerm<br>
</li><li>betterScoresAreLower<br>
<b>Outputs:</b><br>
</li><li>output with Type mzid<br>
<b>Details:</b><br>The difference between these two levels is whether the score is assigned to the protein group already(cvParam on PAG) or it comes from the archor protein of the protein group (if no anchor protein, the first PDH will be used as group representative). This means that the user needs to know what types of scores are annotated in the file, at the group level or PDH level<br></li></ul>
