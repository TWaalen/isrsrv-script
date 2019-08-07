# isrsrv-script
Bash script for running Interstellar Rift on a linux server

**Required packages**

-xvfb

-screen

-wine

-winetricks

-steamcmd

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

-script auto update from github

**Instructions:**

Log in to your server with ssh and execute:

wget https://raw.githubusercontent.com/7thCore/isrsrv-script/master/isrsrv-script.bash

Before doing anything edit the script and input your steam username and password for the auto update feature to work. The variables for it are located at the very top of the script. Also if you have Steam Guard on your mobile phone activated, disable it because steamcmd always asks for the two factor authentication code and breaks the auto update feature. Use Steam Guard via email.

Also if you plan to use a ramdisk change the variable:

TMPFS_ENABLE="0"

to

TMPFS_ENABLE="1"

Sometime between the insallation process you will be prompted for steam's two factor authentication code and after that steamcmd will not ask you for another code once it runs if you are using steam guard via email.

Now for the installation.

First use the -install argument (run only this command as root) and follow the instructions.

Set "AutoSaveDelay" and "BackupSaveDelay" in server.json to 0 to disable the integrated saves and backups. The script will take care of saving and backups. This is required is using the script so the game won't save mid script-backup or sync from RamDisk to hdd/ssd.

After that paste in you SSK.txt and then reboot the server. After that the game should start on boot.

That should be it.

**Known issues are:**
-If typing uppercase letters and symbols in the server console the server crashes. To avoid crashes use lowercase letters and use ID codes for user specific commands.
