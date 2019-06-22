#!/bin/bash

#Interstellar Rift server script by 7thCore
#If you do not know what any of these settings are you are better off leaving them alone. One thing might brake the other if you fiddle around with it.
#Leave this variable alone, it is tied in with the systemd service file so it changes accordingly by it.
SCRIPT_ENABLED="0"

#Basics
NAME="IsRSrv" #Name of the screen
USER="$(whoami)" #Get user's username

#Steamcmd login
STEAMCMDUID="user" #Your steam username
STEAMCMDPSW="password" #Your steam password
APPID="363360" #app id of the steam game

#Server configuration
SERVICE_NAME="isrsrv" #Name of the service files, script and script log
SRV_DIR_NAME="interstellar_rift" #Main directory name
SRV_DIR="/home/$USER/servers/$SRV_DIR_NAME/server" #Location of the server located on your hdd/ssd
SCRIPT_NAME="$SERVICE_NAME-script.bash" #Script name
SCRIPT_DIR="/home/$USER/servers/$SRV_DIR_NAME/scripts" #Location of this script
UPDATE_DIR="/home/$USER/servers/$SRV_DIR_NAME/updates" #Location of update information for the script's automatic update feature

#Wine configuration
WINE_ARCH="win32" #Architecture of the wine prefix
WINE_PREFIX_GAME_DIR="drive_c/Games/InterstellarRift" #Server executable directory
WINE_PREFIX_GAME_EXE="Build/IR.exe -server -inline" #Server executable

#Ramdisk configuration
TMPFS_ENABLE="0" #Set this to 1 if you want to run the server on a ramdisk
TMPFS_DIR="/home/$USER/tmpfs/$SRV_DIR_NAME" #Locaton of your ramdisk. Note: you have to configure the ramdisk in /etc/fstab before using this.

#TmpFs/hdd variables
if [[ "$TMPFS_ENABLE" == "1" ]]; then
	BCKP_SRC_DIR="$TMPFS_DIR/drive_c/users/$USER/Application Data/InterstellarRift/" #Application data of the tmpfs
	SERVICE="$SERVICE_NAME-tmpfs.service" #TmpFs service file name
elif [[ "$TMPFS_ENABLE" == "0" ]]; then
	BCKP_SRC_DIR="$SRV_DIR/drive_c/users/$USER/Application Data/InterstellarRift/" #Application data of the hdd/ssd
	SERVICE="$SERVICE_NAME.service" #Hdd/ssd service file name
fi

#Backup configuration
BCKP_SRC="*" #What files to backup, * for all
BCKP_DIR="/home/$USER/servers/$SRV_DIR_NAME/backups" #Location of stored backups
BCKP_DEST="$BCKP_DIR/$(date +"%Y")/$(date +"%m")/$(date +"%d")" #How backups are sorted, by default it's sorted in folders by month and day
BCKP_DELOLD="+3" #Delete old backups. Ex +3 deletes 3 days old backups.

#Log configuration
LOG_DIR="/home/$USER/servers/$SRV_DIR_NAME/logs/$(date +"%Y")/$(date +"%m")/$(date +"%d")/"
LOG_SCRIPT="$LOG_DIR/$SERVICE_NAME-script.log" #Script log
LOG_TMP="/tmp/$SERVICE_NAME-screen.log"
LOG_DELOLD="+14" #Delete old logs. Ex +14 deletes 14 days old logs.

#-------Do not edit anything beyond this line-------

#Console collors
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
LIGHTRED='\033[1;31m'
NC='\033[0m'

#Deletes old logs
script_logs() {
	#If there is not a folder for today, create one
	if [ ! -d "$LOG_DIR" ]; then
		mkdir -p $LOG_DIR
	fi
	echo "$(date +"%Y-%m-%d %H:%M:%S") [$NAME] [INFO] (Delete old logs) Deleting old logs: $LOG_DELOLD days old." | tee -a  "$LOG_SCRIPT"
	# Delete old logs
	find $LOG_DIR -mtime $LOG_DELOLD -exec rm {} \;
	# Delete empty folders
	find $LOG_DIR -type d 2> /dev/null -empty -exec rm -rf {} \;
	echo "$(date +"%Y-%m-%d %H:%M:%S") [$NAME] [INFO] (Delete old logs) Deleting old logs complete." | tee -a  "$LOG_SCRIPT"
}

#Prints out if the server is running
script_status() {
	if [[ "$(systemctl --user show -p ActiveState --value $SERVICE)" != "active" ]]; then
		echo "$(date +"%Y-%m-%d %H:%M:%S") [$NAME] [INFO] (Status) Server is not running." | tee -a  "$LOG_SCRIPT"
	elif [[ "$(systemctl --user show -p ActiveState --value $SERVICE)" == "active" ]]; then
		echo "$(date +"%Y-%m-%d %H:%M:%S") [$NAME] [INFO] (Status) Server running." | tee -a  "$LOG_SCRIPT"
	fi
}

#If the script variable is set to 0, the script won't issue any commands ran. It will just exit.
script_enabled() {
	if [[ "$SCRIPT_ENABLED" == "0" ]]; then
		echo "$(date +"%Y-%m-%d %H:%M:%S") [$NAME] [INFO] (Script status) Server script is disabled" | tee -a  "$LOG_SCRIPT"
		script_status
		exit 0
	fi
}

