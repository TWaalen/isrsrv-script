Update 2020-09-26

- fixed commands script
- fixed commands script service
- fixed log generation
- fixed isr service not running with proper tmux config
- added seperate tmux config for commands script

-------------------------

Update 2020-07-22

- fixed systemd service bugs

Existing users need to stop the server and rebuild the service files with -rebuild_services

-------------------------

Update 2020-07-10

- added log files generation about wine errors
- tmux config will now be auto generated before service start and deleted after service stop. No rebuilds required for tmux

Existing users need to stop the server with systemctl --user stop isrsrv-tmpfs.service or isrsrv.service
Existing users need to update the script and execute the following paramerers to rebuild updated functions:

- -rebuild_services

-------------------------

Update 2020-06-18

- added Debian 10 (Buster) support
- added error message if trying to install packages on non supported distro
- fixed a problem with the game and save not being backed up and restored when rebuilding prefix
- fixed the detection function for "Galaxy is already saving". The server will be restarted now if it detects this.

-------------------------

Update 2020-05-06

- fixed save function not restarting the server if the infinite save bug is detected
- fixed ssk check function not sending email and discord message if ssk expires

-------------------------

Update 2020-05-02

- updated Ubuntu 20.04 LTS support (wine repo)
- fixed save function to correctly detect galaxy already saving bug

-------------------------

Update 2020-04-24

- added Ubuntu 20.04 LTS support
- added -diag argument for quick and easy basic script diagnostics
- added -verify argument for server files verification
- added -start_no_err argument for starting a server in failed state without prompts 

-------------------------

Update 2020-04-05

- added multi-instance support for commands wrapper script
- added SSK monitor tool to monitor the server console for SSK notifications
- added SSK monitor and save function timeout configurations to script config file
- fixed enable and disable services function
- fixed tmux rebuild function

-------------------------

Update 2020-04-04

- added multi-instance support
- added -add_server argumant to add more server instances
- added -remove_server argument to remove server instances

-------------------------

Update 2020-03-26

- fixed config file generation during installation for email and discord notifications

-------------------------

Update 2020-03-01

- fixed script log deletion
- added game log deletion for logs that are 14 days old, this can be configured in the config file
- added game dump deletion for dump files that are 14 days old, this can be configured in the config file
- fixed AlunaCrashHandler.exe detection

-------------------------

Update 2020-02-27

- fixed permissions issue when using -install function
- fixed -install_packages function overriding ubuntu sources.list file
- added ubuntu version detection to -install_packages function
- added -attach argument to script to attach to tmux session of server
- removed all aliases and added alias isrsrv that points to the script

-------------------------

Update 2020-02-10

- updated -install_packages function

-------------------------

Update 2020-02-05

- fixed -help asking for username and thinking it's in installation mode
- fixed Arch Linux package installation
- modified script displaying configuration is missing in installation mode

-------------------------

Update 2020-02-03

- added support for Ubuntu 18.04 (see known issues)
- reworked script log functions (create log structure and delete)
- cleaned up old script enabled functions (not used anymore)

-------------------------

Update 2020-01-31

- fixed some username examples being displayed wrong

-------------------------

Update 2020-01-31

- fixed check if multiple script instances running
- fixed check for executing functions/arguments to allow notification sending 
- fixed manual update steamcmd call

-------------------------

Update 2020-01-30

- added check for executing functions/arguments to only allow -install and -install_packages functions to be allowed to run with sudo or as root
- added check for executing functions/arguments to allow notification sending functions to run along side another instance of the script
- added warning to readme and the script for the update script from github function for security reasons
- added warning to readme about the script storing steam credentials
- added option to not store steam credentials (users will have to manually trigger updates and enter the credentials each time)

-------------------------

Update 2020-01-21

- fixed start function not allowing start if server crashed or failed before
- start function will now ask if the user wishes to start the server even if it crashed earlier

-------------------------

Update 2020-01-15

- added config file check (adds missing settings to the config file if script introduces new configurable features)
- fixed multiple rebuild functions not properly detecting if the server is running and not allowing rebuilds

-------------------------

Update 2020-01-14

- removed old script updating code
- fixed rebuild_prefix function
- fixed script update function (bug when multiple servers/scripts are updating at the same time)

-------------------------

Update 2020-01-13

- fixed discord configuration in installation (was displaying email instead of discord)
- integrated update script to the script itself

-------------------------

