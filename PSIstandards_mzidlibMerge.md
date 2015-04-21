**Name:** mzIdLib:Merge<br>
<b>Description:</b><br>
Using mzIdentML-Lib to combine mzIdentML result files from different search engines<br>
<b>Input files:</b>
<ul><li>input1   First Input mzIdentML file<br>
</li><li>input2   Second Input mzIdentML file<br>
<b>Parameters:</b><br>
</li><li>cv1   CV term for FDR calculation in the first mzIdentML file<br>
</li><li>cv2   CV term for FDR calculation in the second mzIdentML file<br>
</li><li>Conditional element: third<br>
<ul><li>1<br>
</li><li>0</li></ul></li></ul>

<ul><li>decoyRegex<br>
</li><li>decoyValue<br>
<b>Outputs:</b><br>
</li><li>output with Type mzid<br>
<b>Details:</b><br>
</li></ul><blockquote>Using mzidLib (<a href='https://code.google.com/p/mzidentml-lib/'>https://code.google.com/p/mzidentml-lib/</a>) to combine mzIdentML files from no more than three search engines from the same spectral file into single mzIdentmL file for further processing.<br>
<blockquote>NOTE: This tool internally calls FalseDiscoveryRate in the first (individual search engines) and second pass analysis (combinations of search engines identifying the same PSM). The algorithm REQUIRES a concatenated target:decoy search and will fail if it doesn�t detect a suitable amount of decoys. This also means that the search with individual each search engine needs to export sufficiently weak IDs that there are lots of decoys.<br>
</blockquote><br></blockquote>
