#!/bin/bash

# path to sh
ABSOLUTE_FILENAME=`readlink -e "$0"`
# sh directory
DIRECTORY=`dirname "$ABSOLUTE_FILENAME"`

cd ~

whiptail \
--title "CoD2 versions" --checklist \
"Check CoD2 versions, which you want to use:" 15 60 7 \
"1.0" "" ON \
"1.2" "" ON \
"1.3" "" ON \
2>cod2_ver --separate-output

cod2_1_0=0
cod2_1_2=0
cod2_1_3=0
while read ver
do
	case $ver in
		1.0) cod2_1_0=1
		;;
		1.2) cod2_1_2=1
		;;
		1.3) cod2_1_3=1
		;;
	esac
done < cod2_ver


# folders
mkdir ~/cod2
mkdir ~/cod2/main
mkdir ~/cod2/servers
mkdir ~/cod2/Library

if [ $cod2_1_0 -eq 1 ]
then
	mkdir ~/cod2/main/1.0
	mkdir ~/cod2_1_0
	mkdir ~/cod2_1_0/main
	mkdir ~/.callofduty2_1_0
fi

if [ $cod2_1_2 -eq 1 ]
then
	mkdir ~/cod2/main/1.2
	mkdir ~/cod2_1_2
	mkdir ~/cod2_1_2/main
	mkdir ~/.callofduty2_1_2
fi

if [ $cod2_1_3 -eq 1 ]
then
	mkdir ~/cod2/main/1.3
	mkdir ~/cod2_1_3
	mkdir ~/cod2_1_3/main
	mkdir ~/.callofduty2_1_3
fi


# download main files
dl_mode=0
dl_err=1
while [ $dl_err -eq 1 ]
do
	dl_mode=$(whiptail \
	--title "Main files" \
	--menu "Choose how do you want to upload CoD2 main files" 15 60 3 \
	"1" "Download it via torrent" \
	"2" "Download it via http" \
	"3" "Upload it by yourself via ftp" \
	3>&1 1>&2 2>&3) || { echo "You chose cancel."; exit 1; }

	case $dl_mode in
		1)
			echo "Downloading main via torrent..."
			has_error=0
			aria2c \
			--no-conf=true \
			--summary-interval=0 \
			--check-integrity=true \
			--save-session torrent_log.txt \
			--seed-time=0 \
			-T $DIRECTORY/main.torrent \
			-d ~/cod2 || has_error=1
			
			#has_error=`wc -l < torrent_log.txt`
			if [ $has_error -eq 0 ]
			then				
				dl_err=0
			else
				whiptail \
				--title "Error" \
				--msgbox "Oops! It seems that there is no seeders (or torrent file is broken). Try another way." 10 60
			fi
			;;
			
		2)
			wget -O ~/cod2/main/main.zip http://files.cod2.ru/.cod2install/main.zip
			if [ $? -eq 0 ]; then
				unzip ~/cod2/main/main.zip -d ~/cod2/main
				rm ~/cod2/main/main.zip
				dl_err=0
			else
				whiptail \
				--title "Error" \
				--msgbox "Oops! Broken link, report it, please!. Try another way." 10 60
			fi
			;;
			
		3)
			whiptail \
			--title "FTP" \
			--msgbox "Now place your CoD2 files in ~/cod2/main\nNotice: don't duplicate files. In 1.2 and 1.3 folders place iw_15 and last localized file only.\nChoose Ok after upload." 10 60
			
			if [ -f ~/cod2/main/1.0/iw_00.iwd ]
			then
				dl_err=0
			else
				whiptail \
				--title "Error" \
				--msgbox "Oops! No files! Try another way or this again." 10 60
			fi
			;;
	esac
done

# seed torrent on server start
if [ $dl_mode -lt 3 ]
then
	if (whiptail --title "Done" --yesno "Main files downloaded!\nDo you want to seed our torrent? It will start with your server automatically." 10 60) 
	then
		# save our torrent files here
		mkdir ~/cod2/torrent
		cp $DIRECTORY/main.torrent ~/cod2/torrent/main.torrent
		cat <<EOF > ~/cod2/torrent/seed.sh
