#!/bin/bash

# path to sh
ABSOLUTE_FILENAME=$(readlink -e "$0")
# sh directory
DIRECTORY=$(dirname "$ABSOLUTE_FILENAME")


# server files
srv_upload=$(whiptail \
--title "Servers" \
--menu "Do you want to upload files from your old server via SSH?:" 10 60 2 \
"1" "Yes, let's upload it via SSH" \
"2" "No, I'll upload it by myself via FTP" \
3>&1 1>&2 2>&3)

case $srv_upload in
1)
	try_upload=1
	while [ "$try_upload" -eq 1 ]
	do
		upload_host=$(whiptail \
		--title "Connection" \
		--inputbox "Enter the remote host name" 10 60 \
		3>&1 1>&2 2>&3) || { echo "You chose cancel."; exit 1; }

		upload_login=$(whiptail \
		--title "Connection" \
		--inputbox "Enter the remote host login" 10 60 \
		3>&1 1>&2 2>&3) || { echo "You chose cancel."; exit 1; }

		upload_pass=$(whiptail \
		--title "Connection" \
		--passwordbox  "Enter the remote host password" 10 60 \
		3>&1 1>&2 2>&3) || { echo "You chose cancel."; exit 1; }
		
		sshpass -p "$upload_pass" ssh -q "$upload_login"@"$upload_host" exit
		if [ $? -eq 0 ]
		then
			whiptail \
			--title "Upload" --checklist \
			"Choose, what do you want to upload:" 15 60 8 \
			"servers" "fs_game of all servers" ON \
			"maps" "Library folder" ON \
			"db" "mysql database" ON \
			"libcod" "libcod version" OFF \
			2>settings --separate-output || { echo "You chose cancel."; exit 1; }

			while read -r choice
			do
				case $choice in
					servers) 	upload_servers=1
					;;
					maps) 		upload_maps=1
					;;
					db) 		upload_db=1
					;;
					libcod) 	upload_libcod=1
					;;
					
				esac
			done < settings
			
			if [ $servers -eq 1 ]
			then
				sshpass -p "$upload_pass" scp -r "$upload_login"@"$upload_host":~/cod2/servers ~/cod2
				echo "done servers"
			fi
			
			if [ $maps -eq 1 ]
			then
				sshpass -p "$upload_pass" scp -r "$upload_login"@"$upload_host":~/cod2/Library ~/cod2
				echo "done maps"
			fi
			
			if [ $db -eq 1 ]
			then
				mysql_login=$(whiptail \
				--title "Remote MySQL" \
				--inputbox "Enter mysql login" 10 60 \
				3>&1 1>&2 2>&3) || { echo "You chose cancel."; exit 1; }

				mysql_pass=$(whiptail \
				--title Remote "MySQL" \
				--passwordbox  "Enter mysql password" 10 60 \
				3>&1 1>&2 2>&3) || { echo "You chose cancel."; exit 1; }
			
				sshpass -p "$upload_pass" ssh -X "$upload_login"@"$upload_host" 'mysqldump -u"$mysql_login" -p"$mysql_pass" --all-databases' > backup.sql
				
				mysql_login1=$(whiptail \
				--title "Local MySQL" \
				--inputbox "Enter mysql login" 10 60 \
				3>&1 1>&2 2>&3) || { echo "You chose cancel."; exit 1; }

				mysql_pass1=$(whiptail \
				--title Local "MySQL" \
				--passwordbox  "Enter mysql password" 10 60 \
				3>&1 1>&2 2>&3) || { echo "You chose cancel."; exit 1; }
				
				mysql -u"$mysql_login1" –-password="$mysql_pass1" < backup.sql 
				echo "done db"
			fi
			
			if [ $libcod -eq 1 ]
			then
				rm ~/cod2_1_0/libcod2_1_0.so
				rm ~/cod2_1_2/libcod2_1_2.so
				rm ~/cod2_1_3/libcod2_1_3.so
				sshpass -p "$upload_pass" scp -r "$upload_login"@"$upload_host":~/cod2_1_0/libcod2_1_0.so ~/cod2_1_0
				sshpass -p "$upload_pass" scp -r "$upload_login"@"$upload_host":~/cod2_1_2/libcod2_1_2.so ~/cod2_1_2
				sshpass -p "$upload_pass" scp -r "$upload_login"@"$upload_host":~/cod2_1_3/libcod2_1_3.so ~/cod2_1_3
				echo "done libcod"
			fi
			
			try_upload=0
			
		else
			if ! (whiptail --title "Error!" --yesno "Can't connect to the remote host. Would you like to try again?" 10 60) 
			then
				try_upload=0
			fi
		fi
	done
	;;
	
2)
	whiptail \
	--title "Servers" \
	--msgbox "Now place your servers folders (fs_game) in ~/cod2/servers/\\nChoose Ok after upload." 10 60
	;;
	
esac
