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


# download main cod2 files
$DIRECTORY/download.sh


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
