#!/bin/bash

# folders
cd ~/
mkdir cod2
mkdir cod2/main
mkdir cod2_1_0
mkdir cod2_1_0/main
mkdir cod2_1_3
mkdir cod2_1_3/main


# main files
echo
echo "Now place your CoD2 1.3 files in ~/cod2/main"
read -p "Done? " -r
echo    
if [[ $REPLY =~ ^[Yy]$ ]]
then
	lang=$(find ~/cod2/main -type f -printf "%f\n" | grep 'localized' | grep '13')
	
	cd ~/cod2_1_0/main
	for file in ~/cod2/main/*; do fname=${file##*/}; ln $file $fname; done
	rm iw_15.iwd
	rm $lang
	echo "DONE main files for 1.0"
	
	cd ~/cod2_1_3/main
	for file in ~/cod2/main/*; do fname=${file##*/}; ln $file $fname; done
	echo "DONE main files for 1.3"
fi


#libcod
cd cod2
git clone https://github.com/voron00/libcod
cd libcod

./doit.sh cod2_1_0
mv bin/libcod2_1_0.so ~/cod2_1_0/libcod2_1_0.so
echo "DONE libcod for 1.0"

./doit.sh cod2_1_3
mv bin/libcod2_1_3.so ~/cod2_1_3/libcod2_1_3.so
echo "DONE libcod for 1.3"


# lnxded
echo
echo "Now place cod2_lnxded in ~/cod2_1_0 and ~/cod2_1_3"
read -p "Done? " -r
echo    
if [[ $REPLY =~ ^[Yy]$ ]]
then
	sudo chmod 500 ~/cod2_1_0/cod2_lnxded
	sudo chmod 500 ~/cod2_1_3/cod2_lnxded
fi


# servers
echo
echo "Now place your servers folders in ~/cod2"
read -p "Done? " -r
echo    
if [[ $REPLY =~ ^[Yy]$ ]]
then
	until [[ $REPLY =~ ^[Nn]$ ]]
	do
		read -p "Write the name of your server: " -r
		name=$REPLY
		read -p "Write the name of your server's config: " -r
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
		
		echo "DONE"
		echo
		read -p "Want to add another server? " -r
	done
fi


