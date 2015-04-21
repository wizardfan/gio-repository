package uk.ac.qmul.sbcs.extract_peptide;

import java.io.File;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.xml.XMLConstants;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.transform.Source;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamSource;
import javax.xml.validation.Schema;
import javax.xml.validation.SchemaFactory;
import javax.xml.validation.Validator;
import org.w3c.dom.Document;

import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.SAXException;

/**
 *
 * @author Jun Fan@qmul
 */
public class XMLparser {
    private Document doc;
    private String filename;
    private boolean validated = false;
    public XMLparser(String fileName){
        filename = fileName;
    }
    /**
     * validate the xml file with the xsd file defined within the file
     * @param validatorTagName the tag where contains the location of the xsd file
     */
    public void validate(String validatorTagName){
//        if ((filename.indexOf(".xtc") < 0) 
//                && (filename.indexOf(".xtp") < 0)
//                && (filename.indexOf(".xml") < 0)) {
//            System.out.println("ERROR: The supposed xml file "+filename+" does not have a valid extension which should be .xtc, .xtp or .xml");
//            System.exit(1);
//            return;
//        }
        DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
        dbf.setNamespaceAware(true);
        try {
            DocumentBuilder db = dbf.newDocumentBuilder();
            doc = db.parse(filename);

            // create a SchemaFactory
            SchemaFactory factory = SchemaFactory.newInstance(XMLConstants.W3C_XML_SCHEMA_NS_URI);

//            doc.getDocumentElement().normalize();
            Node nodeLst = doc.getElementsByTagName(validatorTagName).item(0);
            if (nodeLst == null) {
                System.out.println("ERROR: The configuration file can not be validated as " + validatorTagName + " does not exist.");
                System.exit(1);
            }

            String schemaLocation = "";

            if (nodeLst.getAttributes().getNamedItem("xsi:schemaLocation") != null) {
                schemaLocation = nodeLst.getAttributes().getNamedItem("xsi:schemaLocation").getTextContent();
            } else {
                if (nodeLst.getAttributes().getNamedItem("xsi:noNamespaceSchemaLocation") != null) {
                    schemaLocation = nodeLst.getAttributes().getNamedItem("xsi:noNamespaceSchemaLocation").getTextContent();
                } else {
                    System.out.println("ERROR: No .xsd schema is provided for " + filename);
                    System.exit(1);
                }
            }
            // load the xtracker WXS schema
            File xsdFile = new File(schemaLocation);
            if (!xsdFile.exists()) {
                System.out.println("ERROR: Can not find the specified xsd file " + schemaLocation + " for validation");
                System.exit(1);
            }
            Source schemaFile = new StreamSource(xsdFile);
            Schema schema = factory.newSchema(schemaFile);
            // create a Validator instance
            Validator validator = schema.newValidator();
            try {
                validator.validate(new DOMSource(doc));
            } catch (SAXException e) {
                // instance document is invalid!
                System.out.println("\n\nERROR - could not validate the input file " + filename + "!");
                System.out.print(e);
                System.exit(1);
            }
        } catch (Exception e) {
            System.out.println("Exception while reading " + filename + "!\n" + e);
        }
        validated = true;
    }
    /**
     * return whether the plugin parameter file (in XML format) is valid
     * @return 
     */
    public boolean isValidated(){
        return validated;
    }
    /**
     * get the node with the specified tag name
     * @param tagName
     * @return 
     */
    public Node getElement(String tagName){
        if(isValidated()){
            return doc.getElementsByTagName(tagName).item(0);
        }
        return null;
    }
    
    public String getElementContent(String baseTagName,String contentTagName){
        Node node = getElement(baseTagName);
        if (node == null) return null;
        NodeList nodeList = node.getChildNodes();
        for (int i = 0; i < nodeList.getLength(); i++) {
            Node item = nodeList.item(i);
            if (item.getNodeType() == Node.ELEMENT_NODE) {
                if (item.getNodeName().equals(contentTagName)) {
                    return item.getTextContent();
                }
            }
        }
        return null;
    }
    /**
     * retrieve the validator for the given xsd file
     * @param xsdFilename
     * @return 
     */
    public static Validator getValidator(String xsdFilename){
        try {
            System.out.println(XMLparser.class.getClassLoader().getResource(xsdFilename));
            Source schemaFile = new StreamSource(XMLparser.class.getClassLoader().getResourceAsStream(xsdFilename));
            SchemaFactory factory = SchemaFactory.newInstance(XMLConstants.W3C_XML_SCHEMA_NS_URI);
            Schema schema = factory.newSchema(schemaFile);
            return schema.newValidator();
        } catch (SAXException ex) {
            System.out.println("ERROR: Can not find the specified xsd file " + xsdFilename + " to validate the XML file");
            Logger.getLogger(XMLparser.class.getName()).log(Level.SEVERE, null, ex);
            System.exit(1);
        }
        return null;
    }
    /**
     * check whether the xml file is valid according to the given validator
     * @param validator
     * @param xmlFile
     * @return 
     */
    public static boolean validate(Validator validator, String xmlFile){
        try {
            DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
            dbf.setNamespaceAware(true);
            DocumentBuilder db = dbf.newDocumentBuilder();
//            String location = Utils.locateFile(xmlFile, xTracker.folders);
//            Document doc = db.parse(location);
            Document doc = db.parse(xmlFile);
            doc.getDocumentElement().normalize();
            validator.validate(new DOMSource(doc));
        } catch (SAXException e) {
            // instance document is invalid!
            System.out.println("\n\nERROR - when validating the file " + xmlFile + "!");
            System.out.println(e.getMessage());
            return false;
        } catch (Exception e) {
            System.out.println("Exception while validating \n" + e);
            return false;
        }
        return true;
    }
}
