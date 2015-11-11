/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package local_mcpred;
import java.util.regex.*;
import java.util.*;
import java.io.*;

/**
 *
 * @author mjfidcl2
 */
public class McpredUtils {

    //attributes

    //constructor
    public McpredUtils(){
    }


    /*
     * Repeats a given character for a specified number of times.
     */
    public static String repeatChar(String s, int i){
        String rep = "";
        for(int j=0;j<i;j++){
            rep += s;
        }
        return rep;
    }


    
    
    
    
    /*
     * reads in fasta sequence files
     */
    public static HashMap<String, String> readFasta(String f) throws IOException{
        BufferedReader br = new BufferedReader(new FileReader(new File(f)));
        String s = null;
        String header = null;
        String tmp = null;
        Pattern p = Pattern.compile("^\\>.*");

        HashMap<String, String> seqs = new HashMap<String, String>();
        while((s=br.readLine())!=null){
            Matcher m = p.matcher(s);

            if(m.find()){
                header = m.group(0).substring(1);
                
            }else{
                if(seqs.containsKey(header)){
                    tmp = seqs.get(header);
                    tmp = tmp.concat(s);
                    if(tmp.contains("*")){
                        tmp = tmp.replaceAll("\\*", "");
                    }
                    seqs.put(header, tmp);
                }else{
                    s = s.replaceAll("\\*", "");
                    seqs.put(header, s);
                }
            }
        }
        return seqs;
    }

    /*
     * Overloaded trypsin digest method. Accepts protein seqeunce and
     * number of miscleaves to be contained in peptides. And min peptide
     * length.
     */
    public static String[] trypsinDigest(String s, int i, int min, int max){
        
        String[] cleaved = McpredUtils.trypsinDigest(s, i);
        ArrayList<String> fdigested = new ArrayList<String>();
        for(int m=0;m<cleaved.length;m++){
            if(cleaved[m].length()>=min && cleaved[m].length()<=max){
                fdigested.add(cleaved[m]);
            }
        }
        String[] r = new String[fdigested.size()];
        fdigested.toArray(r);
        return r;
    }


    /*
     * Overloaded trypsin digest method. Accepts protein seqeunce and
     * number of miscleaves to be contained in peptides. 
     */
    public static String[] trypsinDigest(String s, int i){
         String[] gdigested = McpredUtils.trypsinDigest(s);
         ArrayList<String> cat = new ArrayList<String>();
         String thisstring = null;
         for(int j=0;j<gdigested.length;j++){
             thisstring = gdigested[j];
             if(j+i<gdigested.length){
                for(int k=j;k<=j+i;k++){
                    if(k==j){
                        cat.add(thisstring);
                    }else{
                        thisstring = thisstring+""+gdigested[k];
                        cat.add(thisstring);
                    }
                }
             }else{                    
                for(int k=j;k<gdigested.length;k++){
                    if(k==j){
                        cat.add(thisstring);
                    }else{
                        thisstring = thisstring+""+gdigested[k];
                        cat.add(thisstring);
                    }
                }
             }
         }
        String[] r = new String[cat.size()];
        cat.toArray(r);
        return r;
    }

    /*
     * Overloaded trypsin digest method. Accepts protein sequence and
     * returns all digest proteins with max number of miscleavages. 
     */
     public static String[] trypsinDigest(String s){
         ArrayList<String> digested  = new ArrayList<String>();
//         System.out.println(s);
         Pattern site = Pattern.compile("[KR]");
         Matcher m = site.matcher(s);
         int last = 0;
         int now = 0;
         while(m.find()){
             now = m.end();
             digested.add(s.substring(last, now));
             last = now;
         }
         digested.add(s.substring(now));
         String[] frags = new String[digested.size()];
         digested.toArray(frags);
         ArrayList<String> tmpfrags = new ArrayList<String>();
         for(int i=0;i<frags.length;i++){
           if(frags[i].startsWith("P") && i>0){
               String tmp = tmpfrags.get(tmpfrags.size()-1)+""+frags[i];
               tmpfrags.remove(tmpfrags.size()-1);
               tmpfrags.add(tmp);
           }else{
               if(frags[i].length()>0){
                tmpfrags.add(frags[i]);
               }
           }
        }

        String[] pepfrags = new String[tmpfrags.size()];
        tmpfrags.toArray(pepfrags);
        
        return pepfrags;
    }

     /*
      * add Z string
      * accepts an integer as the number of Z characters to return
      * returns a string of Z for length supplied
      */

    public static String addZ(int z){
        String s = "";
        for(int i=0;i<z;i++){
            s += "Z";
        }
        return s;
    }



}
