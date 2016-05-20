## Introduction
Galaxy-based Integrated Omics (GIO) is a curated collection of tools and associated wrappers brought together to allow the integration of different types of omic data. In the first instance we are supporting the Proteomics Informed by Transcriptomics (PIT) workflow described in [Evans et al. 2012](http://www.ncbi.nlm.nih.gov/pubmed/23142869).

A public instance of GIO, together with some tutorials, is available at [gio.sbcs.qmul.ac.uk](http://gio.sbcs.qmul.ac.uk). **We strongly recommend that you use this public server unless you have special requirements**, as installing GIO on your computing facilities is a multi-step process requiring a certain level of computing expertise.

## Installing GIO
Rather than installing individual tools and adding wrappers via the Galaxy Tool Shed, GIO has been designed to allow installation of the entire collection of tools via a simple Java application, so you can get up and running as quickly as possible without worrying about sourcing tools and fixing dependencies.

Installation instructions are provided below. These instructions assume that you already have Galaxy installed and have admin access to that installation. If you do not already have Galaxy, we provide brief instructions for this [here](../wiki/InstallingGalaxy.md).

  1. Install proteomics datatypes via Galaxy Tool Shed ([more details](http://wiki.galaxyproject.org/InstallingRepositoriesToGalaxy#Installing_Galaxy_tool_shed_repository_tools_into_a_local_Galaxy_instance)):
    * Log in as the administrator (i.e. using the email set up in the previous step) through the User link at the top of the middle panel
    * Click the **Admin** link 
    * Click the **Search and browse tool sheds** link in the middle of the left panel
    * Select Galaxy main tool shed
    * In the search box, search "datatypes", click proteomics_datatypes from the search result, then click Preview and Install
    * Click Install to Galaxy
    * Click Install button again and job done.
    * Quit Galaxy (by pressing Ctrl-C in the terminal window you used to open it)
  2. Make sure git is installed by typing the command "git". If not, to install git, type "sudo apt-get install git" and follow the instructions.
  3. Make sure java is installed as well, if not, type the command "sudo apt-get install default-jre"
  4. Download [this jar file version May 2016](https://github.com/wizardfan/gio_installer/blob/master/gio_installer-180516.jar?raw=true) to your hard drive (we recommend you put it in a newly created folder). At the command line, enter the folder and execute the jar file with the command `java -jar gio_installer-<version>.jar`. If you did not install Galaxy in its default folder, you can supply the folder name by using `java -jar gio_installer-<version>.jar /your/galaxy/folder`. The Java program will install GIO automatically.
  6. Start Galaxy. If installation was successful, you will see the **Galaxy Integrated Omics** collection of tools in the tools panel on the left panel of the Galaxy window.

Though gio-installer is designed to be as automatic as possible, it is currently necessary to install some tools separately, particularly those tools requiring locally installed databases/data. Please check the following instructions for these tools:
  * [MS-GF+ based](../wiki/setup/SetupMSGFplus.md): MSGFplus
  * [GMAP based](../wiki/setup/SetupGMAP.md): GMAP
  * [BLAST based](../wiki/setup/SetupBLAST.md): Species Finding

## Updating GIO
New tools are added from time to time. To keep your local GIO toolset up-to-date, simply repeat step 4 above and restart the Galaxy server. Any pre-existing GIO installation will be overwritten, but other tools, data etc. will be unaffected.

## Using GIO
A list of current tools and descriptions of these can be found [here](../wiki/tool_document.md). More accessible tutorials can be found at [gio.sbcs.qmul.ac.uk](http://gio.sbcs.qmul.ac.uk).

## Acknowledgements ##
GIO is a collaboration between [Conrad Bessant's lab](http://www.bessantlab.org) at Queen Mary, University of London and [David Matthews](http://www.bristol.ac.uk/cellmolmed/research/infect-immune/matthews.html) at the University of Bristol. Jun Fan is lead developer. The project is supported by BBSRC (project number BB/K016075/1).

As well as novel codes, GIO will include a number of already existing tools produced by other groups. We will acknowledge these groups in full here when the list of tools is stable.
