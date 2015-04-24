**Name:** emPAI analysis in X-Tracker

**Description:**
Execute emPAI quantitation method within X-Tracker

**Input files:**

**Parameters:**
* Conditional element: Input name: spectra
  * mzml
  * mgf

* Conditional element: Input name: identification
  * mzid
  * mascot

* the minimum molecular weight to be observed
* the maximum molecular weight to be observed
  * Repeat element protein database

**Outputs:**
* output in mzq format

**Details:**

	X-Tracker is a PSI-standards-compliant software framework for supporting mass spectrometry-based protein quantitation. Through an abstraction of the main steps involved in quantitation, X-Tracker should technically be able to support quantitation by means of all the current protocols, both at MS1 and/or MS2 level, and provide a flexible, platform-independent quantitation environment. More details can be found at http://www.x-tracker.info/.
	This tool demonstrates the ability of X-Tracker to do an emPAI analyses.
	
