# isrsrv-script
Bash script for running Interstellar Rift on a linux server

-------------------------

# What does this script do?

This script creates a new non-sudo enabled user and installes the game in a folder called server in the user's home folder. It also installs systemd services for starting and shutting down the game server when the computer starts up, shuts down or reboots and also installs systemd timers so the script is executed on timed intervals (every 15 minutes) to do it's work like automatic game updates, backups and syncing from ramdisk to hdd. It will also create a config file in the script folder that will save the configuration you defined between the installation process. The reason for user creation is to limit the script's privliges so it CAN NOT be used with sudo when handeling the game server. Sudo is only needed for installing the script (for user creation) and installing packages (if the script supports the distro you are running).

-------------------------

**Features:**

- auto backups

- auto updates

- script logging

- auto restart if crashed

- delete old backups

- delete old logs

- run from ramdisk

- sync from ramdisk to hdd/ssd

- start on os boot

- shutdown gracefully on os shutdown

- script auto update from github (optional)

- send email notifications when SSK.txt near end of life (optional)

- send email notifications after 3 crashes within a 5 minute time limit (optional)

- send email notifications when server updated (optional)

- send email notifications on server startup (optional)

- send email notifications on server shutdown (optional)

- send discord notifications when SSK.txt near end of life or expired (optional)

- send discord notifications after 3 crashes within a 5 minute time limit (optional)

- send discord notifications when server updated (optional)

- send discord notifications on server startup (optional)

- send discord notifications on server shutdown (optional)

- supports multiple discord webhooks

-------------------------

# Supported distros

- Arch Linux

- Ubuntu 19.10

- Ubuntu 18.04 LTS

I will add suport for the next Ubuntu LTS version when it's released.

The script can, in theory run on any systemd-enabled distro. So if you are not using Arch Linux or Ubuntu 19.10 I suggest you check your distro's wiki on how to install the required packages. The script can, in theory install packages for any Ubuntu version, but the repositories for old versions of Ubuntu might have outdated packages and cause problems.

-------------------------

# WARNING

- Steam: A Steam username and password owning the game in question is needed to download all the needed files (workshop items and DLCs) and allow automated updates. If you want for automated updates for the game enabled you are advised to enable Steam 2 factor authentication via email because Steam Guard via phone will ask for the authentication password every time the script runs a function using SteamCMD and will brake certain functions. Your steam credentials will be stored in the script's configuration file. If you are not comfortable with this you can disable auto updates for the game and mods. You will be however required to manually log in to the server and manually update each time an update is released and each time you will be prompted to enter your Steam credentials wich will not be saved on the server.

- Script updates from GitHub: These may include malicious code to steal any info the script uses to work, like Steam and email credentials and discord webhooks.
Now I'm not saying that I'm that kind of person that would do that but:

**IF YOU DON'T TRUST ME, LEAVE THIS OFF FOR SECURITY REASONS!**

-------------------------

# Installation

**Required packages**

- xvfb

- rsync

- tmux (minimum version: 2.9a)

- wine (minimum version: 5.0)

- winetricks (minimum version: 20191224)

- steamcmd

- curl

- wget

- cabextract

- postfix (optional for email notifications)

- zip (optional but required if using the email feature)

-------------------------

**Download the script:**

Log in to your server with ssh and execute:

`git clone https://github.com/7thCore/isrsrv-script`

Make it executable:

`chmod +x ./isrsrv-script.bash`

The script will ask you for your steam username and password and will store it in a configuration file for automatic updates. Also if you have Steam Guard on your mobile phone activated, disable it because steamcmd always asks for the two factor authentication code and breaks the auto update feature. Use Steam Guard via email.

Sometime between the installation process you will be prompted for steam's two factor authentication code and after that steamcmd will not ask you for another code once it runs if you are using steam guard via email.

-------------------------

**Installation:**

If you wish you can have the script install the required packages with (Only for Arch Linux & Ubuntu 19.10):

`sudo ./isrsrv-script.bash -install_packages`

After that run the script with root permitions like so (necessary for user creation):

`sudo ./isrsrv-script.bash -install`

You can also install bash aliases to make your life easier by logging in to the newly created user and executing the script with the following command:

`./isrsrv-script.bash -install_aliases`

After the installation finishes log in to the newly created user and set `AutoSaveDelay` and `BackupSaveDelay` in server.json to `0` to disable the integrated saves and backups. The script will take care of saving and backups. This is required if using the script so the game won't save mid script-backup or sync from RamDisk to hdd/ssd. Also paste in your SSK.txt, fine tune your game configuration and then reboot the operating system and the service files will start the game server automaticly on boot. 

That should be it.

-------------------------

# Available commands:

| Command | Description |
| ------- | ----------- |
| `-help` | Prints a list of commands and their description |
| `-start` | Start the server |
| `-stop` | Stop the server |
| `-restart` | Restart the server |
| `-save` | Issue the save command to the server |
| `-sync` | Sync from tmpfs to hdd/ssd |
| `-backup` | Backup files, if server running or not |
| `-autobackup` | Automaticly backup files when server running |
| `-deloldbackup` | Delete old backups |
| `-delete_save` | Delete the server's save game with the option for deleting/keeping the server.json and SSK.txt files |
| `-change_branch` | Changes the game branch in use by the server (public,experimental,legacy and so on) |
| `-ssk_check` | Checks the SSK's creation/modification date and displays a warning if nearing expiration |
| `-ssk_install` | Installs new SSK.txt file. Your new SSK.txt needs to be in /home/$USER folder before using this |
| `-install_aliases` | Installs .bashrc aliases for easy access to the server tmux session |
| `-rebuild_tmux_config` | Reinstalls the tmux configuration file from the script. Usefull if any tmux configuration updates occoured |
| `-rebuild_commands` | Reinstalls the commands wrapper script if any updates occoured |
| `-rebuild_services` | Reinstalls the systemd services from the script. Usefull if any service updates occoured |
| `-rebuild_prefix` | Reinstalls the wine prefix. Usefull if any wine prefix updates occoured |
| `-disable_services` | Disables all services. The server and the script will not start up on boot anymore |
| `-enable_services` | Enables all services dependant on the configuration file of the script |
| `-reload_services` | Reloads all services, dependant on the configuration file |
| `-update` | Update the server, if the server is running it wil save it, shut it down, update it and restart it |
| `-update_script` | Check github for script updates and update if newer version available |
| `-update_script_force` | Get latest script from github and install it no matter what the version |
| `-status` | Display status of server |
| `-install` | Installs all the needed files for the script to run, the wine prefix, systemd services and timers and the game |
| `-install_packages` | Installs all the needed packages (Supports only Arch linux & Ubuntu 19.10 and onward) |

-------------------------

# Known issues:

| Issue | Resolution |
| ----- | ---------- |
| Ubuntu 18.04 LTS Support (Script can't enable services during installation) | This version of Ubuntu has a bug in it's systemd component, meaning the script CAN NOT enable the services required for the game to start up after boot. You will have to do this manually by rebooting the os and logging in with the username you designated at the beginning of the install procedure then execute the script with the `-enable_services` argument. |
