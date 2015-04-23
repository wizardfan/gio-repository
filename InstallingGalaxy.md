GIO has been developed based on the Galaxy platform, so you must have Galaxy installed to use it. For completeness, instructions for installing and setting up Galaxy are provided below. These instructions have been tested on **Ubuntu**, but should be similar on other Linux-based operating systems.

  1. Install Galaxy: follow [the tutorial](http://wiki.galaxyproject.org/Admin/Get%20Galaxy) to install it.
  1. Run Galaxy for the first time to generate necessary system files.
  1. Within Galaxy, create an account for yourself by clicking on **User** in the bar at the top and then clicking **Register** in the menu that appears.
  1. Stop Galaxy (by pressing Ctrl-C in the terminal window that you used to launch Galaxy), and make the following changes to the Galaxy configuration file (_config/galaxy.ini_) in the Galaxy root folder (_galaxy-dist_).
    * Enable Galaxy over your network (optional): uncomment and change the host setting to **host = 0.0.0.0**
    * Add yourself as an admin user: uncomment and change the admin\_users setting to include the email address that you registered in Step 3, e.g. **admin\_users = w.moreland@example.com** [More details](http://wiki.galaxyproject.org/Admin/Interface)
    * Allow access to Galaxy Tool Shed: uncomment and change the tool\_config\_file setting so that it reads **tool\_config\_file = tool\_conf.xml,shed\_tool\_conf.xml** [More details](http://wiki.galaxyproject.org/InstallingRepositoriesToGalaxy#Installing_Galaxy_tool_shed_repository_tools_into_a_local_Galaxy_instance)