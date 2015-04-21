package uk.ac.qmul.sbcs.extract_peptide;

import java.util.ArrayList;
import java.util.HashSet;

/**
 * Hello world!
 *
 */
public class App{
    private String input;
    private String output;
    private String type;
    private Parser parser;
    final private String MAXQUANT = "maxquant";
    final private String MZID = "mzid";
    final private String MZQ = "mzq";
    private HashSet<String> types;
    public App(){
        types = new HashSet<String>();
        types.add(MAXQUANT);
        types.add(MZID);
        types.add(MZQ);
//        String tmp = "bo;igoh;foo";
//        String[] aa = tmp.split("o");
//        System.out.println(aa.length);
    }

    private void init(String[] args){
//        System.out.println("args length:"+args.length);
//        for (int i = 0; i < args.length; i++) {
//            String string = args[i];
//            System.out.println("parameter "+i+" : "+ string);
//        }
        input = args[0];
        output = args[1];
        type = args[2].toLowerCase();
        if(!types.contains(type)){
            System.out.println("Unrecoginzed type, please only use mzid|mzq|maxquant");
            System.exit(3);
        }
        if(type.equals(MAXQUANT)){
            ArrayList<Integer> index = new ArrayList<Integer>();
            for (int i = 3; i < args.length; i++) {
                index.add(Integer.parseInt(args[i]));
            }
            parser = new ParseMaxquant(input,output,index);
        }else if(type.equals(MZQ)){
            parser = new ParseMzq(input, output);
        }else if(type.equals(MZID)){
            parser = new ParseMzid(input, output,args[3]);
        }
        parser.parse();
    }
    
    public static void main(String[] args ){
        App app = new App();
        if(args.length<3){
            System.out.println("At least three parameters required.");
            System.out.println("Usage: java -jar extractPeptide.jar <input file> <output file> <type> <fasta file|type-specific parameters>");
            System.exit(1);
        }
        app.init(args);
    }
}
