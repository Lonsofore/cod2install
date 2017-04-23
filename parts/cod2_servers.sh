#!/bin/bash

# folders
cd ~/
mkdir cod2
mkdir cod2/main
mkdir cod2/main/1.0
mkdir cod2/main/1.2
mkdir cod2/main/1.3
mkdir cod2_1_0
mkdir cod2_1_0/main
mkdir cod2_1_2
mkdir cod2_1_2/main
mkdir cod2_1_3
mkdir cod2_1_3/main


# download main files
echo
echo "Time to upload main files" 
echo "Type 0 if you will upload by yourself"
echo "Type 1 if you want to try download it from the internet"
read -p "Answer: " -r
case $REPLY in
	0)
		echo "Now place your CoD2 files in ~/cod2/main"
		echo "Notice: don't duplicate files. In 1.2 and 1.3 folders place iw-15 and last localized files only."
		read -p "Done? " -r
		;;
	1)
		wget -O ~/cod2/main/main.zip https://getfile.dokpub.com/yandex/get/https://yadi.sk/d/DpHUSZMP3HEsVR
		unzip ~/cod2/main/main.zip -d ~/cod2/main
		rm ~/cod2/main/main.zip
		;;
esac

# main files link - 1.0
cd ~/cod2_1_0/main
for file in ~/cod2/main/1.0/*; do fname=${file##*/}; ln $file $fname; done
echo "done main files for 1.0"

# main files link - 1.2
cd ~/cod2_1_2/main
for file in ~/cod2/main/1.0/*; do fname=${file##*/}; ln $file $fname; done
for file in ~/cod2/main/1.2/*; do fname=${file##*/}; ln $file $fname; done
echo "done main files for 1.2"

# main files link - 1.3
cd ~/cod2_1_3/main
for file in ~/cod2/main/1.0/*; do fname=${file##*/}; ln $file $fname; done
for file in ~/cod2/main/1.3/*; do fname=${file##*/}; ln $file $fname; done
echo "done main files for 1.3"


# libcod
cd cod2
git clone https://github.com/voron00/libcod
cd libcod

./doit.sh cod2_1_0
mv bin/libcod2_1_0.so ~/cod2_1_0/libcod2_1_0.so
./doit.sh clean
echo "done libcod for 1.0"

./doit.sh cod2_1_2
mv bin/libcod2_1_2.so ~/cod2_1_2/libcod2_1_2.so
./doit.sh clean
echo "done libcod for 1.2"

./doit.sh cod2_1_3
mv bin/libcod2_1_3.so ~/cod2_1_3/libcod2_1_3.so
./doit.sh clean
echo "done libcod for 1.3"

# lnxded
cp ~/cod2install/cod2_lnxded/1.0/cod2_lnxded ~/cod2_1_0/cod2_lnxded
cp ~/cod2install/cod2_lnxded/1.2/cod2_lnxded ~/cod2_1_2/cod2_lnxded
cp ~/cod2install/cod2_lnxded/1.3/cod2_lnxded ~/cod2_1_3/cod2_lnxded

sudo chmod 500 ~/cod2_1_0/cod2_lnxded
sudo chmod 500 ~/cod2_1_2/cod2_lnxded
sudo chmod 500 ~/cod2_1_3/cod2_lnxded


# pb
cp ~/cod2install/cod2_lnxded/1.2/pb ~/cod2_1_2/pb -R
cp ~/cod2install/cod2_lnxded/1.3/pb ~/cod2_1_3/pb -R


# servers
echo
echo "Now place your servers folders (fs_game) in ~/cod2"
read -p "Done? " -r
echo    
if [[ $REPLY =~ ^[Yy]$ ]]
then
	until [[ $REPLY =~ ^[Nn]$ ]]
	do
		read -p "Write the name of your server (fs_game): " -r
		name=$REPLY
		read -p "Write the name of your server's config (without .cfg): " -r
		conf=$REPLY
		read -p "Write your server's port: " -r
		port=$REPLY
		
		# 1.0
		cd ~/cod2_1_0
		ln -s ~/cod2/$name ./
		cat << EOF > $name.sh
#!/bin/bash

export LD_PRELOAD="\$HOME/cod2_1_0/libcod2_1_0.so"

PARAMS="+set fs_game $name +set dedicated 2 +set net_port $port +exec $conf.cfg +set sv_cracked 1 +set sv_version 1.0"

while true ; do
	"./cod2_lnxded" "\$PARAMS"
	echo "Restarting the server..."
done
exit 1
EOF

		# 1.2
		cd ~/cod2_1_2
		ln -s ~/cod2/$name ./
		cat << EOF > $name.sh
#!/bin/bash

export LD_PRELOAD="\$HOME/cod2_1_2/libcod2_1_2.so"

PARAMS="+set fs_game $name +set dedicated 2 +set net_port $port +exec $conf.cfg +set sv_cracked 1 +set sv_version 1.2"

while true ; do
	"./cod2_lnxded" "\$PARAMS"
	echo "Restarting the server..."
done
exit 1
EOF
		
		# 1.3
		cd ~/cod2_1_3
		ln -s ~/cod2/$name ./
		cat << EOF > $name.sh
#!/bin/bash

export LD_PRELOAD="\$HOME/cod2_1_3/libcod2_1_3.so"

PARAMS="+set fs_game $name +set dedicated 2 +set net_port $port +exec $conf.cfg +set sv_cracked 1 +set sv_version 1.3"

while true ; do
	"./cod2_lnxded" "\$PARAMS"
	echo "Restarting the server..."
done
exit 1
EOF
		
		echo "done"
		echo
		read -p "Want to add another server? " -r
	done
fi