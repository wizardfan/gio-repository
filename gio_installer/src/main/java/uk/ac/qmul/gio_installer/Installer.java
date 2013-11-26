package uk.ac.qmul.gio_installer;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FilenameFilter;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.Properties;
import java.util.Scanner;
import java.util.logging.Level;
import java.util.logging.Logger;

public class Installer {

    private final static String SECTION_NAME = "Galaxy Integrated Omics";
    private final static String SECTION_ID = "gio";
    private static String GALAXY_PATH = "";
    private static String CURRENT_PATH = "";

    public static void main(String[] args) {
//        GenerateDocument gd = new GenerateDocument("C:\\gio-repository\\trunk\\wrappers");
//        gd.execute();
//        System.exit(0);
        Properties properties = System.getProperties();
//        System.out.println(properties);
//        Enumeration<Object> names = properties.keys();
//        while(names.hasMoreElements()){
//            Object name = names.nextElement();
//            System.out.println(name+": "+properties.get(name));
//        }
//        System.out.println(properties.getProperty("user.home"));
        System.out.println("Current path:"+properties.getProperty("user.dir"));
//        System.out.println(properties.getProperty("os.name"));
//        System.exit(0);
        CURRENT_PATH = properties.getProperty("user.dir");
        if(args.length > 0){
            GALAXY_PATH = args[0];
        }
        new Installer();
    }

    public Installer() {
        locateGalaxyFolder();
        getRepository();
        modifyToolConfByFileOperation();
        moveFolders();
        System.out.println("Installation finished.");
        clear();
    }

    private void locateGalaxyFolder() {
        if(!checkGalaxyFolder()){
            //if galaxy not located at the provided location, try the possible default installation folder
            if(GALAXY_PATH.length()==0){
                System.out.println("No galaxy path has been provided");
            }else{
                System.out.println("Galaxy has not been found at the provided path "+GALAXY_PATH);
            }
            System.out.println("Now trying to locate Galaxy at the default installation path");
            GALAXY_PATH = System.getProperties().getProperty("user.home")+"/galaxy-dist/";
            if(!checkGalaxyFolder()) {
                System.out.println("Galaxy has not been found at the guessed path "+GALAXY_PATH+" either. Please make sure galaxy has been installed or the correct path has been supplied to the installer");
                System.exit(1);
            }
        }
        System.out.println("Galaxy folder has been located");
    }
    
    private boolean checkGalaxyFolder(){
        File galaxy = new File(GALAXY_PATH);
        if(!galaxy.exists()) return false;
        File toolConfPath = new File(GALAXY_PATH + "/tool_conf.xml");
        if(!toolConfPath.exists())return false;
        File universePath = new File(GALAXY_PATH + "/universe_wsgi.ini");
        if(!universePath.exists())return false;
        return true;
    }

    private void getRepository() {
        System.out.println("Checking out the latest version of gio_repository. This process could take a while, please be patient.");
        File delme = new File(CURRENT_PATH);
        try {
            Process proc = Runtime.getRuntime().exec("svn checkout https://gio-repository.googlecode.com/svn/trunk/ gio-repository", null, delme);
            int value = proc.waitFor();
//            System.out.println(value);
        } catch (IOException ex) {
            Logger.getLogger(Installer.class.getName()).log(Level.SEVERE, null, ex);
        } catch (InterruptedException ex) {
            Logger.getLogger(Installer.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

    private void modifyToolConfByFileOperation() {
        System.out.println("Checking out finished.");
        System.out.println("Start to install");
        String filepath = GALAXY_PATH+"/tool_conf.xml";
//        String filepath = "tool_conf.xml";
//        File file = new File(filepath);
//        System.out.println(file.getAbsolutePath());
        ArrayList<String> fileLines = new ArrayList<String>();
        ArrayList<String> gioEntry = new ArrayList<String>();
        String section = "  <section name=\""+SECTION_NAME+"\" id=\""+SECTION_ID+"\">";
        gioEntry.add(section);
        File wrappers = new File(CURRENT_PATH+"/gio-repository/wrappers/");
        for(String appName:wrappers.list()){
            if(appName.startsWith(".")) continue;//skip the hidden folder i.e. .svn or special folder
            final String appFolder = CURRENT_PATH+"/gio-repository/wrappers/"+appName+"/";
            File appFolderFile = new File(appFolder);
            String[] locFiles = appFolderFile.list(new FilenameFilter() {
                public boolean accept(File dir, String name) {
                    if(name.endsWith(".loc.sample")) return true;
                    return false;
                }
            });
            for(String loc:locFiles){
                try {
                    String cmd = "cp "+appFolder+loc+" "+GALAXY_PATH+"/tool-data/";
//                    System.out.println(cmd);
                    Process proc = Runtime.getRuntime().exec(cmd);
                    int value = proc.waitFor();
                } catch (IOException ex) {
                    Logger.getLogger(Installer.class.getName()).log(Level.SEVERE, null, ex);
                } catch (InterruptedException ex) {
                    Logger.getLogger(Installer.class.getName()).log(Level.SEVERE, null, ex);
                }
            }

            final File wrapper_entry = new File(appFolder+"/tool_conf_"+appName+".xml");
            try {
                Scanner wrapper = new Scanner(wrapper_entry);
                while(wrapper.hasNextLine()){
                    gioEntry.add(wrapper.nextLine());
                }
            } catch (FileNotFoundException ex) {
                Logger.getLogger(Installer.class.getName()).log(Level.SEVERE, null, ex);
            }
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

    private void moveFolders() {
//        File delme = new File(CURRENT_PATH);
        try {
            Process proc;
            System.out.println("Deleting the old version of gio");
            //delete all old installation
            proc = Runtime.getRuntime().exec("rm -r "+GALAXY_PATH+"/tools/gio");
            proc.waitFor();
            proc = Runtime.getRuntime().exec("rm -r "+GALAXY_PATH+"/../gio_applications");
            proc.waitFor();
            final String cmd = "rm "+GALAXY_PATH+"tool-data/gio_*.loc";
            System.out.println("Check out: "+cmd);
            proc = Runtime.getRuntime().exec(cmd);
            proc.waitFor();
            System.out.println("Permission changed");
            //change permission to 775
            proc = Runtime.getRuntime().exec("chmod -R 775 "+CURRENT_PATH+"/gio-repository/applications/");
            proc.waitFor();
            //put the new version in
            final String cmd1 = "cp -r "+CURRENT_PATH+"/gio-repository/wrappers/ "+GALAXY_PATH+"/tools/gio";
//            System.out.println(cmd);
            proc = Runtime.getRuntime().exec(cmd1);
            int value = proc.waitFor();
//            System.out.println(value);
            proc = Runtime.getRuntime().exec("cp -r "+CURRENT_PATH+"/gio-repository/applications/ "+GALAXY_PATH+"/../gio_applications");
            proc.waitFor();
        } catch (IOException ex) {
            Logger.getLogger(Installer.class.getName()).log(Level.SEVERE, null, ex);
        } catch (InterruptedException ex) {
            Logger.getLogger(Installer.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

    private void clear(){
        try {
            System.out.println("Clearing the temp files");
            Process proc = Runtime.getRuntime().exec("rm -r "+CURRENT_PATH+"/gio-repository");
            proc.waitFor();
            System.out.println("Installation completed");
        } catch (IOException ex) {
            Logger.getLogger(Installer.class.getName()).log(Level.SEVERE, null, ex);
        } catch (InterruptedException ex) {
            Logger.getLogger(Installer.class.getName()).log(Level.SEVERE, null, ex);
        }
    }
}
