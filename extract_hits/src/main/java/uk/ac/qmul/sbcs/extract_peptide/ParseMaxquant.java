package uk.ac.qmul.sbcs.extract_peptide;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * @author Jun Fan@qmul
 */
public class ParseMaxquant extends Parser{
    private ArrayList<Integer> index;
    
    public ParseMaxquant(String input, String output, ArrayList<Integer> index) {
        this.input = input;
        this.output = output;
        this.index = index;
    }
    
    @Override
    void parse(){
        try {
            BufferedReader in = new BufferedReader(new FileReader(input));
            BufferedWriter out = new BufferedWriter(new FileWriter(output));
            String header = in.readLine().trim();
            String[] elmts = header.split("\t");
            StringBuffer sb = new StringBuffer();
            sb.append(elmts[index.get(0)-1]);
            for (int i = 1; i < index.size(); i++) {
                sb.append("\t");
                sb.append(elmts[index.get(i)-1]);
            }
            sb.append("\n");
            out.append(sb.toString());
            String line;
            while((line=in.readLine())!=null){
                sb = new StringBuffer();
                elmts = line.split("\t");
//                sb.append(elmts[index.get(0) - 1]);
                sb.append(getElement(elmts, index.get(0)));
                for (int i = 1; i < index.size(); i++) {
                    sb.append("\t");
                    sb.append(getElement(elmts, index.get(i)));
                }
                sb.append("\n");
                out.append(sb.toString());
            }
            out.flush();
            out.close();
        } catch (FileNotFoundException ex) {
            System.out.println("Can not find the specified input file "+input);
            System.exit(2);
        } catch (IOException ex) {
            Logger.getLogger(App.class.getName()).log(Level.SEVERE, null, ex);
        }
    }
    
    private String getElement(String[] elmts, int idx){
        if (idx > elmts.length) return "";
        return elmts[idx-1];
    }
}
