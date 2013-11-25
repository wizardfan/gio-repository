package uk.ac.qmul.gio_installer;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import org.w3c.dom.DOMException;
import org.w3c.dom.Document;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

/**
 *
 * @author Jun Fan@qmul
 */
public class GenerateDocument {
    private String folder;
    public GenerateDocument(String dir){
        folder = dir;
    }
    
    public void execute(){
        BufferedWriter out = null;
        try {
            out = new BufferedWriter(new FileWriter("../wiki/document.wiki"));
            File dir = new File(folder);
            if(!dir.exists()){
                System.out.println("Can not locate the given folder "+folder);
                System.exit(1);
            }
            String[] sections = dir.list();
            for(String tmp:sections){
                File section = new File(folder+"/"+tmp);
                out.append("==Section "+tmp+"==\n");
                String[] files = section.list();
                for(String file:files){
                    if(file.endsWith(".xml")){
                        if(!file.startsWith("tool_conf")) out.append(generateDocument(folder+"/"+tmp+"/"+file));
                    }else if(!file.endsWith(".sample")){
                        File aa = new File(folder+"/"+tmp+"/"+file);
                        if (aa.isDirectory()){
                            String[] abc = aa.list();
                            for (String cba:abc){
                                if(cba.endsWith(".xml")) out.append(generateDocument(folder+"/"+tmp+"/"+file+"/"+cba));
                            }
                        }
                    }
                }
            }
        } catch (IOException ex) {
            Logger.getLogger(GenerateDocument.class.getName()).log(Level.SEVERE, null, ex);
        } finally {
            try {
                out.close();
            } catch (IOException ex) {
                Logger.getLogger(GenerateDocument.class.getName()).log(Level.SEVERE, null, ex);
            }
        }
    }

    private String generateDocument(String filename){
        StringBuilder value = new StringBuilder();
        try {
            DocumentBuilderFactory docFactory = DocumentBuilderFactory.newInstance();
            DocumentBuilder docBuilder = docFactory.newDocumentBuilder();
            Document doc = docBuilder.parse(filename);
            Node root = doc.getFirstChild();
            
            value.append("*Name:*");
            value.append(getAttributeText(root, "name"));
            
            value.append("\n*Description:*\n");
            value.append(getElementContent(doc,"description"));
            
            NodeList inputs = doc.getElementsByTagName("inputs").item(0).getChildNodes();
            StringBuilder inputSb = new StringBuilder();
            StringBuilder paramSb = new StringBuilder();
//            int inputCount = 0;
            for (int i=0; i < inputs.getLength(); i++){
                Node node = inputs.item(i);
                if (node.getNodeType() == Node.ELEMENT_NODE){
                    if(node.getNodeName().equals("param")){
                        final String type = node.getAttributes().getNamedItem("type").getTextContent();
                        if(type.equals("data")){
//                            inputCount++;
//                            inputSb.append("Input file ");
//                            inputSb.append(inputCount);
//                            inputSb.append(": ");
                            inputSb.append("  # ");
                            inputSb.append(getAttributeText(node, "name"));
                            inputSb.append(" ");
                            inputSb.append(getAttributeText(node,"label"));
                            inputSb.append(" ");
                            inputSb.append(getAttributeText(node,"help"));
                            inputSb.append("\n");
                        }else{
//                            paramSb.append("Paramter: ");
                            paramSb.append("  # ");
                            paramSb.append(getAttributeText(node, "name"));
                            paramSb.append(" ");
                            paramSb.append(getAttributeText(node, "label"));
                            paramSb.append(" ");
                            paramSb.append(getAttributeText(node, "help"));
                            paramSb.append("\n");
                        }
                    }else if(node.getNodeName().equals("repeat")){
                        paramSb.append("  # Repeat element ");
                        paramSb.append(node.getAttributes().getNamedItem("title").getTextContent());
                        paramSb.append("\n");
                    }
                }
            }
            value.append("\n*Input files:*\n");
            value.append(inputSb.toString());
            value.append("*Parameters:*\n");
            value.append(paramSb.toString());
            
            value.append("*Outputs:*\n");
            NodeList outputs = doc.getElementsByTagName("outputs").item(0).getChildNodes();
//            int count = 0;
            for (int i = 0; i < outputs.getLength(); i++) {
                Node node = outputs.item(i);
                if(node.getNodeType() == Node.ELEMENT_NODE && node.getNodeName().equals("data")){
//                    count++;
                    StringBuilder sb = new StringBuilder();
//                    sb.append("Output file ");
//                    sb.append(count);
//                    sb.append(": Name ");
                    sb.append("  # ");
                    sb.append(getAttributeText(node, "name"));
                    sb.append(" with Type ");
                    sb.append(getAttributeText(node,"format"));
                    value.append(sb.toString());
                    value.append("\n");
                }
            }
            
            value.append("*Details:*\n");
            value.append(getElementContent(doc,"help"));
            value.append("\n");
        } catch (Exception e) {
            e.printStackTrace();
        }
        return value.toString();
    }

    private String getElementContent(Document doc,String tagName) throws DOMException {
        NodeList node = doc.getElementsByTagName(tagName);
        if(node.getLength()!=0){
            return node.item(0).getTextContent();
        }
        return "";
    }

    private String getAttributeText(Node node, String label) {
        final Node attr = node.getAttributes().getNamedItem(label);
        if(attr!=null){
            return attr.getTextContent();
        }
        return "";
    }
}
