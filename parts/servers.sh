#!/bin/bash

# path to sh
ABSOLUTE_FILENAME=`readlink -e "$0"`
# sh directory
DIRECTORY=`dirname "$ABSOLUTE_FILENAME"`
# main
MAINDIRECTORY=$DIRECTORY/../

# servers files
whiptail \
--title "Servers" \
--msgbox "Now place your servers folders (fs_game) in ~/cod2/servers/\nChoose Ok after upload." 10 60

# sh with all servers
create_sh=0
if [ ! -f ~/start_all.sh ]
then
	if (whiptail --title "Start sh" --yesno "Do you want to make a .sh file to start all your servers?" 10 60) 
	then
		create_sh=1
		cat << EOF >> ~/start_all.sh
#!/bin/bash
EOF
	fi
fi

# setup servers
srv_inst=1
while [ $srv_inst -eq 1 ]
do
	# sh file name
	srv_sh=$(whiptail \
	--title "Sh file" \
	--inputbox "Enter the name of sh-file for this server" 10 60 \
	3>&1 1>&2 2>&3) || { echo "You chose cancel."; exit 1; }

	# fs_game
	srv_fs=$(whiptail \
	--title "fs_game" \
	--inputbox "Enter the fs_game for your server" 10 60 \
	3>&1 1>&2 2>&3) || { echo "You chose cancel."; exit 1; }

	# .cfg
	srv_cfg=$(whiptail \
	--title "Config file" \
	--inputbox "Enter the name of your .cfg server file" 10 60 \
	3>&1 1>&2 2>&3) || { echo "You chose cancel."; exit 1; }

	# sv_cracked
	srv_crck=0
	if (whiptail --title "Cracked" --yesno "Is your server cracked?" 10 60) 
	then
		srv_crck=1
	fi
	
	# server versions
	whiptail \
	--title "CoD2 versions" --checklist --separate-output \
	"Check CoD2 versions, which you want to use with this server:" 15 60 7 \
	"1.0" "" ON \
	"1.2" "" ON \
	"1.3" "" ON \
	2>versions || { echo "You chose cancel."; exit 1; }
	
	while read choice
	do
		srv_port=$(whiptail \
		--title "Server port" \
		--inputbox "Enter your server port for $choice version (default is 28960)" 10 60 \
		3>&1 1>&2 2>&3)
		
		case $choice in
			1.0) ver=1_0
			;;
			1.2) ver=1_2
			;;
			1.3) ver=1_3
			;;
		esac
		
		# create fs_home and link library there
		fs_home=~/.callofduty2/"$srv_port"_"$srv_fs"
		lib=~/cod2/Library/$srv_fs
		mkdir $lib
		mkdir $fs_home
		ln -s $lib $fs_home/Library
		
		# link server folder to server version
		ln -s ~/cod2/servers/$srv_fs ~/cod2_$ver/
		
		# make sh file
		cat << EOF > ~/cod2_$ver/$srv_sh.sh
#!/bin/bash

export LD_PRELOAD="\$HOME/cod2_$ver/libcod2_$ver.so"

PARAMS="+set fs_homepath $HOME/.callofduty2_$ver +set fs_game $srv_fs +set dedicated 2 +set net_port $srv_port +exec $srv_cfg.cfg +set sv_cracked $srv_crck"

while true ; do
	"./cod2_lnxded" "\$PARAMS"
	echo "Restarting the server..."
	sleep 1
done
exit 1
EOF
		chmod +x ~/cod2_$ver/$srv_sh.sh
		
		# sh with all servers
		if [ $create_sh -eq 1 ]
		then
			if (whiptail --title "Add server" --yesno "Add this server to .sh file with all servers?" 10 60) 
			then
				cat << EOF >> ~/start_all.sh
screen -dm ~/cod2_$ver/$srv_sh.sh
EOF
			fi
		fi
	done < versions
	rm versions
	
	if ! (whiptail --title "Another server" --yesno "Done! Want to add another server?" 10 60) 
	then
		srv_inst=0
	fi
done

# sh with all servers
if [ $create_sh -eq 1 ]
then
	chmod +x ~/start_all.sh
	
	if (whiptail --title "Start sh" --yesno "Do you want start .sh file with your servers at system start?" 10 60) 
	then
		# add it in crontab
		crontab -l | { cat; echo "@reboot /home/$USER/start_all.sh"; } | crontab -
		service cron restart
	fi
fi