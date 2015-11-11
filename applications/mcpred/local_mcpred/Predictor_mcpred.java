/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package local_mcpred;


import java.io.File;
import java.text.DecimalFormat;
import java.util.HashMap;
import jnisvmlight.LabeledFeatureVector;
import jnisvmlight.SVMLightModel;


/**
 *
 * @author mjfidcl2
 */
public class Predictor_mcpred{
    
    
    private SVMLightModel model;    
    private String[] protnames;
    private HashMap<String, String> fasta;
    private HashMap<String, String[]> protpeps;
    private HashMap<String, String> pep_starts;
    private HashMap<String, String> pep_ends;
    private HashMap<String, String> classification;
    
    
    /*
     * creates new mcpred predictor object
     * requires integer for the number of test subjects
     * sets up model file and initiates the test set
     */
    
    public Predictor_mcpred(String svm_model) throws Exception {
        model = SVMLightModel.readSVMLightModelFromURL(new File(svm_model).toURL());        
        classification = new HashMap<String, String>();
    }
    
    
    public void importPeptides(HashMap<String, String[]> pephash, HashMap<String, String> prots){
        this.fasta = prots;
        this.protpeps = pephash;
        this.protnames = new String[pephash.size()];
        protpeps.keySet().toArray(protnames);                
    }
    
