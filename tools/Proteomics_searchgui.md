**Name:** Peptide spectrum matching

**Description:**

		Using SearchGUI to perform MS/MS search via X!Tandem, OMSSA and MS-GF+
	

**Input files:**
* Input Peak Lists (mgf) in mgf format: Select appropriate MGF dataset from history

**Parameters:**
* Conditional element: Input name: database
  * built_in
  * upload

* Percursor Ion Tolerance: Provide error value for precursor ion, based on instrument used. 10 ppm recommended for Orbitrap instrument
* Precursor Ion Tolerance Units: Select based on instrument used, as different machines provide different quality of spectra. ppm is a standard for most precursor ions
* Enzyme: Which enzyme was used for protein digest in experiment? In most cases, trypsin is used
* Maximum Missed Cleavages: Allow peptides to contain up to this many missed enzyme cleavage sites. 2 is the recommended value
* Fixed Modifications: Occurs in known places on peptide sequence. Hold the appropriate key while clicking to select multiple items
* Variable Modifications: Can occur anywhere on the peptide sequence; adds additional error to search score. Hold the appropriate key while clicking to select multiple items
* Minimum Charge: Lowest searched charge value for fragment ions
* Maximum Charge: Highest searched charge value for fragment ions
* Run OMSSA
* Run X!Tandem
* Run MS-GF+
**Outputs:**
* output in html format
* omssa_result in mzid format
* tandem_result in mzid format
* msgf_result in mzid format

**Details:**

**What it does**

Runs multiple search engines (X!Tandem, OMSSA and MS-GF+) on any number of MGF peak lists using the SearchGUI application. All result files are automatically converted to the PSI standard format mzIdentML

	
