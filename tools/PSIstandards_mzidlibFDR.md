**Name:** mzIdLib:FDR

**Description:**
Using mzIdentML-Lib to calculate False Discovery Rate

**Input files:**
* Input file in mzid format

**Parameters:**
* Conditional element: Input name: fdrType
  * PSM
  * Peptide
  * ProteinGroup

* Input name: decoyRegex
* Input name: decoyValue
* Conditional element: Input name: score
  * combined
  * original

* Input name: betterScoresAreLower

**Outputs:**
* output in mzid format

**Details:**
The difference between these two levels is whether the score is assigned to the protein group already(cvParam on PAG) or it comes from the archor protein of the protein group (if no anchor protein, the first PDH will be used as group representative). This means that the user needs to know what types of scores are annotated in the file, at the group level or PDH level