Update 2020-01-09

- fixed -install_packages function. Said function was not detecting the distro correctly and in turn not installing the required packages.

-------------------------

Update 2020-01-08

- added minimal discord integration. The script can now send messages using the discord webhook api on events like crashes, game updates, server startup and shutdown and SSK notifications. Server admins can use multiple webhooks if they so desire.

-------------------------

Update 2019-12-24

- added enable services function (to enable all services to run the server, read from the config file)
- added disable services function (to disable all services to run the server, the server will not startup automaticly anymore)
- added reload services function (disables, reloads and re-enables the services. Usefull if switching from a ramdisk to a hdd or vice-versa)

-------------------------

Update 2019-11-24

- fixed rebuild functions printing out wrong information
- fixed force update function in the update script (updates main script from github)

Existing users need to stop the server with systemctl --user stop isrsrv-tmpfs.service or isrsrv.service
Existing users need to update the script and execute the following paramerers to rebuild updated functions:

- -rebuild_services

-------------------------

Update 2019-11-11

- small systemd service changes
- added SSK replace function for easy SSK replacement/installation. The new SSK needs to be pasted in the home folder and then the script executed with the required argument (execute the script with the -help argument for more info) 
- fixed a problem with the script detecting a failed steamcmd login
- added function to implement command aliases for ease of use (execute the script with the -help argument for more info)
- added backups and logs deletion/how old backups get deleted in days to config file 

Existing users need to stop the server with systemctl --user stop isrsrv-tmpfs.service or isrsrv.service
Existing users need to update the script and execute the following paramerers to rebuild updated functions:

- -rebuild_services

-------------------------

Update 2019-01-11

- fixed package installation for arch linux. No rebuilds required.

-------------------------

Update 2019-10-26

- added a function to detect a failed steam login and ask the user for their credentials again
- added the commands wrapper script
- added a function for auto installation of required packages (only for Arch Linux & Ubuntu 19.10 and onward)

-------------------------

Update 2019-10-14

- fixed a bug when typing symbols or caps in the server console it would crash it (Credit goes to the Split Polygon Dev Team).

Existing users need to stop the server with systemctl --user stop isrsrv-tmpfs.service or isrsrv.service
Existing users need to update the script and execute the following paramerers to rebuild updated functions:

- -rebuild_services

-------------------------

Update 2019-08-10

- fixed a few bugs in the systemd service files and added a new service for piping the console output to multiple processes

Existing users need to stop the server with systemctl --user stop isrsrv-tmpfs.service or isrsrv.service
Existing users need to update the script and execute the following paramerers to rebuild updated functions:

- -rebuild_services

-------------------------

Update 2019-10-05

- migrated from screen to tmux due to some limitations in screen.

Existing users need to stop the server with systemctl --user stop isrsrv-tmpfs.service or isrsrv.service
Existing users need to install tmux
Existing users need to update the script and execute the following paramerers to rebuild updated functions:

- -rebuild_services
- -rebuild_tmux_config

-------------------------

Update 2019-09-13

- modified service files (for ramdisk) so the mkdir service starts before the main service (if the main is executed by the user himself or the systemd service daemon)

Existing users need to update the script and execute the following paramerers to rebuild updated functions:

- -rebuild_services argument

-------------------------

Update 2019-09-10

- fixed a problem with service files.
- fixed script being encoded in dos encoding

Existing users need to update the script and execute the following paramerers to rebuild updated functions:

- -rebuild_services argument

-------------------------

Update 2019-07-09

- fixed a problem with service files on ubuntu.

Existing users need to update the script and execute the following paramerers to rebuild updated functions:

- -rebuild_services argument

-------------------------

Update 2019-08-20

- fixed script execution when service inactive
- fixed delete old backup function so now it actually deletes empty folders and old files
- removed systemd interaction with the script/editing it (systemd turned the script on and off), the script will now check itself if the services are running, if not it will just stand by
- added rebuild commands/arguments for the wine prefix, systemd services and the update script (the script that auto updates the main script from github) so if i update any of those the users/server admins don't have to reinstall the whole thing
- added functions to the update script so users can either check for updates, or issue a force update to download/redownload the main script. The update script will check for updates on github once a day automaticly (users will get to decide to turn this feature on or off when installing the script)

Existing users need to update the script and execute the following parameters to rebuild updated functions:

- -rebuild_update_script
- -rebuild_services
