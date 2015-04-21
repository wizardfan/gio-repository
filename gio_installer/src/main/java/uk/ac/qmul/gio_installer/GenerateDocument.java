package uk.ac.qmul.gio_installer;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.Writer;
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
//        generateDocument("C:\\gio-repository\\trunk\\wrappers\\pit\\extractPeptides.xml");
//        System.exit(0);
        BufferedWriter out = null;
        try {
            out = new BufferedWriter(new FileWriter("../wiki/document.wiki"));
            File dir = new File(folder);
            if(!dir.exists()){
                System.out.println("Can not locate the given folder "+folder);
                System.exit(1);
            }
            String[] sections = dir.list();
            for(String section:sections){
                File sectionFolder = new File(folder+"/"+section);
                if(section.equals("PSIstandards")) {
                    out.append("==Section PSI standards==\n");
                }else{
                    out.append("==Section "+section+"==\n");
                }
                String[] files = sectionFolder.list();
                for(String file:files){
                    if(file.endsWith(".xml")){
                        if(!file.startsWith("tool_conf")) docForOneTool(out, folder+"/"+section+"/"+file, section, file.substring(0, file.length()-4));
                    }else if(!file.endsWith(".sample")){
                        File aa = new File(folder+"/"+section+"/"+file);
                        if (aa.isDirectory()){
                            String[] abc = aa.list();
                            for (String cba:abc){
                                if(cba.endsWith(".xml")) docForOneTool(out, folder+"/"+section+"/"+file+"/"+cba, section, cba.substring(0, cba.length()-4));
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

    
    private String generateDocument(String section, String toolName, String filename){
        StringBuilder value = new StringBuilder();
        try {
            DocumentBuilderFactory docFactory = DocumentBuilderFactory.newInstance();
            DocumentBuilder docBuilder = docFactory.newDocumentBuilder();
            Document doc = docBuilder.parse(filename);
            Node root = doc.getFirstChild();
            
            value.append("*Name:* ");
            value.append(getAttributeText(root, "name"));
            
            value.append("<br>\n*Description:*<br>\n");
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
                            inputSb.append("  * ");
                            inputSb.append(getAttributeText(node, "name"));
                            inputSb.append("   ");
                            inputSb.append(getAttributeText(node,"label"));
                            inputSb.append(" ");
                            inputSb.append(getAttributeText(node,"help"));
                            inputSb.append("\n");
                        }else{
//                            paramSb.append("Paramter: ");
                            paramSb.append("  * ");
                            paramSb.append(getAttributeText(node, "name"));
                            paramSb.append("   ");
                            paramSb.append(getAttributeText(node, "label"));
                            paramSb.append(" ");
                            paramSb.append(getAttributeText(node, "help"));
                            paramSb.append("\n");
                        }
                    }else if(node.getNodeName().equals("repeat")){
                        paramSb.append("  * Repeat element ");
                        paramSb.append(getAttributeText(node, "title"));
                        paramSb.append("\n");
                    }else if(node.getNodeName().equals("conditional")){
                        paramSb.append("  * Conditional element: ");
                        paramSb.append(getAttributeText(node, "name"));
                        paramSb.append("\n");
                        NodeList conditions = node.getChildNodes();
                        for (int j = 0; j < conditions.getLength(); j++) {
                            Node condition = conditions.item(j);
                            if (condition.getNodeType() == Node.ELEMENT_NODE){
                                if(condition.getNodeName().equals("when")){
                                    paramSb.append("    * ");
                                    paramSb.append(getAttributeText(condition, "value"));
                                    paramSb.append("\n");
                                }
                            }
                        }
                        paramSb.append("\n");
                    }
                }
            }
            value.append("<br>\n*Input files:*");
            if(inputSb.length()==0){
                value.append("<br>\n");
            }else{
                value.append("\n");
                value.append(inputSb.toString());
            }
            value.append("*Parameters:*<br>\n");
            value.append(paramSb.toString());
            
            value.append("*Outputs:*<br>\n");
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
                    sb.append("  * ");
                    sb.append(getAttributeText(node, "name"));
                    boolean singleFormat = true;
                    NodeList changeFormats = node.getChildNodes();
                    for (int j = 0; j < changeFormats.getLength(); j++) {
                        Node tmp = changeFormats.item(j);
                        if(tmp.getNodeType() == Node.ELEMENT_NODE && tmp.getNodeName().equals("change_format")){
                            singleFormat = false;
                            sb.append(" in the one of the listed formats: ");
                            sb.append(getAttributeText(node, "format"));
                            NodeList formats = tmp.getChildNodes();
                            for (int k = 0; k < formats.getLength(); k++) {
                                Node format = formats.item(k);
                                if(format.getNodeType()==Node.ELEMENT_NODE && format.getNodeName().equals("when")){
                                    sb.append(", ");
                                    sb.append(getAttributeText(format, "value"));
                                }
                            }
                        }
                    }
                    if(singleFormat){
                        sb.append(" with Type ");
                        sb.append(getAttributeText(node,"format"));
                    }
                    value.append(sb.toString());
                    value.append("\n");
                }
            }
            
            value.append("*Details:*<br>");
            value.append(getElementContent(doc,"help"));
            value.append("<br>\n\n");
            String outfile = "../wiki/"+section+"_"+toolName+".wiki";
            BufferedWriter writer = new BufferedWriter(new FileWriter(outfile));
            writer.append(value.toString());
            writer.close();
            return getAttributeText(root, "name");
        } catch (Exception e) {
            e.printStackTrace();
        }
        //should never reach here as long as the wrapper is written according to the specification
        return "";
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

    private void docForOneTool(BufferedWriter out, String filename, String section, String toolName) throws IOException {
        section = section.replace(" ", "");
        toolName = toolName.replace(" ", "");
        String display = generateDocument(section, toolName, filename);
        display = display.replace(" ", "_");
        out.append("  * [");
        out.append(section);
        out.append("_");
        out.append(toolName);
        out.append(" ");
        out.append(display);
        out.append("]\n");
    }
}
