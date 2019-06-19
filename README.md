# isrsrv-script
Bash script for running Interstellar Rift on a linux server

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

**Instructions:**

Log in to your server with ssh and execute:

wget https://raw.githubusercontent.com/7thCore/isrsrv-script/master/isrsrv-script.bash

Before doing anything edit the script and input your steam username and password for the auto update feature to work. The variables for it are located at the very top of the script. Also if you have Steam Guard on your mobile phone activated, disable it because steamcmd always asks for the two factor authentication code and breaks the auto update feature. Use Steam Guard via email.

Also if you plan to use a ramdisk change the variable:

TMPFS_ENABLE="0"

to

TMPFS_ENABLE="1"

Run steamcmd and login with your account at least once to enter the first two factor authentication code and after that steamcmd will not ask you for another code once it runs.


steamcmd login username password


Now for the installation.

First use the -install argument (run only this command as root) and follow the instructions Second, run the -install_services argument. It will install the services for the server.

Reboot the server. Log back in with "ssh -Y user@host" without quotes to enable X11 forwarding.

Now run the -install-prefix argument. It will install the wine prefix. There will be a lot of GUI interaction involved.
Also when the uninstaller shows up remove everything related to mono.

Lastly you can run the script with the -update argument to install the game. Your server configuration file and SSK should be put in /path/to/prefix/drive_c/users/your_username/Application Data/InterstellarRift/ When all of this is done copy/move this script to the script folder.

Set "AutoSaveDelay" and "BackupSaveDelay" to something ridiculous like 31556926.0 wich is a year. The script will take care of saving and backups. This is required is using the script so the game won't save mid script-backup or sync from RamDisk to hdd/ssd.

After that enable the correct service with:

systemctl --user enable isrsrv.service

or for the RamDisk variant

systemctl --user enable isrsrv-tmpfs.service

USE ONLY ONE!

Now start the service with:

systemctl --user start isrsrv.service

or again for the RamDisk variant

systemctl --user start isrsrv-tmpfs.service

That should be it.

**Known issues are:**
-If typing uppercase letters and symbols in the server console the server crashes. To avoid crashes use lowercase letters and use ID codes for user specific commands.

-if for some reason systemd reports the service failed when it stops, don't worry about it, the IsR server session shuts down gracefully.
