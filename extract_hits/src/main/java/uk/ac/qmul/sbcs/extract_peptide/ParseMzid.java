/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package uk.ac.qmul.sbcs.extract_peptide;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import uk.ac.ebi.jmzidml.MzIdentMLElement;
import uk.ac.ebi.jmzidml.model.mzidml.AnalysisData;
import uk.ac.ebi.jmzidml.model.mzidml.CvParam;
import uk.ac.ebi.jmzidml.model.mzidml.DBSequence;
import uk.ac.ebi.jmzidml.model.mzidml.Peptide;
import uk.ac.ebi.jmzidml.model.mzidml.PeptideEvidence;
import uk.ac.ebi.jmzidml.model.mzidml.PeptideEvidenceRef;
import uk.ac.ebi.jmzidml.model.mzidml.SpectrumIdentificationItem;
import uk.ac.ebi.jmzidml.model.mzidml.SpectrumIdentificationList;
import uk.ac.ebi.jmzidml.model.mzidml.SpectrumIdentificationResult;
import uk.ac.ebi.jmzidml.xml.io.MzIdentMLUnmarshaller;
import java.util.HashSet;
import java.util.HashMap;
import java.util.ArrayList;
import java.util.Iterator;
import javax.xml.validation.Validator;

/**
 *
 * @author Jun Fan@qmul
 */
public class ParseMzid extends Parser {

    private static final String SCORE = "Score";
    private final String MZID_XSD = "mzIdentML1.1.0.xsd";
    private HashSet<Integer> cvTerms = new HashSet<Integer>();
    private HashSet<String> existingTerms = new HashSet<String>();
    private HashMap<String, HashMap<String, String>> peptideCvTerms = new HashMap<String, HashMap<String, String>>();
    private ArrayList<String> peptides = new ArrayList<String>();
    private String fastaFile;
    private HashMap<String, String> dbs_seqs = new HashMap<String, String>();

    public ParseMzid(String input, String output, String fastaFile) {
        this.input = input;
        this.output = output;
        this.fastaFile = fastaFile;
        initialize();
    }

