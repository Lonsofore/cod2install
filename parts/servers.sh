#!/bin/bash

# servers files
whiptail \
--title "Servers" \
--msgbox "Now place your servers folders (fs_game) in ~/cod2/servers/\\nChoose Ok after upload." 10 60

# setup servers
srv_inst=1
while [ "$srv_inst" -eq 1 ]
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
	
	while read -r choice
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
		fs_home=~/.callofduty2/"$srv_port"
		lib=~/cod2/Library/$srv_fs
		mkdir "$lib"
		mkdir "$fs_home"
		ln -s "$lib" "$fs_home/$srv_fs/Library"
		
		# link server folder to server version
		ln -s "$HOME/cod2/servers/$srv_fs" "$HOME/cod2_$ver/"
		
		# make sh file
		cat << EOF > "$HOME/cod2_$ver/$srv_sh.sh"
#!/bin/bash

export LD_PRELOAD="\$HOME/cod2_$ver/libcod2_$ver.so"

PARAMS="+set fs_homepath $HOME/.callofduty2/$srv_port +set fs_game $srv_fs +set dedicated 2 +set net_port $srv_port +exec $srv_cfg.cfg +set sv_cracked $srv_crck"

while true ; do
	"\$HOME/cod2_$ver/cod2_lnxded" "\$PARAMS"
	echo "Restarting the server..."
	sleep 1
done
exit 1
EOF
		chmod +x "$HOME/cod2_$ver/$srv_sh.sh"
		
		# add server to startup.sh
		if (whiptail --title "Add server" --yesno "Add this server to startup.sh?" 10 60) 
		then
			if [ ! -f "$HOME/startup.sh" ]
			then
				"$DIRECTORY/startup.sh"
			fi
			echo "(cd ./cod2_${ver} && screen -dmS ${srv_sh}_${ver} ./${srv_sh}.sh)" >> ~/startup.sh
		fi
	done < versions
	rm versions
	
	if ! (whiptail --title "Another server" --yesno "Done! Want to add another server?" 10 60) 
	then
		srv_inst=0
	fi
done
