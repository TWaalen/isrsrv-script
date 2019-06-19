# isrsrv-script
Bash script for running Interstellar Rift on a linux server

Features:

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

Before doing anything edit the script and input your steam username and password for the auto update feature to work.
The variables for it are located at the very top of the script.
Also if you have Steam Guard on your mobile phone activated, disable it because steamcmd always asks for the
two factor authentication code and breaks the auto update feature. Use Steam Guard via email.
Run steamcmd and login with your account once to enter the first two factor authentication code and after that
steamcmd will not ask you for another code once it runs.

First use the -install argument (run only this command as root) and follow the instructions
Second, run the -install_services argument. It will install the services for the server.

Reboot the server.
Log back in with "ssh -Y user@host" without quotes to enable X11 forwarding.

Now run the -install-prefix argument. It will install the wine prefix. There will be a lot of GUI interaction involved.
Lastly you can run the script with the -update argument to install the game.
Your server configuration file and SSK should be put in /path/to/prefix/drive_c/users/your_username/Application Data/InterstellarRift/
When all of this is done copy/move this script to the script folder.

After that enable the correct service with: systemctl --user enable isrsrv.service or"
systemctl --user enable isrsrv-tmpfs.service for the RamDisk variant (USE ONLY ONE!)
Now start the service with systemctl --user start isrsrv.service or systemctl --user start isrsrv-tmpfs.service

That should be it.