    @Override
    void parse() {
        try {
            Validator validator = XMLparser.getValidator(MZID_XSD);
            boolean validFlag = XMLparser.validate(validator, input);
            if (!validFlag) {
                System.out.println("The mzIdentML validation went wrong, program terminated");
                System.exit(1);
            }
            //main parse code is adapted from loadMzIdentML.java from X-Tracker
            MzIdentMLUnmarshaller unmarshaller = new MzIdentMLUnmarshaller(new File(input));
            Iterator<DBSequence> seqs = unmarshaller.unmarshalCollectionFromXpath(MzIdentMLElement.DBSequence);
            while (seqs.hasNext()) {
                DBSequence current = seqs.next();
                String seq = current.getSeq();
                if (seq != null) {
                    dbs_seqs.put(current.getId(), seq);
                }
            }
            if(dbs_seqs.isEmpty()) System.out.println("No protein sequences can be found in the given mzid file: "+input);
            BufferedWriter seqOut = new BufferedWriter(new FileWriter(fastaFile));

            AnalysisData analysisData = unmarshaller.unmarshal(MzIdentMLElement.AnalysisData);
            List<SpectrumIdentificationList> silList = analysisData.getSpectrumIdentificationList();
            for (SpectrumIdentificationList sil : silList) {
                List<SpectrumIdentificationResult> sirList = sil.getSpectrumIdentificationResult();
//          1.	For each available SpectrumIdentificationResult (SIR) corresponding to one spectrum 
                for (SpectrumIdentificationResult sir : sirList) {
//              a.	Find the raw spectral file by using the location attribute from the SpectraData via the mandatory attribute spectraDataRef
                    //need to modify the MzIdentMLElement.cgf.xml line 184 autoRefResolving to true for SIR
                    //otherwise use the statement below
                    // System.out.println(unmarshaller.getElementAttributes(sir.getSpectraDataRef(),SpectraData.class).get("location"));
//                        System.out.println(sir.getSpectraData().getLocation());
//              b.	The spectrum id is retrieved from the mandatory spectrumID attribute
//                        System.out.println(sir.getSpectrumID());
//              c.	The id is retrieved from the mandatory id attribute
//                        System.out.println(sir.getId());
//              d.	Find the top identification which passes the threshold:
//                        For each SSI under the current SIR
                    SpectrumIdentificationItem selected = null;
                    List<SpectrumIdentificationItem> siiList = sir.getSpectrumIdentificationItem();
                    for (SpectrumIdentificationItem sii : siiList) {
//                  i.	If the mandatory passThreshold attribute is false, jump to the next SSI
//                  ii.	If the mandatory rank attribute equals to 1, the top SSI is selected, break the loop;
//                         else jump to next SSI
                        if (sii.isPassThreshold() && sii.getRank() == 1) {
                            selected = sii;
                            break;
                        }
                    }//end of sii list
//              e.	If the top SSI found 
                    if (selected != null) {
                        //If the peptide_ref is available (as it is optional)
                        //change autoRefResolving to true in SII line 139
                        Peptide peptide = selected.getPeptide();
                        if (peptide != null) {
//                      a) retrieve the peptide sequence and modification(s) from the subelement PeptideSequence and Modification respectively from the referenced peptide
//                                System.out.println(peptide.getPeptideSequence());
//                                System.out.println("SIR:"+sir.getId()+" peptide: "+peptide.getId());
                            //currently using the spectral file location from the parameter file, not the getSpectraData.getLocation() assuming the 1-to-1 relationship
//                                Identification identification = new Identification(sir.getId(), sir.getSpectraData().getLocation(), sir.getSpectrumID(), selected, sir.getCvParam(), identFile); 
//                      b) for each available PeptideEvidence (PE)
                            StringBuilder sb = new StringBuilder();
                            sb.append(peptide.getPeptideSequence());
                            sb.append("\t>");
                            List<PeptideEvidenceRef> peRefList = selected.getPeptideEvidenceRef();
                            for (PeptideEvidenceRef peRef : peRefList) {
                                //autoResolving set to true in line 325 for PeptideEvidenceRef
                                PeptideEvidence pe = peRef.getPeptideEvidence();
//                          i) if isDecoy attribute does not exists or equals to true (does not say if the optional attribute does not exist, which value should be expected), jump to next PE
                                if (pe.isIsDecoy()) {
                                    continue;
                                }
//                                    foundPE = true;
//                          ii)retrieve protein id and accession from the mandatory attributes id and accession respectively from the referenced DBSequence in the PE
                                DBSequence dbs = pe.getDBSequence();
                                if(dbs_seqs.containsKey(dbs.getId())){
                                    seqOut.append(">");
                                    seqOut.append(dbs.getAccession());
                                    seqOut.append("\n");
                                    seqOut.append(dbs_seqs.get(dbs.getId()));
                                    seqOut.append("\n");
                                    dbs_seqs.remove(dbs.getId());
                                }
                                sb.append(dbs.getAccession());
                                sb.append(",");
                            }
                            sb.deleteCharAt(sb.length() - 1);
                            final String pepInfo = sb.toString();
                            peptides.add(pepInfo);
                            HashMap<String, String> map = new HashMap<String, String>();
                            for (CvParam cv : selected.getCvParam()) {
                                if (cv.getCvRef().equals("PSI-MS") || cv.getCvRef().equals("MS")) {
                                    String[] elmts = cv.getAccession().split(":");
                                    int acc = Integer.parseInt(elmts[1]);
                                    if (cvTerms.contains(acc)) {
                                        existingTerms.add(cv.getName());
                                        map.put(cv.getName(), cv.getValue());
                                    }
                                }
                            }
                            peptideCvTerms.put(pepInfo, map);
                        }//peptide found
                    }//if sii not null
                }//end of sir list
            }
            //find the main score for output
            String mainScoreCV;
            if (existingTerms.isEmpty()) {
                mainScoreCV = SCORE;
            } else if (existingTerms.contains("FDRScore")) {
                mainScoreCV = "FDRScore";
                existingTerms.remove("FDRScore");
            } else if (existingTerms.contains("Mascot:score")) {
                mainScoreCV = "Mascot:score";
                existingTerms.remove("Mascot:score");
            } else {
                mainScoreCV = existingTerms.iterator().next();
                existingTerms.remove(mainScoreCV);
            }
            ArrayList<String> remaining = new ArrayList<String>();
            remaining.addAll(existingTerms);
            BufferedWriter out = new BufferedWriter(new FileWriter(output));
            out.append("Peptide\tProteins\tReverse\tContaminants\t");
            out.append(mainScoreCV);
            out.append("\tQuantitation");
            for (String one : remaining) {
                out.append("\t");
                out.append(one);
            }
            out.append("\n");
            for (String pepInfo : peptides) {
                out.append(pepInfo);
                //reverse contaminant score
                out.append("\t\t\t");
                HashMap<String, String> map = peptideCvTerms.get(pepInfo);
                if (mainScoreCV.equals(SCORE)) {
                    out.append("1");
                } else {
                    if (map.containsKey(mainScoreCV)) {
                        out.append(map.get(mainScoreCV));
                    } else {
                        out.append("1");
                    }
                }
                //quantitation, as there is no quant info, set to be 1
                out.append("\t1");
                for (String one : remaining) {
                    out.append("\t");
                    if (map.containsKey(one)) {
                        out.append(map.get(one));
                    } else {
                        out.append("1");
                    }
                }
                out.append("\n");
            }
            out.flush();
            out.close();
            seqOut.flush();
            seqOut.close();
        } catch (IOException ex) {
            Logger.getLogger(ParseMzq.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

    private void initialize() {
//id: MS:1001143 name: search engine specific score for PSMs def: "Search engine specific peptide scores." [PSI:PI] is_a: MS:1001105 ! peptide result details
        cvTerms.add(1001143);
//id: MS:1001153 name: search engine specific score def: "Search engine specific scores." [PSI:PI] is_a: MS:1001405 ! spectrum identification result details
        cvTerms.add(1001153);
//id: MS:1001171 name: Mascot:score
        cvTerms.add(1001171);
//id: MS:1001172 name: Mascot:expectation value
        cvTerms.add(1001172);
//id: MS:1001215 name: SEQUEST:PeptideSp
        cvTerms.add(1001215);
//id: MS:1002248 name: SEQUEST:spscore
        cvTerms.add(1002248);
//id: MS:1001328 name: OMSSA:evalue
        cvTerms.add(1001328);
//id: MS:1001329 name: OMSSA:pvalue
        cvTerms.add(1001329);
//id: MS:1001330 name: X\!Tandem:expect
        cvTerms.add(1001330);
//id: MS:1001390 name: Phenyx:Score
        cvTerms.add(1001390);
//id: MS:1001396 name: Phenyx:PepPvalue
        cvTerms.add(1001396);
//id: MS:1001492 name: percolator:score
        cvTerms.add(1001492);
//id: MS:1001501 name: MSFit:Mowse score
        cvTerms.add(1001501);
//id: MS:1001502 name: Sonar:Score
        cvTerms.add(1001502);
//id: MS:1001507 name: ProteinExtractor:Score
        cvTerms.add(1001507);
//id: MS:1001568 name: Scaffold:Peptide Probability
        cvTerms.add(1001568);
//id: MS:1001569 name: IdentityE Score
        cvTerms.add(1001569);
//id: MS:1001572 name: SpectrumMill:Score
        cvTerms.add(1001572);
//id: MS:1001887 name: SQID:score
        cvTerms.add(1001887);
//id: MS:1001894 name: Progenesis:confidence score
        cvTerms.add(1001894);
//id: MS:1001950 name: PEAKS:peptideScore
        cvTerms.add(1001950);
//id: MS:1001974 name: DeBunker:score
        cvTerms.add(1001974);
//id: MS:1001979 name: MaxQuant:PTM Score
        cvTerms.add(1001979);
//id: MS:1001985 name: Ascore:Ascore
        cvTerms.add(1001985);
//id: MS:1002044 name: ProteinProspector:score
        cvTerms.add(1002044);
//id: MS:1002045 name: ProteinProspector:expectation value
        cvTerms.add(1002045);
//id: MS:1002053 name: MS-GF:EValue
        cvTerms.add(1002053);
//id: MS:1002255 name: Comet:spscore
        cvTerms.add(1002255);
//id: MS:1002257 name: Comet:expectation value
        cvTerms.add(1002257);
//id: MS:1002262 name: Byonic:Score
        cvTerms.add(1002262);
//id: MS:1002319 name: Amanda:AmandaScore
        cvTerms.add(1002319);
//id: MS:1002338 name: Andromeda:score
        cvTerms.add(1002338);
//id: MS:1001874 name: FDRScore
        cvTerms.add(1001874);
    }
}