#!/bin/bash
aria2c \
--no-conf=true \
--summary-interval=0 \
--check-integrity=true \
-T ~/cod2/torrent/main.torrent \
-d ~/cod2
EOF
					
		chmod +x ~/cod2/torrent/seed.sh
		# save our current crontab
		crontab -l > mycron
		# add sh into cron file
		echo "@reboot screen -S test -d -m ~/cod2/torrent/seed.sh" >> mycron
		# install new cron file
		crontab mycron
		rm mycron
	fi
fi

# main files link - 1.0
if [ $cod2_1_0 -eq 1 ]
then
	ln -s ~/cod2/main/1.0/* ~/cod2_1_0/main/
	echo "done main files for 1.0"
fi

# main files link - 1.2
if [ $cod2_1_2 -eq 1 ]
then
	ln -s ~/cod2/main/1.0/* ~/cod2_1_2/main/
	ln -s ~/cod2/main/1.2/* ~/cod2_1_2/main/
	echo "done main files for 1.2"
fi

# main files link - 1.3
if [ $cod2_1_3 -eq 1 ]
then
	ln -s ~/cod2/main/1.0/* ~/cod2_1_3/main/
	ln -s ~/cod2/main/1.3/* ~/cod2_1_3/main/
	echo "done main files for 1.3"
fi

# libcod
cd ~/cod2
git clone https://github.com/voron00/libcod
cd libcod

if [ $cod2_1_0 -eq 1 ]
then
	./doit.sh cod2_1_0
	mv bin/libcod2_1_0.so ~/cod2_1_0/libcod2_1_0.so
	./doit.sh clean
	echo "done libcod for 1.0"
fi

if [ $cod2_1_2 -eq 1 ]
then
	./doit.sh cod2_1_2
	mv bin/libcod2_1_2.so ~/cod2_1_2/libcod2_1_2.so
	./doit.sh clean
	echo "done libcod for 1.2"
fi

if [ $cod2_1_3 -eq 1 ]
then
	./doit.sh cod2_1_3
	mv bin/libcod2_1_3.so ~/cod2_1_3/libcod2_1_3.so
	./doit.sh clean
	echo "done libcod for 1.3"
fi


# lnxded
if [ $cod2_1_0 -eq 1 ]
then
	cp ~/cod2install/cod2_lnxded/1.0/cod2_lnxded ~/cod2_1_0/cod2_lnxded
	chmod 500 ~/cod2_1_0/cod2_lnxded
fi

if [ $cod2_1_2 -eq 1 ]
then
	cp ~/cod2install/cod2_lnxded/1.2/cod2_lnxded ~/cod2_1_2/cod2_lnxded
	chmod 500 ~/cod2_1_2/cod2_lnxded
fi

if [ $cod2_1_3 -eq 1 ]
then
	cp ~/cod2install/cod2_lnxded/1.3/cod2_lnxded ~/cod2_1_3/cod2_lnxded
	chmod 500 ~/cod2_1_3/cod2_lnxded
fi


# pb
if (whiptail --title "PunkBuster" --yesno "Do you use PunkBuster?" 10 60 --defaultno) 
then
	if [ $cod2_1_2 -eq 1 ]
	then
		cp ~/cod2install/cod2_lnxded/1.2/pb ~/cod2_1_2/pb -R
	fi
	if [ $cod2_1_3 -eq 1 ]
	then
		cp ~/cod2install/cod2_lnxded/1.3/pb ~/cod2_1_3/pb -R
	fi
fi


# servers files
whiptail \
--title "Servers" \
--msgbox "Now place your servers folders (fs_game) in ~/cod2/servers/\nChoose Ok after upload." 10 60

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
		
		# maps
		mkdir ~/cod2/Library/$srv_fs # maps for fs_game here
		mkdir ~/.callofduty2_$ver/$srv_fs # and it will link here
		ln -s ~/cod2/Library/$srv_fs $HOME/.callofduty2_$ver/$srv_fs/
		mv ~/.callofduty2_$ver/$srv_fs/$srv_fs ~/.callofduty2_$ver/$srv_fs/Library
		# servers
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
		chmod 500 ~/cod2_$ver/$srv_sh.sh
	done < versions
	
	if ! (whiptail --title "Another server" --yesno "Done! Want to add another server?" 10 60) 
	then
		srv_inst=0
	fi
done
