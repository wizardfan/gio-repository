**Name:** mzIdLib:Threshold

**Description:**
Using mzIdentML-Lib to remove identification under given threshold

**Input files:**
* Input file in mzid format

**Parameters:**
* Input name: isPSMThreshold
* Conditional element: Input name: score
  * post
  * engine

* Input name: threshValue
* Input name: thresholdBetterScoresAreLower
**Outputs:**
* output in mzid format

**Details:**

	Threshold can be used with any search engine or post-processing score that a user may with to apply the threshold over. Usually this tool is used after FDR calculation and can be a precursor to ProteoGrouper.
	
