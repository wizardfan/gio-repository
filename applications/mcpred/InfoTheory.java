/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */


import java.util.HashMap;
import local_mcpred.McpredUtils;
import local_mcpred.Predictor_infotheory;
/**
 *
 * @author mjfidcl2
 */
public class InfoTheory {

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) throws Exception{
        // TODO code application logic here
        HashMap<String, String> fasta = McpredUtils.readFasta(args[0]);
        String[] protnames = new String[fasta.size()];
        fasta.keySet().toArray(protnames);
        HashMap<String, String[]> protpeps = new HashMap<String, String[]>();        
        for(int i=0;i<protnames.length;i++){
            protpeps.put(protnames[i], McpredUtils.trypsinDigest(fasta.get(protnames[i]), 0, 5, 99));
        }
        
        
        Predictor_infotheory pred = new Predictor_infotheory();
        pred.importPeptides(protpeps, fasta);
        pred.runClassification();
        pred.printResults();
        
        
        
    }
}
