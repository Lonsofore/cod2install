#!/bin/bash

# path to sh
ABSOLUTE_FILENAME=`readlink -e "$0"`
# sh directory
DIRECTORY=`dirname "$ABSOLUTE_FILENAME"`
# main
MAINDIRECTORY=$DIRECTORY/../

cd ~

# folders
mkdir ~/.callofduty2
mkdir ~/cod2
mkdir ~/cod2/main
mkdir ~/cod2/servers
mkdir ~/cod2/Library

mkdir ~/cod2/main/1.0
mkdir ~/cod2_1_0
mkdir ~/cod2_1_0/main

mkdir ~/cod2/main/1.2
mkdir ~/cod2_1_2
mkdir ~/cod2_1_2/main

mkdir ~/cod2/main/1.3
mkdir ~/cod2_1_3
mkdir ~/cod2_1_3/main
	

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
		echo "@reboot screen -S seed -d -m ~/cod2/torrent/seed.sh" >> mycron
		# install new cron file
		crontab mycron
		rm mycron
	fi
fi

# main files link - 1.0
ln -s ~/cod2/main/1.0/* ~/cod2_1_0/main/
echo "done main files for 1.0"

# main files link - 1.2
ln -s ~/cod2/main/1.0/* ~/cod2_1_2/main/
ln -s ~/cod2/main/1.2/* ~/cod2_1_2/main/
echo "done main files for 1.2"

# main files link - 1.3
ln -s ~/cod2/main/1.0/* ~/cod2_1_3/main/
ln -s ~/cod2/main/1.3/* ~/cod2_1_3/main/
echo "done main files for 1.3"


# libcod
$DIRECTORY/libcod.sh


# lnxded
cp $MAINDIRECTORY/cod2_lnxded/1.0/cod2_lnxded ~/cod2_1_0/cod2_lnxded
chmod 500 ~/cod2_1_0/cod2_lnxded

cp $MAINDIRECTORY/cod2_lnxded/1.2/cod2_lnxded ~/cod2_1_2/cod2_lnxded
chmod 500 ~/cod2_1_2/cod2_lnxded

cp $MAINDIRECTORY/cod2_lnxded/1.3/cod2_lnxded ~/cod2_1_3/cod2_lnxded
chmod 500 ~/cod2_1_3/cod2_lnxded


# pb
if (whiptail --title "PunkBuster" --yesno "Do you use PunkBuster?" 10 60 --defaultno) 
then
	cp $MAINDIRECTORY/cod2_lnxded/1.2/pb ~/cod2_1_2/pb -R
	cp $MAINDIRECTORY/cod2_lnxded/1.3/pb ~/cod2_1_3/pb -R
fi


# setup servers
$DIRECTORY/servers.sh
