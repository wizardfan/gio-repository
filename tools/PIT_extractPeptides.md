**Name:** Extract hits<br>
<b>Description:</b><br>
Extract peptide information from various file formats for PIT analysis<br>
<b>Input files:</b><br>
<b>Parameters:</b><br>
<ul><li>Conditional element: type_selection<br>
<ul><li>mzid<br>
</li><li>mzq<br>
</li><li>maxquant</li></ul></li></ul>

<b>Outputs:</b><br>
<ul><li>output with Type tabular<br>
<b>Details:</b><br>
<blockquote>The proteomics data can come in various formats, including but not limited to PSI standards (mzQuantML and mzIdentML) and widely-used TSV(tab-separated-value) formats which is used by MaxQuant. This tools converts the information in different formats to a fixed-header tsv which will be used in the PIT:Integrate tool. The headers are in the order of Peptide, Protein, Reverse, Contamination, Score, Quantitation and unlimited optional columns. Of course it can be used standard-alone to extract the essential information from those more-complex formats.<br>
</blockquote></li></ul><blockquote><br></blockquote>
