# isrsrv-script
Bash script for running Interstellar Rift on a linux server

**Required packages**

-xvfb

-tmux

-wine

-winetricks

-steamcmd

-postfix (optional for email notifications)

-zip (optional but required if using the email feature)

**Features:**

-auto backups

-auto updates

-script logging

-auto restart if crashed

-delete old backups

-delete old logs

-run from ramdisk

-sync from ramdisk to hdd/ssd

-start on os boot

-shutdown gracefully on os shutdown

-script auto update from github (optional)

-send email notifications when SSK.txt near end of life (optional)

-send email notifications after 3 crashes within a 5 minute time limit (optional)

-send email notifications when server updated (optional)

**Instructions:**

Log in to your server with ssh and execute:

git clone https://github.com/7thCore/isrsrv-script

Make it executable:

chmod +x ./isrsrv-script.bash

The script will ask you for your steam username and password and will store it in a configuration file for automatic updates. Also if you have Steam Guard on your mobile phone activated, disable it because steamcmd always asks for the two factor authentication code and breaks the auto update feature. Use Steam Guard via email.

If you plan on using a ramdisk to run your server from, the script will give you that option.

Sometime between the installation process you will be prompted for steam's two factor authentication code and after that steamcmd will not ask you for another code once it runs if you are using steam guard via email.

Now for the installation.

If you wish you can have the script install the required packages with (Only for Arch Linux & Ubuntu 19.10):

sudo ./isrsrv-script.bash -install_packages

After that run the script with root permitions like so (necessary for user creation):

sudo ./isrsrv-script.bash -install

The script will create a new non-sudo enabled user from wich the game server will run. If you want to have multiple game servers on the same machine just run the script multiple times but with a diffrent username inputted to the script.


Set "AutoSaveDelay" and "BackupSaveDelay" in server.json to 0 to disable the integrated saves and backups. The script will take care of saving and backups. This is required if using the script so the game won't save mid script-backup or sync from RamDisk to hdd/ssd.

After that paste in you SSK.txt and then reboot the server. After that the game should start on boot.

That should be it.

**Known issues are:**

-Wine version 4.12 and later are fubar. Use 4.11 or lower. (This should be solved, report any problems regarding this)

~~-The winetricks package in ubuntu is outdated. Follow this guide to install the latest winetricks: https://wiki.winehq.org/Winetricks (needed for dotnet472)~~

-If typing uppercase letters and symbols in the server console the server crashes. To avoid crashes use lowercase letters and use ID codes for user specific commands. (This should be solved)

-If for some reason systemd reports the service failed when it stops, don't worry about it, the server session shuts down gracefully. (This should be solved)
