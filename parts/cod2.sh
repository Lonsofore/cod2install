#!/bin/bash

# path to sh
ABSOLUTE_FILENAME=$(readlink -e "$0")
# sh directory
DIRECTORY=$(dirname "$ABSOLUTE_FILENAME")
# main
MAINDIRECTORY=$DIRECTORY/../

# functions
function install_folders {
	mkdir ~/cod2/main/"$1"
	mkdir ~/cod2_"$1"
	mkdir ~/cod2_"$1"/main
}

function install_link {
	ln -s ~/cod2/main/1_0/* ~/cod2_1_0/main/
	if [ "$1" != "1_0" ]
	then
		ln -s ~/cod2/main/"$1"/* ~/cod2_"$1"/main/
	fi	
	echo "done main files for $1"
}

function install_lnxded {
	cp "$MAINDIRECTORY"/cod2_lnxded/"$1"/cod2_lnxded "$HOME"/cod2_"$1"/cod2_lnxded
	chmod 500 ~/cod2_"$1"/cod2_lnxded
}

function install_pb {
	cp "$MAINDIRECTORY"/cod2_lnxded/"$1"/pb "$HOME"/cod2_"$1"/pb -R
}


# here we start
cd "$HOME" || exit

# create main folders
mkdir ~/.callofduty2
mkdir ~/cod2
mkdir ~/cod2/main
mkdir ~/cod2/servers
mkdir ~/cod2/Library

# create versions folders
install_folders 1_0
install_folders 1_2
install_folders 1_3

# download main cod2 files
"$DIRECTORY"/download.sh

# main files link
install_link 1_0
install_link 1_2
install_link 1_3

# libcod
"$DIRECTORY"/libcod.sh

# lnxded
install_lnxded 1_0
install_lnxded 1_2
install_lnxded 1_3

# pb
if (whiptail --title "PunkBuster" --yesno "Do you use PunkBuster?" 10 60 --defaultno) 
then
	install_pb 1_2
	install_pb 1_3
fi

# setup servers
"$DIRECTORY"/servers.sh
