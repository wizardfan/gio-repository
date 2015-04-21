/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package uk.ac.qmul.sbcs.extract_peptide;

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Set;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.xml.validation.Validator;
import uk.ac.liv.jmzqml.model.mzqml.MzQuantML;
import uk.ac.liv.jmzqml.model.mzqml.PeptideConsensus;
import uk.ac.liv.jmzqml.model.mzqml.PeptideConsensusList;
import uk.ac.liv.jmzqml.model.mzqml.Protein;
import uk.ac.liv.jmzqml.model.mzqml.ProteinList;
import uk.ac.liv.jmzqml.model.mzqml.QuantLayer;
import uk.ac.liv.jmzqml.model.mzqml.Row;
import uk.ac.liv.jmzqml.xml.io.MzQuantMLUnmarshaller;

/**
 *
 * @author Jun Fan@qmul
 */
public class ParseMzq extends Parser{
    
    /**
     * the name of the xsd file for mzQuantML format
     */
    private final String MZQ_XSD = "mzQuantML_1_0_0.xsd";
    public ParseMzq(String input, String output){
        this.input = input;
        this.output = output;
    }

    @Override
    void parse(){
        Validator validator = XMLparser.getValidator(MZQ_XSD);
        boolean validFlag = XMLparser.validate(validator, input);
        if(!validFlag){
            System.out.println("The mzQuantML validation went wrong, program terminated");
            System.exit(1);
        }
        System.out.println("mzq file "+input+" is valid");
        //load the mzQuantML file into memory
        MzQuantMLUnmarshaller unmarshaller = new MzQuantMLUnmarshaller(input);
        MzQuantML mzq = unmarshaller.unmarshall();
        ProteinList proteinList = mzq.getProteinList();
        if(proteinList==null){
            System.out.println("There is no protein list in the mzq file, program terminated.");
            System.exit(0);
        }
        //get all peptides related to proteins
        HashMap<String,HashSet<String>> peptides = new HashMap<String, HashSet<String>>();
        HashMap<String,String> seqs = new HashMap<String, String>();
        for(Protein protein:proteinList.getProtein()){
            for (String id : protein.getPeptideConsensusRefs()) {
                HashSet<String> proteins;
                if (peptides.containsKey(id)) {
                    proteins = peptides.get(id);
                } else {
                    proteins = new HashSet<String>();
                    peptides.put(id, proteins);
                }
                proteins.add(protein.getAccession());
            }
        }
        boolean foundQuant = false;
        HashMap<String,StringBuilder> quantInfo = new HashMap<String, StringBuilder>();
        StringBuilder headerSB = new StringBuilder();
        headerSB.append("Peptide\tProteins\tReverse\tContaminants\tScore");
        //get the quantitation for peptides
        for(PeptideConsensusList pcList:mzq.getPeptideConsensusList()){
            if (pcList.isFinalResult()){
                for(PeptideConsensus pc:pcList.getPeptideConsensus()){
                    seqs.put(pc.getId(), pc.getPeptideSequence());
                }
                for(QuantLayer ql:pcList.getAssayQuantLayer()){
                    foundQuant = true;
                    for(Object col:ql.getColumnIndex()){
                        headerSB.append("\t");
                        headerSB.append(ql.getId());
                        headerSB.append("_");
                        headerSB.append(col);
                    }
                    Set<String> notfound = new HashSet<String>();
                    for(String id:peptides.keySet()){
                        notfound.add(id);
                    }
                    for(Row row:ql.getDataMatrix().getRow()){
                        String id = row.getObjectRef();
                        notfound.remove(id);
                        StringBuilder sb;
                        if(quantInfo.containsKey(id)){
                            sb = quantInfo.get(id);
                        }else{
                            sb = new StringBuilder();
                            quantInfo.put(id, sb);
                        }
                        for(String value:row.getValue()){
                            sb.append("\t");
                            sb.append(value);
                        }
                    }
                    for (String id:notfound){
                        StringBuilder sb;
                        if(quantInfo.containsKey(id)){
                            sb = quantInfo.get(id);
                        }else{
                            sb = new StringBuilder();
                            quantInfo.put(id, sb);
                        }
                        for (Iterator it = ql.getColumnIndex().iterator(); it.hasNext();) {
                            Object value = it.next();
                            sb.append("\t");
                            sb.append("0");
                        }
                    }
                }
            }
        }
        if(!foundQuant){
            System.out.println("No quantitation found within the mzq file, all set to 1");
            headerSB.append("\tQuantitation");
        }
        try {
            BufferedWriter out = new BufferedWriter(new FileWriter(output));
            out.append(headerSB.toString());
            out.append("\n");
            for(String peptide:seqs.keySet()){
                //peptide
                out.append(seqs.get(peptide));
                out.append("\t");
                //protein
                StringBuilder sb = new StringBuilder();
                for(String protein:peptides.get(peptide)){
                    sb.append(">");
                    sb.append(protein);
                    sb.append(",");
                }
                sb.deleteCharAt(sb.length()-1);
                out.append(sb.toString());
                //reverse contaminant score
                out.append("\t\t\t1");
                //quantitation
                if(foundQuant){
                    out.append(quantInfo.get(peptide).toString());
                }else{
                    out.append("\t1");
                }
                out.append("\n");
            }
            out.flush();
            out.close();
        } catch (IOException ex) {
            Logger.getLogger(ParseMzq.class.getName()).log(Level.SEVERE, null, ex);
        }
    }
}
