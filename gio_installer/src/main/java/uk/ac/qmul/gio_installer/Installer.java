package uk.ac.qmul.gio_installer;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FilenameFilter;
import java.io.IOException;
import java.io.InputStreamReader;
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
        System.out.println("Current path:" + properties.getProperty("user.dir"));
//        System.out.println(properties.getProperty("os.name"));
//        System.exit(0);
        CURRENT_PATH = properties.getProperty("user.dir");
        if (args.length > 0) {
            GALAXY_PATH = args[0];
        }
        new Installer();
    }

    public Installer() {
        locateGalaxyFolder();
        getRepository();
        modifyToolConfByFileOperation();
        moveFolders();
        checkExecutables();
        clear();
    }

    private void locateGalaxyFolder() {
        if (!checkGalaxyFolder()) {
            //if galaxy not located at the provided location, try the possible default installation folder
            if (GALAXY_PATH.length() == 0) {
                System.out.println("No galaxy path has been provided");
            } else {
                System.out.println("Galaxy has not been found at the provided path " + GALAXY_PATH);
            }
            System.out.println("Now trying to locate Galaxy at the default installation path");
            GALAXY_PATH = System.getProperties().getProperty("user.home") + "/galaxy-dist/";
            if (!checkGalaxyFolder()) {
                System.out.println("Galaxy has not been found at the guessed path " + GALAXY_PATH + " either. Please make sure galaxy has been installed or the correct path has been supplied to the installer");
                System.exit(1);
            }
        }
        System.out.println("Galaxy folder has been located");
    }

    private boolean checkGalaxyFolder() {
        File galaxy = new File(GALAXY_PATH);
        if (!galaxy.exists()) {
            return false;
        }
        File toolConfPath = new File(GALAXY_PATH + "/tool_conf.xml");
        if (!toolConfPath.exists()) {
            return false;
        }
        File universePath = new File(GALAXY_PATH + "/universe_wsgi.ini");
        if (!universePath.exists()) {
            return false;
        }
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

        ArrayList<String> fileLines = new ArrayList<String>();
        ArrayList<String> gioEntry = new ArrayList<String>();
        File wrappers = new File(CURRENT_PATH + "/gio-repository/wrappers/");
        for (String appName : wrappers.list()) {
            if (appName.startsWith(".")) {
                continue;//skip the hidden folder i.e. .svn or special folder
            }
            final String appFolder = CURRENT_PATH + "/gio-repository/wrappers/" + appName + "/";
            File appFolderFile = new File(appFolder);
            //put .loc.sample files into tool-data folder
            String[] locFiles = appFolderFile.list(new FilenameFilter() {
                public boolean accept(File dir, String name) {
                    if (name.endsWith(".loc.sample")) {
                        return true;
                    }
                    return false;
                }
            });
            for (String loc : locFiles) {
                try {
                    String cmd = "cp " + appFolder + loc + " " + GALAXY_PATH + "/tool-data/";
//                    System.out.println(cmd);
                    Process proc = Runtime.getRuntime().exec(cmd);
                    int value = proc.waitFor();
                } catch (IOException ex) {
                    Logger.getLogger(Installer.class.getName()).log(Level.SEVERE, null, ex);
                } catch (InterruptedException ex) {
                    Logger.getLogger(Installer.class.getName()).log(Level.SEVERE, null, ex);
                }
            }

            final File wrapper_entry = new File(appFolder + "/tool_conf_" + appName + ".xml");
            try {
                Scanner wrapper = new Scanner(wrapper_entry);
                while (wrapper.hasNextLine()) {
                    gioEntry.add(wrapper.nextLine());
                }
            } catch (FileNotFoundException ex) {
                Logger.getLogger(Installer.class.getName()).log(Level.SEVERE, null, ex);
            }
        }
        //gio entries have been extracted from the section xml files
        //then add those gio entries into the tool_conf.xml
        String filepath = GALAXY_PATH + "/tool_conf.xml";
        Scanner scanner = null;
        try {
            scanner = new Scanner(new File(filepath));
            String line = scanner.nextLine();
            fileLines.add(line);
            while (line.indexOf("toolbox") < 0) {
                line = scanner.nextLine();
                fileLines.add(line);
            }

            //be aware: currently line is <toolbox> and already put in the fileLines
            //add new gio entry into it
            fileLines.addAll(gioEntry);

            //remove the existing gio entry
            //locate the start line of a section
            line = scanner.nextLine();
            while (line.indexOf("<section") < 0) {
                line = scanner.nextLine();
            }
//            System.out.println("the expected first line of first section:"+line);
            //check whether it is one of gio sections
            while (line.indexOf("gio") > 0) {//gio has been installed before, remove the old section
                line = scanner.nextLine();
//                System.out.println("In gio:"+line);
                while (line.indexOf("/section") < 0) {
                    line = scanner.nextLine();
//                    System.out.println("locate the end of section:"+line);
                }
                line = scanner.nextLine();
                while (line.indexOf("<section") < 0) {
                    line = scanner.nextLine();
                }
            }
//            System.out.println("the very first line after gio section:"+line);
            fileLines.add(line);
//            System.out.println("new tool_conf.xml:\n");
//            for (String entry : fileLines) {
//                System.out.println(entry);
//            }
            //add remaining part in the tool_conf.xml
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
            System.out.println("Deleting the old version of GIO");
            //delete all old installation
            proc = Runtime.getRuntime().exec("rm -r " + GALAXY_PATH + "/tools/gio");
            proc.waitFor();
            proc = Runtime.getRuntime().exec("rm -r " + GALAXY_PATH + "/../gio_applications");
            proc.waitFor();
            proc = Runtime.getRuntime().exec("rm " + GALAXY_PATH + "tool-data/gio_*.loc");
            proc.waitFor();

            System.out.println("Changing permission for applications");
            //change permission to 775
            proc = Runtime.getRuntime().exec("chmod -R 775 " + CURRENT_PATH + "/gio-repository/applications/");
            proc.waitFor();
            System.out.println("Installing new version of GIO");
            //put the new version in
            proc = Runtime.getRuntime().exec("cp -r " + CURRENT_PATH + "/gio-repository/wrappers/ " + GALAXY_PATH + "/tools/gio");
            proc.waitFor();
            proc = Runtime.getRuntime().exec("cp -r " + CURRENT_PATH + "/gio-repository/applications/ " + GALAXY_PATH + "/../gio_applications");
            proc.waitFor();
        } catch (IOException ex) {
            Logger.getLogger(Installer.class.getName()).log(Level.SEVERE, null, ex);
        } catch (InterruptedException ex) {
            Logger.getLogger(Installer.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

    private void clear() {
        try {
            System.out.println("Clearing the temp files");
            Process proc = Runtime.getRuntime().exec("rm -r " + CURRENT_PATH + "/gio-repository");
            proc.waitFor();
            System.out.println("Installation completed");
        } catch (IOException ex) {
            Logger.getLogger(Installer.class.getName()).log(Level.SEVERE, null, ex);
        } catch (InterruptedException ex) {
            Logger.getLogger(Installer.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

    private void checkExecutables() {
        try {
            System.out.println("Test the platform compatibility for applications");
            String line;
            Process proc = Runtime.getRuntime().exec("perl " + CURRENT_PATH + "/gio-repository/checkGioExecutable.pl");
            BufferedReader bri = new BufferedReader(new InputStreamReader(proc.getInputStream()));
//            BufferedReader bre = new BufferedReader(new InputStreamReader(proc.getErrorStream()));
            while ((line = bri.readLine()) != null) {
                System.out.println(line);
            }
            bri.close();
//            while ((line = bre.readLine()) != null) {
//                System.out.println(line);
//            }
//            bre.close();
            proc.waitFor();
        } catch (IOException ex) {
            Logger.getLogger(Installer.class
                    .getName()).log(Level.SEVERE, null, ex);
        } catch (InterruptedException ex) {
            Logger.getLogger(Installer.class
                    .getName()).log(Level.SEVERE, null, ex);
        }
    }
}