    public void runClassification(){

        pep_starts = new HashMap<String, String>();
        pep_ends = new HashMap<String, String>();  
        
        double max = 1.949242;
        double min = 5.223915;   
        
        for(int i=0;i<protnames.length; i++) {
//            System.out.println(protnames[i]+"\t"+fasta.get(protnames[i]).length());
            String[] peps = protpeps.get(protnames[i]);
            
            int last = 0;
            for (int j = 0; j < peps.length; j++) {
                int start = fasta.get(protnames[i]).indexOf(peps[j], last);
                int end = fasta.get(protnames[i]).indexOf(peps[j], last) + peps[j].length();
                last = fasta.get(protnames[i]).indexOf(peps[j], last)+peps[j].length();
                
//                System.out.println("-> "+peps[j]+"\t"+start+"\t"+end);
//                
                if (start == 0) {
                    pep_starts.put(protnames[i] + "_" + peps[j]+"_"+j, "--");
                }else if((start+4)> fasta.get(protnames[i]).length()){                  
                    int diff = (start+4) - fasta.get(protnames[i]).length();
                    pep_starts.put(protnames[i] + "_" + peps[j]+"_"+j,fasta.get(protnames[i]).substring(start-5)+McpredUtils.addZ(diff));                    
                } else if (start < 5) {
                    int diff = 5 - start;
                    pep_starts.put(protnames[i] + "_" + peps[j]+"_"+j, McpredUtils.addZ(diff) + "" + fasta.get(protnames[i]).substring(0, start + 4));
                } else {
                    pep_starts.put(protnames[i] + "_" + peps[j]+"_"+j, fasta.get(protnames[i]).substring(start - 5, start + 4));
                }
                if (end == fasta.get(protnames[i]).length()) { 
                    pep_ends.put(protnames[i] + "_" + peps[j]+"_"+j, "--");
                }else if((end-5)<0){
                    int diff = 0-(end-5);
                    pep_ends.put(protnames[i] + "_" + peps[j]+"_"+j,McpredUtils.addZ(diff)+""+fasta.get(protnames[i]).substring(0, end+4));
                } else if (fasta.get(protnames[i]).length() < (4 + end)) {
                    int diff = (4 + end) - fasta.get(protnames[i]).length();
                    pep_ends.put(protnames[i] + "_" + peps[j]+"_"+j, fasta.get(protnames[i]).substring(end - 5) + "" + McpredUtils.addZ(diff));
                } else {
                    pep_ends.put(protnames[i] + "_" + peps[j]+"_"+j, fasta.get(protnames[i]).substring(end - 5, end + 4));
                }
                
            }
        }
        
        HashMap<String, String> aabin = new HashMap<String, String>();
        aabin.put("G","100000000000000000000");
        aabin.put("A","010000000000000000000");
        aabin.put("S","001000000000000000000");
        aabin.put("P","000100000000000000000");
        aabin.put("V","000010000000000000000");
        aabin.put("T","000001000000000000000");
        aabin.put("C","000000100000000000000");
        aabin.put("I","000000010000000000000");
        aabin.put("L","000000001000000000000");
        aabin.put("N","000000000100000000000");
        aabin.put("D","000000000010000000000");
        aabin.put("Q","000000000001000000000");
        aabin.put("K","000000000000100000000");
        aabin.put("E","000000000000010000000");
        aabin.put("M","000000000000001000000");
        aabin.put("H","000000000000000100000");
        aabin.put("F","000000000000000010000");
        aabin.put("R","000000000000000001000");
        aabin.put("Y","000000000000000000100");
        aabin.put("W","000000000000000000010");
        aabin.put("Z","000000000000000000001");
                
        DecimalFormat df = new DecimalFormat("0.00");
            
        for(int i = 0; i < protnames.length; i++) {

            String[] peps = protpeps.get(protnames[i]);            
            for (int j = 0; j < peps.length; j++) {   

                
                //check invalid amino acid characters in tryptic context
                
                String start_contains = "";
                String end_contains = "";
                String[] start_pepcheck = pep_starts.get(protnames[i]+"_"+peps[j]+"_"+j).split("");
                String[] end_pepcheck = pep_ends.get(protnames[i]+"_"+peps[j]+"_"+j).split("");
                
                for(int k=1;k<start_pepcheck.length;k++){
                    if(!aabin.containsKey(start_pepcheck[k])){
                        start_contains += " "+start_pepcheck[k];
                    }
                }
                
                for(int k=1;k<end_pepcheck.length;k++){
                    if(!aabin.containsKey(end_pepcheck[k])){
                        end_contains += " "+end_pepcheck[k];
                    }
                }
                
                      
                if (!pep_starts.get(protnames[i] + "_" + peps[j]+"_"+j).equals("--") && start_contains.equals("")) {
                    String[] tmp_start = pep_starts.get(protnames[i] + "_" + peps[j]+"_"+j).split("");
                    int[] dims = new int[9];
                    double[] values = new double[]{1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0};
                    for (int t = 1; t < tmp_start.length; t++) {
                        int p = ((t - 1) * 21) + 1;
                        dims[t - 1] = aabin.get(tmp_start[t]).indexOf("1") + p;
                    }
                    double val = model.classify(new LabeledFeatureVector(0, dims, values));
                    if (val < -(min)) {
                        val = -min;
                    } else if (val > max) {
                        val = max;
                    }
                    if (val < 0) {
                        val = (1 + (val / min)) / 2;
                    } else {
                        val = (1 + (val / max)) / 2;
                    }
                    classification.put("start_" + protnames[i] + "_" + peps[j]+"_"+j, df.format(val));
                } else if (pep_starts.get(protnames[i] + "_" + peps[j]+"_"+j).equals("--") ) {                    
                    classification.put("start_" + protnames[i] + "_" + peps[j]+"_"+j, "--");
                }else if(!start_contains.equals("")){
                    classification.put("start_" + protnames[i] + "_" + peps[j]+"_"+j,"unknown amino acid ("+start_contains+" ) in N-terminal tryptic context");
                }
                
                if (!pep_ends.get(protnames[i] + "_" + peps[j]+"_"+j).equals("--") && end_contains.equals("")) {
                    String[] tmp_end = pep_ends.get(protnames[i] + "_" + peps[j]+"_"+j).split("");
                    int[] dims = new int[9];
                    double[] values = new double[]{1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0};
                    for (int t = 1; t < tmp_end.length; t++) {
                        int p = ((t - 1) * 21) + 1;
                        dims[t - 1] = aabin.get(tmp_end[t]).indexOf("1") + p;
                    }
                    double val = model.classify(new LabeledFeatureVector(0, dims, values));
                    if (val < -(min)) {
                        val = -min;
                    } else if (val > max) {
                        val = max;
                    }
                    if (val < 0) {
                        val = (1 + (val / min)) / 2;
                    } else {
                        val = (1 + (val / max)) / 2;
                    }
                    classification.put("end_" + protnames[i] + "_" + peps[j]+"_"+j, df.format(val));
                } else if (pep_ends.get(protnames[i] + "_" + peps[j]+"_"+j).equals("--")) {
                    classification.put("end_" + protnames[i] + "_" + peps[j]+"_"+j, "--");
                } else if(!end_contains.equals("")){
                    classification.put("end_" + protnames[i] + "_" + peps[j]+"_"+j,"unknown amino acid ("+end_contains+" ) in C-terminal tryptic context");
                }
            }

        }
        
        
    }
    
    public void printResults(){
        
        System.out.println("Protein\tPeptide\tN-Terminal\tC-Terminal");
        
        for(int i=0;i<protnames.length;i++){
            String[] peps = protpeps.get(protnames[i]);
            for(int j=0;j<peps.length;j++){
                System.out.println(protnames[i]+"\t"+peps[j]+"\t"+classification.get("start_"+protnames[i]+"_"+peps[j]+"_"+j)+"\t"+classification.get("end_"+protnames[i]+"_"+peps[j]+"_"+j));
            }
        }
    }
    
    
    
    
}
