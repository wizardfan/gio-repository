/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

/**
 *
 * @author mjfidcl2
 */




import java.util.HashMap;
import local_mcpred.McpredUtils;
import local_mcpred.Predictor_mcpred;

public class Mcpred {

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) throws Exception{
        HashMap<String, String> fasta = McpredUtils.readFasta(args[0]);
        String[] protnames = new String[fasta.size()];
        fasta.keySet().toArray(protnames);
        HashMap<String, String[]> protpeps = new HashMap<String, String[]>();        
        for(int i=0;i<protnames.length;i++){
            protpeps.put(protnames[i], McpredUtils.trypsinDigest(fasta.get(protnames[i]), 0, 5, 99));
        }
        
        Predictor_mcpred pred = new Predictor_mcpred("mcpred.model");
        pred.importPeptides(protpeps, fasta);
        pred.runClassification();
        pred.printResults();
    }
}