script_crash_kill() {
	if [[ "$(ps aux | grep -i "[A]lunaCrashHandler.exe" | awk '{print $2}')" -gt "0" ]]; then
		echo "$(date +"%Y-%m-%d %H:%M:%S") [$NAME] [INFO] (Aluna Crash Handler) AlunaCrashHandler.exe detected. Killing the process." | tee -a  "$LOG_SCRIPT"
		kill $(ps aux | grep -i "[A]lunaCrashHandler.exe" | awk '{print $2}')
		if [[ "$(ps aux | grep -i "[A]lunaCrashHandler.exe" | awk '{print $2}')" -eq "" ]]; then
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$NAME] [INFO] (Aluna Crash Handler) AlunaCrashHandler.exe process killed." | tee -a  "$LOG_SCRIPT"
		elif [[ "$(ps aux | grep -i "[A]lunaCrashHandler.exe" | awk '{print $2}')" -gt "0" ]]; then
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$NAME] [INFO] (Aluna Crash Handler) Failed to kill AlunaCrashHandler.exe process." | tee -a  "$LOG_SCRIPT"
		fi
	elif [[ "$(ps aux | grep -i "[A]lunaCrashHandler.exe" | awk '{print $2}')" -eq "" ]]; then
		echo "$(date +"%Y-%m-%d %H:%M:%S") [$NAME] [INFO] (Aluna Crash Handler) AlunaCrashHandler.exe not detected. Server nominal." | tee -a  "$LOG_SCRIPT"
	fi
}

#Issue the save command to the server
script_save() {
	if [[ "$(systemctl --user show -p ActiveState --value $SERVICE)" != "active" ]]; then
		echo "$(date +"%Y-%m-%d %H:%M:%S") [$NAME] [INFO] (Save) Server is not running." | tee -a  "$LOG_SCRIPT"
	elif [[ "$(systemctl --user show -p ActiveState --value $SERVICE)" == "active" ]]; then
		echo "$(date +"%Y-%m-%d %H:%M:%S") [$NAME] [INFO] (Save) Save game to disk has been initiated." | tee -a  "$LOG_SCRIPT"
		( sleep 5 && screen -p 0 -S $NAME -X eval 'stuff "save"\\015' ) &
		while read line; do
			if [[ "$line" =~ "[Server]: Save completed." ]]; then
				echo "$(date +"%Y-%m-%d %H:%M:%S") [$NAME] [INFO] (Save) Save game to disk has been completed." | tee -a  "$LOG_SCRIPT"
				break
			else
				echo "$(date +"%Y-%m-%d %H:%M:%S") [$NAME] [INFO] (Save) Save game to disk is in progress. Please wait..."
			fi
		done < <(tail -n1 -f $LOG_TMP)
	fi
}

#Sync server files from ramdisk to hdd/ssd
script_sync() {
	if [[ "$TMPFS_ENABLE" == "1" ]]; then
		if [[ "$(systemctl --user show -p ActiveState --value $SERVICE)" != "active" ]]; then
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$NAME] [INFO] (Sync) Server is not running." | tee -a  "$LOG_SCRIPT"
		elif [[ "$(systemctl --user show -p ActiveState --value $SERVICE)" == "active" ]]; then
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$NAME] [INFO] (Sync) Sync from tmpfs to disk has been initiated." | tee -a  "$LOG_SCRIPT"
			rsync -av --info=progress2 $TMPFS_DIR/ $SRV_DIR #| sed -e "s/^/$(date +"%Y-%m-%d %H:%M:%S") [$NAME] [INFO] (Sync) Syncing: /" | tee -a  "$LOG_SCRIPT"
			sleep 1
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$NAME] [INFO] (Sync) Sync from tmpfs to disk has been completed." | tee -a  "$LOG_SCRIPT"
		fi
	elif [[ "$TMPFS_ENABLE" == "0" ]]; then
		echo "$(date +"%Y-%m-%d %H:%M:%S") [$NAME] [INFO] (Sync) Server does not have tmpfs enabled." | tee -a  "$LOG_SCRIPT"
	fi
}

#Start the server
script_start() {
	if [[ "$(systemctl --user show -p ActiveState --value $SERVICE)" == "inactive" ]]; then
		echo "$(date +"%Y-%m-%d %H:%M:%S") [$NAME] [INFO] (Start) Server start initialized." | tee -a  "$LOG_SCRIPT"
		systemctl --user start $SERVICE
		sleep 1
		while [[ "$(systemctl --user show -p ActiveState --value $SERVICE)" == "activating" ]]; do
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$NAME] [INFO] (Start) Server is activating. Please wait..." | tee -a  "$LOG_SCRIPT"
			sleep 1
		done
		if [[ "$(systemctl --user show -p ActiveState --value $SERVICE)" == "active" ]]; then
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$NAME] [INFO] (Start) Server has been successfully activated." | tee -a  "$LOG_SCRIPT"
			sleep 1
		elif [[ "$(systemctl --user show -p ActiveState --value $SERVICE)" != "active" ]]; then
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$NAME] [INFO] (Start) Server failed to activate. See systemctl --user status $SERVICE for details." | tee -a  "$LOG_SCRIPT"
			sleep 1
		fi
	elif [[ "$(systemctl --user show -p ActiveState --value $SERVICE)" == "active" ]]; then
		echo "$(date +"%Y-%m-%d %H:%M:%S") [$NAME] [INFO] (Start) Server is already running." | tee -a  "$LOG_SCRIPT"
		sleep 1
	elif [[ "$(systemctl --user show -p ActiveState --value $SERVICE)" == "failed" ]]; then
		echo "$(date +"%Y-%m-%d %H:%M:%S") [$NAME] [INFO] (Start) Server failed to activate. See systemctl --user status $SERVICE for details." | tee -a  "$LOG_SCRIPT"
		sleep 1
	fi
}

