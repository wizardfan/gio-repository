**Name:** mzIdLib:combineSearchEngines

**Description:**
Using mzIdentML-Lib to combine mzIdentML result files from different search engines

**Input files:**
* First Input mzIdentML file in mzid format
* Second Input mzIdentML file in mzid format

**Parameters:**
* CV term for FDR calculation in the first mzIdentML file
* CV term for FDR calculation in the second mzIdentML file
* Conditional element: Input name: third
  * 1
  * 0

* Input name: decoyRegex
* Input name: decoyValue

**Outputs:**
* output in mzid format

**Details:**

	Using mzidLib (https://code.google.com/p/mzidentml-lib/) to combine mzIdentML files from no more than three search engines from the same spectral file into single mzIdentmL file for further processing. 
    
	NOTE: This tool internally calls FalseDiscoveryRate in the first (individual search engines) and second pass analysis (combinations of search engines identifying the same PSM). The algorithm REQUIRES a concatenated target:decoy search and will fail if it doesn’t detect a suitable amount of decoys. This also means that the search with individual each search engine needs to export sufficiently weak IDs that there are lots of decoys. 	
	
