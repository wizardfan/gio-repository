**Name:** Peptide spectrum matching<br>
<b>Description:</b><br>

<blockquote>Using SearchGUI to perform MS/MS search via X!Tandem, OMSSA and MS-GF+<br>
</blockquote><blockquote><br>
<b>Input files:</b>
<ul><li>spectra   Input Peak Lists (mgf) Select appropriate MGF dataset(s) from history<br>
<b>Parameters:</b><br>
</li><li>Conditional element: database<br>
<ul><li>built_in<br>
</li><li>upload</li></ul></li></ul></blockquote>

<ul><li>precursor_ion_tol   Percursor Ion Tolerance Provide error value for precursor ion, based on instrument used. 10 ppm recommended for Orbitrap instrument<br>
</li><li>precursor_ion_tol_units   Precursor Ion Tolerance Units Select based on instrument used, as different machines provide different quality of spectra. ppm is a standard for most precursor ions<br>
</li><li>enzyme   Enzyme Which enzyme was used for protein digest in experiment? In most cases, trypsin is used<br>
</li><li>missed_cleavages   Maximum Missed Cleavages Allow peptides to contain up to this many missed enzyme cleavage sites. 2 is the recommended value<br>
</li><li>fixed_modifications   Fixed Modifications Occurs in known places on peptide sequence. Hold the appropriate key while clicking to select multiple items<br>
</li><li>variable_modifications   Variable Modifications Can occur anywhere on the peptide sequence; adds additional error to search score. Hold the appropriate key while clicking to select multiple items<br>
</li><li>min_charge   Minimum Charge Lowest searched charge value for fragment ions<br>
</li><li>max_charge   Maximum Charge Highest searched charge value for fragment ions<br>
</li><li>omssa   Run OMSSA<br>
</li><li>tandem   Run X!Tandem<br>
</li><li>msgf   Run MS-GF+<br>
<b>Outputs:</b><br>
</li><li>output with Type html<br>
<b>Details:</b><br>
What it does</li></ul>

Runs multiple search engines (X!Tandem, OMSSA and MS-GF+) on any number of MGF peak lists using the SearchGUI application. All result files are automatically converted to the PSI standard format mzIdentML<br>
<br>
<blockquote><br></blockquote>