#Stop the server
script_stop() {
	if [[ "$(systemctl --user show -p ActiveState --value $SERVICE)" == "inactive" ]]; then
		echo "$(date +"%Y-%m-%d %H:%M:%S") [$NAME] [INFO] (Stop) Server is not running." | tee -a  "$LOG_SCRIPT"
		sleep 1
	elif [[ "$(systemctl --user show -p ActiveState --value $SERVICE)" == "active" ]]; then
		echo "$(date +"%Y-%m-%d %H:%M:%S") [$NAME] [INFO] (Stop) Server shutdown in progress." | tee -a  "$LOG_SCRIPT"
		systemctl --user stop $SERVICE
		sleep 1
		while [[ "$(systemctl --user show -p ActiveState --value $SERVICE)" == "deactivating" ]]; do
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$NAME] [INFO] (Stop) Server is deactivating. Please wait..." | tee -a  "$LOG_SCRIPT"
			sleep 1
		done
		echo "$(date +"%Y-%m-%d %H:%M:%S") [$NAME] [INFO] (Stop) Server is deactivated." | tee -a  "$LOG_SCRIPT"
	fi
}

#Restart the server
script_restart() {
	if [[ "$(systemctl --user show -p ActiveState --value $SERVICE)" == "inactive" ]]; then
		echo "$(date +"%Y-%m-%d %H:%M:%S") [$NAME] [INFO] (Restart) Server is not running." | tee -a  "$LOG_SCRIPT"
	elif [[ "$(systemctl --user show -p ActiveState --value $SERVICE)" == "active" ]]; then
		echo "$(date +"%Y-%m-%d %H:%M:%S") [$NAME] [INFO] (Restart) Server is going to restart in 15-30 seconds, please wait..." | tee -a  "$LOG_SCRIPT"
		sleep 1
		screen -p 0 -S $NAME -X eval 'stuff "/all Server restarting in 15 seconds."\\015'
		sleep 1
		script_stop
		sleep 1
		script_start
		sleep 1
	fi
}

#If the server proces is terminated it auto restarts it
script_autorestart() {
	if [[ "$(systemctl --user show -p ActiveState --value $SERVICE)" != "active" ]]; then
		echo "$(date +"%Y-%m-%d %H:%M:%S") [$NAME] [INFO] (Autorestart) Server not running, attempting to start." | tee -a  "$LOG_SCRIPT"
		script_start
		sleep 1
	elif [[ "$(systemctl --user show -p ActiveState --value $SERVICE)" == "active" ]]; then
		echo "$(date +"%Y-%m-%d %H:%M:%S") [$NAME] [INFO] (Autorestart) Server running, no need to restart." | tee -a  "$LOG_SCRIPT"
	fi
}

#Deletes old backups
script_deloldbackup() {
	echo "$(date +"%Y-%m-%d %H:%M:%S") [$NAME] [INFO] (Delete old backup) Deleting old backups: $BCKP_DELOLD days old." | tee -a  "$LOG_SCRIPT"
	# Delete old backups
	find $BCKP_DIR -mtime $BCKP_DELOLD -exec rm {} \;
	# Delete empty folders
	find $BCKP_DIR -type d 2> /dev/null -empty -exec rm -rf {} \;
	echo "$(date +"%Y-%m-%d %H:%M:%S") [$NAME] [INFO] (Delete old backup) Deleting old backups complete." | tee -a  "$LOG_SCRIPT"
}

#Backs up the server
script_backup() {
	#If there is not a folder for today, create one
	if [ ! -d "$BCKP_DEST" ]; then
		mkdir -p $BCKP_DEST
	fi
	#Backup source to destination
	echo "$(date +"%Y-%m-%d %H:%M:%S") [$NAME] [INFO] (Backup) Backup has been initiated." | tee -a  "$LOG_SCRIPT"
	cd "$BCKP_SRC_DIR"
	tar -cpvzf $BCKP_DEST/$(date +"%Y%m%d%H%M").tar.gz $BCKP_SRC #| sed -e "s/^/$(date +"%Y-%m-%d %H:%M:%S") [$NAME] [INFO] (Backup) Compressing: /" | tee -a  "$LOG_SCRIPT"
	echo "$(date +"%Y-%m-%d %H:%M:%S") [$NAME] [INFO] (Backup) Backup complete." | tee -a  "$LOG_SCRIPT"
}

#Automaticly backs up the server and deletes old backups
script_autobackup() {
	if [[ "$(systemctl --user show -p ActiveState --value $SERVICE)" != "active" ]]; then
		echo "$(date +"%Y-%m-%d %H:%M:%S") [$NAME] [INFO] (Autobackup) Server is not running." | tee -a  "$LOG_SCRIPT"
	elif [[ "$(systemctl --user show -p ActiveState --value $SERVICE)" == "active" ]]; then
		sleep 1
		script_backup
		sleep 1
		script_deloldbackup
	fi
}

