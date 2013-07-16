package uk.ac.qmul.gio_installer;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.PrintWriter;
import java.io.RandomAccessFile;
import java.util.ArrayList;
import java.util.Scanner;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import org.w3c.dom.Attr;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

public class Installer {

    private final static String SECTION_NAME = "Galaxy Integrated Omics";
    private final static String SECTION_ID = "gio";

    public Installer() {
        getRepository();
        moveFolders();
//        modifyToolConfByDOM();
        modifyToolConfByFileOperation();
    }

    public static void main(String[] args) {
        new Installer();
    }

    private void getRepository() {
    }

    private void moveFolders() {
    }

    private void modifyToolConfByDOM() {
        try {
            String filepath = "tool_conf.xml";
            DocumentBuilderFactory docFactory = DocumentBuilderFactory.newInstance();
            DocumentBuilder docBuilder = docFactory.newDocumentBuilder();
            Document doc = docBuilder.parse(filepath);
            Node root = doc.getFirstChild();
            NodeList sections = doc.getElementsByTagName("section");
            Node gio = null;
//            for (int i = 0; i < sections.getLength(); i++) {
//                Node node = sections.item(i).getAttributes().getNamedItem("name");
//                if(node.getNodeValue().equalsIgnoreCase(SECTION_NAME)){
//                    gio = node;
//                    System.out.println(gio.getClass());
//                    break;
//                }
//            }
            //gio has never been installed
            if (gio == null) {
                gio = doc.createElement("new_test");
                Attr name = doc.createAttribute("name");
                name.setValue(SECTION_NAME);
                Attr id = doc.createAttribute("id");
                id.setValue(SECTION_ID);
                gio.getAttributes().setNamedItem(name);
                gio.getAttributes().setNamedItem(id);
                for (int i = 0; i < 4; i++) {
                    Element toolNode = doc.createElement("tool");
                    Attr file = doc.createAttribute("file");
                    file.setValue("wrapper_" + i);
                    toolNode.getAttributes().setNamedItem(file);
                    gio.appendChild(toolNode);
                }
                root.appendChild(gio);
            }

            TransformerFactory transformerFactory = TransformerFactory.newInstance();
            Transformer transformer = transformerFactory.newTransformer();
            DOMSource source = new DOMSource(doc);
            StreamResult result = new StreamResult(new File(filepath));
            transformer.transform(source, result);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void modifyToolConfByFileOperation() {
        String filepath = "tool_conf.xml";
        ArrayList<String> fileLines = new ArrayList<String>();
        ArrayList<String> gioEntry = new ArrayList<String>();
        String section = "  <section name=\""+SECTION_NAME+"\" id=\""+SECTION_ID+"\">";
        gioEntry.add(section);
        for (int i = 1; i < 6; i++) {
            String toolStr = "\t<tool file=\"gio/plugin_" + i + ".xml\"/>";
            gioEntry.add(toolStr);
        }
        gioEntry.add("  </section>");
        Scanner scanner = null;
        try {
            scanner = new Scanner(new File(filepath));
            String line = scanner.nextLine();
            fileLines.add(line);
            while (line.indexOf("toolbox") < 0) {
                line = scanner.nextLine();
                fileLines.add(line);
            }
            String firstSection = scanner.nextLine();//the first section
            //gio section should always be the first section
            if (firstSection.indexOf(SECTION_NAME) >= 0) {//gio has been installed before, remove the old section
                while(line.indexOf("/section")<0){
                    line = scanner.nextLine();
                }
            }
            fileLines.addAll(gioEntry);
            if (firstSection.indexOf(SECTION_NAME) < 0) fileLines.add(firstSection);
            while (scanner.hasNextLine()) {
                line = scanner.nextLine();
                fileLines.add(line);
            }
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } finally {
            if (scanner != null) {
                scanner.close();
            }
        }

        PrintWriter pw = null;
        try {
            pw = new PrintWriter(new File(filepath));
            for (String line : fileLines) {
                pw.println(line);
            }
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } finally {
            if (pw != null) {
                pw.close();
            }
        }
    }
}