#Check for updates. If there are updates available, shut down the server, update it and restart it.
script_update() {
	echo "$(date +"%Y-%m-%d %H:%M:%S") [$NAME] [INFO] (Update) Initializing update check." | tee -a  "$LOG_SCRIPT"
	if [ ! -f $UPDATE_DIR/installed.buildid ] ; then
		touch $UPDATE_DIR/installed.buildid
		echo "0" > $UPDATE_DIR/installed.buildid
	fi
	if [ ! -f $UPDATE_DIR/installed.timeupdated ] ; then
		touch $UPDATE_DIR/installed.timeupdated
		echo "0" > $UPDATE_DIR/installed.timeupdated
	fi
	
	echo "$(date +"%Y-%m-%d %H:%M:%S") [$NAME] [INFO] (Update) Removing Steam/appcache/appinfo.vdf" | tee -a  "$LOG_SCRIPT"
	rm -rf "/home/$USER/.steam/appcache/appinfo.vdf"
	
	echo "$(date +"%Y-%m-%d %H:%M:%S") [$NAME] [INFO] (Update) Connecting to steam servers." | tee -a  "$LOG_SCRIPT"
	
	steamcmd +login $STEAMCMDUID $STEAMCMDPSW +app_info_update 1 +app_info_print $APPID +quit | grep -EA 1000 "^\s+\"branches\"$" | grep -EA 5 "^\s+\"public\"$" | grep -m 1 -EB 10 "^\s+}$" | grep -E "^\s+\"buildid\"\s+" | tr '[:blank:]"' ' ' | tr -s ' ' | cut -d' ' -f3 > $UPDATE_DIR/available.buildid
	
	steamcmd +login $STEAMCMDUID $STEAMCMDPSW +app_info_update 1 +app_info_print $APPID +quit | grep -EA 1000 "^\s+\"branches\"$" | grep -EA 5 "^\s+\"public\"$" | grep -m 1 -EB 10 "^\s+}$" | grep -E "^\s+\"timeupdated\"\s+" | tr '[:blank:]"' ' ' | tr -s ' ' | cut -d' ' -f3 > $UPDATE_DIR/available.timeupdated
	
	echo "$(date +"%Y-%m-%d %H:%M:%S") [$NAME] [INFO] (Update) Received application info data." | tee -a  "$LOG_SCRIPT"
	
	INSTALLED_BUILDID=$(cat $UPDATE_DIR/installed.buildid)
	AVAILABLE_BUILDID=$(cat $UPDATE_DIR/available.buildid)
	INSTALLED_TIME=$(cat $UPDATE_DIR/installed.timeupdated)
	AVAILABLE_TIME=$(cat $UPDATE_DIR/available.timeupdated)
	
	if [ "$AVAILABLE_TIME" -gt "$INSTALLED_TIME" ]; then
		echo "$(date +"%Y-%m-%d %H:%M:%S") [$NAME] [INFO] (Update) New update detected." | tee -a  "$LOG_SCRIPT"
		echo "$(date +"%Y-%m-%d %H:%M:%S") [$NAME] [INFO] (Update) Installed: BuildID: $INSTALLED_BUILDID, TimeUpdated: $INSTALLED_TIME" | tee -a  "$LOG_SCRIPT"
		echo "$(date +"%Y-%m-%d %H:%M:%S") [$NAME] [INFO] (Update) Available: BuildID: $AVAILABLE_BUILDID, TimeUpdated: $AVAILABLE_TIME" | tee -a  "$LOG_SCRIPT"
		sleep 1
		if [[ "$(systemctl --user show -p ActiveState --value $SERVICE)" == "active" ]]; then
			#screen -p 0 -S $NAME -X eval 'stuff "/all New update detected. Server will shutdown and update."\\015'
			WAS_RUNNING="1"
			script_stop
		fi
		sleep 1
		if [[ "$TMPFS_ENABLE" == "1" ]]; then
			rm -rf $TMPFS_DIR/$WINE_PREFIX_GAME_DIR
		fi
		echo "$(date +"%Y-%m-%d %H:%M:%S") [$NAME] [INFO] (Update) Updating..." | tee -a  "$LOG_SCRIPT"
		steamcmd +@sSteamCmdForcePlatformType windows +login $STEAMCMDUID $STEAMCMDPSW +force_install_dir $SRV_DIR/$WINE_PREFIX_GAME_DIR +app_update $APPID validate +quit
		echo "$(date +"%Y-%m-%d %H:%M:%S") [$NAME] [INFO] (Update) Update completed." | tee -a  "$LOG_SCRIPT"
		echo "$AVAILABLE_BUILDID" > $UPDATE_DIR/installed.buildid
		echo "$AVAILABLE_TIME" > $UPDATE_DIR/installed.timeupdated
		if [ "$WAS_RUNNING" == "1" ]; then
			if [[ "$TMPFS_ENABLE" == "1" ]]; then
				mkdir -p $TMPFS_DIR/$WINE_PREFIX_GAME_DIR/Build
				mkdir -p $SRV_DIR/$WINE_PREFIX_GAME_DIR/Build
			elif [[ "$TMPFS_ENABLE" == "0" ]]; then
				mkdir -p $SRV_DIR/$WINE_PREFIX_GAME_DIR/Build
			fi
			sleep 1
			script_start
		fi
	elif [ "$AVAILABLE_TIME" -eq "$INSTALLED_TIME" ]; then
		echo "$(date +"%Y-%m-%d %H:%M:%S") [$NAME] [INFO] (Update) No new updates detected." | tee -a  "$LOG_SCRIPT"
		echo "$(date +"%Y-%m-%d %H:%M:%S") [$NAME] [INFO] (Update) Installed: BuildID: $INSTALLED_BUILDID, TimeUpdated: $INSTALLED_TIME" | tee -a  "$LOG_SCRIPT"
	fi
}

#First timer function for systemd timers to execute parts of the script in order without interfering with each other
script_timer_one() {
	script_enabled
	script_logs
	script_crash_kill
	script_autorestart
	script_save
	script_sync
	script_autobackup
	script_update
}

#Second timer function for systemd timers to execute parts of the script in order without interfering with each other
script_timer_two() {
	script_enabled
	script_logs
	script_crash_kill
	script_autorestart
	script_save
	script_sync
	script_update
}

script_install() {
	echo "Installation 1/3"
	echo ""
	echo "Required packages that need to be installed on the server:"
	echo "xorg-xauth"
	echo "xorg-xhost"
	echo "wine"
	echo "screen"
	echo "steamcmd"
	echo ""
	echo "Required packages that need to be installed on the client:"
	echo "xorg-xauth"
	echo ""
	echo "If these packages aren't installed, terminate this script with CTRL+C and install them."
	echo ""
	echo "This installation will enable linger for the user specified (allows user services to be ran on boot)."
	echo "The installation process will also make a modification to /etc/ssh/sshd_config to allow X11 GUI forwarding to your"
	echo "local machine so you can install the wine prefix. For this to work edit your /etc/ssh/sshd_config on your"
	echo "local machine and uncomment the line:"
	echo "#X11Forwarding yes"
	echo "so it looks like this:"
	echo "X11Forwarding yes"
	echo "After that reboot both machines or restart the ssh services."
	echo ""
	read -p "Press any key to continue" -n 1 -s -r
	echo ""
	read -p "Enter user (MUST NOT BE ROOT!): " USER
	echo ""
	read -p "Enable RamDisk (1-yes, 0-no): " TMPFS
	echo ""
	if [[ "$TMPFS" == "1" ]]; then
		read -p "RamDisk Size (Minimum 6GB): " TMPFS_SIZE
	fi
	if [[ "$TMPFS" == "1" ]]; then
		cat >> /etc/fstab <<- EOF
	
		# /home/$USER/tmpfs
		tmpfs				   /home/$USER/tmpfs		tmpfs		   rw,size=$TMPFS_SIZE,uid=$USER	0 0
		EOF
	fi
	sudo sed -i 's/#AllowTcpForwarding yes/AllowTcpForwarding yes/g' /etc/ssh/sshd_config
	sudo sed -i 's/#X11Forwarding yes/X11Forwarding yes yes/g' /etc/ssh/sshd_config 
	sudo sed -i 's/#X11DisplayOffset 10/X11DisplayOffset 10/g' /etc/ssh/sshd_config 
	sudo sed -i 's/#X11UseLocalhost yes/X11UseLocalhost yes/g' /etc/ssh/sshd_config 
	
	sudo mkdir -p /var/lib/systemd/linger/
	sudo touch /var/lib/systemd/linger/$USER
	
	echo "Installation 1/3 complete."
	echo "After you reboot the server and your local machine connect to the server with ssh -Y user@host"
}

script_install_services() {
	echo "Installation 2/3"
	echo ""
	echo "Initializing service instalation."
	echo ""
	echo "List of files that are going to be generated on the system:"
	echo ""
	echo "/home/$USER/.config/systemd/user/$SERVICE_NAME-mkdir-tmpfs.service - Service to generate the folder structure once the RamDisk is started (only executes if RamDisk enabled)."
	echo "/home/$USER/.config/systemd/user/$SERVICE_NAME-tmpfs - Server service file for use with a RamDisk (only executes if RamDisk enabled)."
	echo "/home/$USER/.config/systemd/user/$SERVICE_NAME - Server service file for normal hdd/ssd use."
	echo "/home/$USER/.config/systemd/user/$SERVICE_NAME-timer-1.timer - Timer for scheduled command execution of $SERVICE_NAME-timer-1.service"
	echo "/home/$USER/.config/systemd/user/$SERVICE_NAME-timer-1.service - Executes scheduled script functions: autorestart, save, sync, backup and update."
	echo "/home/$USER/.config/systemd/user/$SERVICE_NAME-timer-2.timer - Timer for scheduled command execution of $SERVICE_NAME-timer-2.service"
	echo "/home/$USER/.config/systemd/user/$SERVICE_NAME-timer-2.service - Executes scheduled script functions: autorestart, save, sync and update."
	echo ""
	read -p "Press any key to continue" -n 1 -s -r
	cat > /home/$USER/.config/systemd/user/$SERVICE_NAME-mkdir-tmpfs.service <<- EOF
	[Unit]
	Description=$NAME TmpFs dir creator
	After=home-$USER-tmpfs.mount
	
	[Service]
	Type=oneshot
	WorkingDirectory=/home/$USER/
	ExecStart=/bin/mkdir -p $TMPFS_DIR/$WINE_PREFIX_GAME_DIR/Build
	
	[Install]
	WantedBy=default.target
	EOF
	
	cat > /home/$USER/.config/systemd/user/$SERVICE_NAME-tmpfs.service <<- EOF
	[Unit]
	Description=$NAME TmpFs Server Service 
	After=network.target home-$USER-tmpfs.mount $SERVICE_NAME-mkdir-tmpfs.service
	
	[Service]
	Type=forking
	WorkingDirectory=$TMPFS_DIR/$WINE_PREFIX_GAME_DIR/Build/
	ExecStartPre=/usr/bin/rsync -av --info=progress2 $SRV_DIR/ $TMPFS_DIR
	ExecStart=/bin/bash -c 'screen -c $SCRIPT_DIR/$SERVICE_NAME-screen.conf -d -m -S $NAME env WINEARCH=$WINE_ARCH WINEDEBUG=-all WINEPREFIX=$TMPFS_DIR wineconsole --backend=curses $TMPFS_DIR/$WINE_PREFIX_GAME_DIR/$WINE_PREFIX_GAME_EXE'
	ExecStartPost=/usr/bin/sed -i 's/SCRIPT_ENABLED="0"/SCRIPT_ENABLED="1"/' $SCRIPT_DIR/$SCRIPT_NAME
	ExecStop=/usr/bin/sed -i 's/SCRIPT_ENABLED="1"/SCRIPT_ENABLED="0"/' $SCRIPT_DIR/$SCRIPT_NAME
	ExecStop=/usr/bin/screen -p 0 -S $NAME -X eval 'stuff "quittimer 15 server shutting down in 15 seconds"\\015'
	ExecStop=/bin/sleep 20
	ExecStop=/usr/bin/rsync -av --info=progress2 $TMPFS_DIR/ $SRV_DIR
	TimeoutStartSec=infinity
	TimeoutStopSec=300
	Restart=no
	
	[Install]
	WantedBy=default.target
	EOF
	
	cat > /home/$USER/.config/systemd/user/$SERVICE_NAME.service <<- EOF
	[Unit]
	Description=$NAME Server Service
	After=network.target
	
	[Service]
	Type=forking
	WorkingDirectory=$SRV_DIR/$WINE_PREFIX_GAME_DIR/Build/
	ExecStart=/bin/bash -c 'screen -c $SCRIPT_DIR/$SERVICE_NAME-screen.conf -d -m -S $NAME env WINEARCH=$WINE_ARCH WINEDEBUG=-all WINEPREFIX=$SRV_DIR wineconsole --backend=curses $SRV_DIR/$WINE_PREFIX_GAME_DIR/$WINE_PREFIX_GAME_EXE'
	ExecStartPost=/usr/bin/sed -i 's/SCRIPT_ENABLED="0"/SCRIPT_ENABLED="1"/' $SCRIPT_DIR/$SCRIPT_NAME
	ExecStop=/usr/bin/sed -i 's/SCRIPT_ENABLED="1"/SCRIPT_ENABLED="0"/' $SCRIPT_DIR/$SCRIPT_NAME
	ExecStop=/usr/bin/screen -p 0 -S $NAME -X eval 'stuff "quittimer 15 server shutting down in 15 seconds"\\015'
	ExecStop=/bin/sleep 20
	TimeoutStartSec=infinity
	TimeoutStopSec=300
	Restart=no
	
	[Install]
	WantedBy=default.target
	EOF
	
	cat > /home/$USER/.config/systemd/user/$SERVICE_NAME-timer-1.timer <<- EOF
	[Unit]
	Description=$NAME Script Timer 1
	
	[Timer]
	OnCalendar=*-*-* 00:00:00
	OnCalendar=*-*-* 06:00:00
	OnCalendar=*-*-* 12:00:00
	OnCalendar=*-*-* 18:00:00
	Persistent=true
	
	[Install]
	WantedBy=timers.target
	EOF
	
	cat > /home/$USER/.config/systemd/user/$SERVICE_NAME-timer-1.service <<- EOF
	[Unit]
	Description=$NAME Script Timer 1 Service
	
	[Service]
	Type=oneshot
	ExecStart=$SCRIPT_DIR/$SCRIPT_NAME -timer_one
	EOF
	
	cat > /home/$USER/.config/systemd/user/$SERVICE_NAME-timer-2.timer <<- EOF
	[Unit]
	Description=$NAME Script Timer 2
	
	[Timer]
	OnCalendar=*-*-* *:15:00
	OnCalendar=*-*-* *:30:00
	OnCalendar=*-*-* *:45:00
	OnCalendar=*-*-* 01:00:00
	OnCalendar=*-*-* 02:00:00
	OnCalendar=*-*-* 03:00:00
	OnCalendar=*-*-* 04:00:00
	OnCalendar=*-*-* 05:00:00
	OnCalendar=*-*-* 07:00:00
	OnCalendar=*-*-* 08:00:00
	OnCalendar=*-*-* 09:00:00
	OnCalendar=*-*-* 10:00:00
	OnCalendar=*-*-* 11:00:00
	OnCalendar=*-*-* 13:00:00
	OnCalendar=*-*-* 14:00:00
	OnCalendar=*-*-* 15:00:00
	OnCalendar=*-*-* 16:00:00
	OnCalendar=*-*-* 17:00:00
	OnCalendar=*-*-* 19:00:00
	OnCalendar=*-*-* 20:00:00
	OnCalendar=*-*-* 21:00:00
	OnCalendar=*-*-* 22:00:00
	OnCalendar=*-*-* 23:00:00
	Persistent=true
	
	[Install]
	WantedBy=timers.target
	EOF
	
	cat > /home/$USER/.config/systemd/user/$SERVICE_NAME-timer-2.service <<- EOF
	[Unit]
	Description=$NAME Script Timer 2 Service
	
	[Service]
	Type=oneshot
	ExecStart=$SCRIPT_DIR/$SCRIPT_NAME -timer_two
	EOF
	
	if [[ "$TMPFS" == "1" ]]; then
		systemctl --user enable $SERVICE_NAME-mkdir-tmpfs.service
	fi
	
	systemctl --user enable $SERVICE_NAME-timer-1.timer $SERVICE_NAME-timer-2.timer
	
	echo "Creating folder structure for server..."
	mkdir -p /home/$USER/servers/$SRV_DIR_NAME/{backups,logs,scripts,server,updates}
	
	cat > $SCRIPT_DIR/$SERVICE_NAME-screen.conf <<- EOF
	#
	# This is an example for the global screenrc file.
	# You may want to install this file as /usr/local/etc/screenrc.
	# Check config.h for the exact location.
	#
	# Flaws of termcap and standard settings are done here.
	#
	
	#startup_message off
	
	#defflow on # will force screen to process ^S/^Q
	
	deflogin on
	#autodetach off
	
	vbell on
	vbell_msg "   Wuff  ----  Wuff!!  "
	
	# all termcap entries are now duplicated as terminfo entries.
	# only difference should be the slightly modified syntax, and check for
	# terminfo entries, that are already corected in the database.
	# 
	# G0 	we have a SEMI-GRAPHICS-CHARACTER-MODE
	# WS	this sequence resizes our window.
	# cs    this sequence changes the scrollregion
	# hs@	we have no hardware statusline. screen will only believe that
	#       there is a hardware status line if hs,ts,fs,ds are all set.
	# ts    to statusline
	# fs    from statusline
	# ds    delete statusline
	# al    add one line
	# AL    add multiple lines
	# dl    delete one line
	# DL    delete multiple lines
	# ic    insert one char (space)
	# IC    insert multiple chars
	# nx    terminal uses xon/xoff
	
	termcap  facit|vt100|xterm LP:G0
	terminfo facit|vt100|xterm LP:G0
	
	#the vt100 description does not mention "dl". *sigh*
	termcap  vt100 dl=5\E[M
	terminfo vt100 dl=5\E[M
	
	#facit's "al" / "dl"  are buggy if the current / last line
	#contain attributes...
	termcap  facit al=\E[L\E[K:AL@:dl@:DL@:cs=\E[%i%d;%dr:ic@
	terminfo facit al=\E[L\E[K:AL@:dl@:DL@:cs=\E[%i%p1%d;%p2%dr:ic@
	
	#make sun termcap/info better
	termcap  sun 'up=^K:AL=\E[%dL:DL=\E[%dM:UP=\E[%dA:DO=\E[%dB:LE=\E[%dD:RI=\E[%dC:IC=\E[%d@:WS=1000\E[8;%d;%dt'
	terminfo sun 'up=^K:AL=\E[%p1%dL:DL=\E[%p1%dM:UP=\E[%p1%dA:DO=\E[%p1%dB:LE=\E[%p1%dD:RI=\E[%p1%dC:IC=\E[%p1%d@:WS=\E[8;%p1%d;%p2%dt$<1000>'
	
	#xterm understands both im/ic and doesn't have a status line.
	#Note: Do not specify im and ic in the real termcap/info file as
	#some programs (e.g. vi) will (no,no, may (jw)) not work anymore.
	termcap  xterm|fptwist hs@:cs=\E[%i%d;%dr:im=\E[4h:ei=\E[4l
	terminfo xterm|fptwist hs@:cs=\E[%i%p1%d;%p2%dr:im=\E[4h:ei=\E[4l
	
	# Long time I had this in my private screenrc file. But many people
	# seem to want it (jw):
	# we do not want the width to change to 80 characters on startup:
	# on suns, /etc/termcap has :is=\E[r\E[m\E[2J\E[H\E[?7h\E[?1;3;4;6l:
	termcap xterm 'is=\E[r\E[m\E[2J\E[H\E[?7h\E[?1;4;6l'
	terminfo xterm 'is=\E[r\E[m\E[2J\E[H\E[?7h\E[?1;4;6l'
	
	#
	# Do not use xterms alternate window buffer. 
	# This one would not add lines to the scrollback buffer.
	termcap xterm|xterms|xs ti=\E7\E[?47l
	terminfo xterm|xterms|xs ti=\E7\E[?47l
	
	#make hp700 termcap/info better
	termcap  hp700 'Z0=\E[?3h:Z1=\E[?3l:hs:ts=\E[62"p\E[0$~\E[2$~\E[1$}:fs=\E[0}\E[61"p:ds=\E[62"p\E[1$~\E[61"p:ic@'
	terminfo hp700 'Z0=\E[?3h:Z1=\E[?3l:hs:ts=\E[62"p\E[0$~\E[2$~\E[1$}:fs=\E[0}\E[61"p:ds=\E[62"p\E[1$~\E[61"p:ic@'
	
	#wyse-75-42 must have defflow control (xo = "terminal uses xon/xoff")
	#(nowadays: nx = padding doesn't work, have to use xon/off)
	#essential to have it here, as this is a slow terminal.
	termcap wy75-42 nx:xo:Z0=\E[?3h\E[31h:Z1=\E[?3l\E[31h
	terminfo wy75-42 nx:xo:Z0=\E[?3h\E[31h:Z1=\E[?3l\E[31h
	
	#remove some stupid / dangerous key bindings
	bind ^k
	#bind L
	bind ^\
	#make them better
	bind \\ quit
	bind K kill
	bind I login on
	bind O login off
	bind } history
	
	scrollback 1000
	logfile $LOG_TMP
	logfile flush 0
	deflog on
	EOF
	
	echo "Installation 2/3 complete."
}

script_install_wine_prefix() {
	echo "Installation 3/3"
	echo ""
	echo "This will install the wine prefix. There will be some GUI interaction necessary."
	echo "The wine uninstaller window will pop up at one time. Uninstall evreything related to Mono."
	echo ""
	read -p "Press any key to continue" -n 1 -s -r
	env WINEARCH=$WINE_ARCH WINEDEBUG=-all WINEPREFIX=$SRV_DIR wineboot --init
	env WINEARCH=$WINE_ARCH WINEDEBUG=-all WINEPREFIX=$SRV_DIR wine uninstaller
	env WINEARCH=$WINE_ARCH WINEDEBUG=-all WINEPREFIX=$SRV_DIR winetricks corefonts vcrun2012 dotnet472
	echo ""
	echo "Instalation 3/3 complete."
}

#Do not allow for another instance of this script to run to prevent data loss
if [[ $(pidof -o %PPID -x $0) -gt "0" ]]; then
	echo "$(date +"%Y-%m-%d %H:%M:%S") [$NAME] [INFO] Another instance of this script is already running. Exiting to prevent data loss."
	exit 0
fi

case "$1" in
	-help)
		echo -e "${CYAN}Time: $(date +"%Y-%m-%d %H:%M:%S") ${NC}"
		echo -e "${CYAN}$NAME server script by 7thCore${NC}"
		echo ""
		echo -e "${LIGHTRED}Before doing anything edit the script and input your steam username and password for the auto update feature to work.${NC}"
		echo -e "${LIGHTRED}The variables for it are located at the very top of the script.${NC}"
		echo -e "${LIGHTRED}Also if you have Steam Guard on your mobile phone activated, disable it because steamcmd always asks for the${NC}"
		echo -e "${LIGHTRED}two factor authentication code and breaks the auto update feature. Use Steam Guard via email.${NC}"
		echo ""
		echo -e "${GREEN}start ${RED}- ${GREEN}Start the server${NC}"
		echo -e "${GREEN}stop ${RED}- ${GREEN}Stop the server${NC}"
		echo -e "${GREEN}restart ${RED}- ${GREEN}Restart the server${NC}"
		echo -e "${GREEN}autorestart ${RED}- ${GREEN}Automaticly restart the server if it's not running${NC}"
		echo -e "${GREEN}save ${RED}- ${GREEN}Issue the save command to the server${NC}"
		echo -e "${GREEN}sync ${RED}- ${GREEN}Sync from tmpfs to hdd/ssd${NC}"
		echo -e "${GREEN}backup ${RED}- ${GREEN}Backup files, if server running or not.${NC}"
		echo -e "${GREEN}autobackup ${RED}- ${GREEN}Automaticly backup files when server running${NC}"
		echo -e "${GREEN}deloldbackup ${RED}- ${GREEN}Delete old backups${NC}"
		echo -e "${GREEN}update ${RED}- ${GREEN}Update the server, if the server is running it wil save it, shut it down, update it and restart it.${NC}"
		echo -e "${GREEN}status ${RED}- ${GREEN}Display status of server${NC}"
		echo -e "${GREEN}install ${RED}- ${GREEN}Installs all the needed files for the script to run${NC}"
		echo -e "${GREEN}install-services ${RED}- ${GREEN}Installs systemd services for the server${NC}"
		echo -e "${GREEN}install-prefix ${RED}- ${GREEN}Installs the wine prefix to the coresponding folder. There will be a lot of GUI interaction involved.${NC}"
		echo ""
		echo -e "${LIGHTRED}If this is your first time running the script:${NC}"
		echo -e "${LIGHTRED}First use the -install argument (run only this command as root) and follow the instructions${NC}"
		echo -e "${LIGHTRED}Second, run the -install_services argument. It will install the services for the server.${NC}"
		echo -e "${LIGHTRED}Third, run the -install-prefix argument. It will install the wine prefix. There will be a lot of GUI interaction involved.${NC}"
		echo -e "${LIGHTRED}Lastly you can run the script with the -update argument to install the game.${NC}"
		echo -e "${LIGHTRED}Your server configuration file and SSK should be put in $SRV_DIR/drive_c/users/$USER/Application Data/InterstellarRift/${NC}"
		echo -e "${LIGHTRED}When all of this is done copy/move this script to $SCRIPT_DIR ${NC}"
		echo ""
		echo -e "${LIGHTRED}After that enable the correct service with: systemctl --user enable $SERVICE_NAME.service or"
		echo -e "${LIGHTRED}systemctl --user enable $SERVICE_NAME-tmpfs.service for the RamDisk variant (USE ONLY ONE!)${NC}"
		echo -e "${LIGHTRED}Now start the service with systemctl --user start $SERVICE_NAME.service or systemctl --user start $SERVICE_NAME-tmpfs.service${NC}"
		echo ""
		echo -e "${LIGHTRED}Example usage: ./$SCRIPT_NAME -start${NC}"
		echo ""
		echo -e "${CYAN}Have a nice day!${NC}"
		echo ""
		;;
	-start)
		script_start
		;;
	-stop)
		script_stop
		;;
	-restart)
		script_restart
		;;
	-save)
		script_save
		;;
	-sync)
		script_sync
		;;
	-backup)
		script_backup
		;;
	-autobackup)
		script_autobackup
		;;
	-deloldbackup)
		script_deloldbackup
		;;
	-autorestart)
		script_autorestart
		;;
	-update)
		script_update
		;;
	-status)
		script_status
		;;
	-install)
		script_install
		;;
	-install_services)
		script_install_services
		;;
	-install-prefix)
		script_install_wine_prefix
		;;
	-crash_kill)
		script_crash_kill
		;;
	-timer_one)
		script_timer_one
		;;
	-timer_two)
		script_timer_two
		;;
	*)
	echo "Usage: $0 {start|stop|restart|save|sync|backup|autobackup|deloldbackup|autorestart|update|status|install|install_services|install-prefix \"server command\"}"
	exit 1
	;;
esac

exit 0


#if [[ "$(systemctl --user is-active $SERVICE)" != "active" ]]; then
