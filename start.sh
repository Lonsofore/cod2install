#!/bin/bash

# path to sh
ABSOLUTE_FILENAME=`readlink -e "$0"`
# sh directory
DIRECTORY=`dirname "$ABSOLUTE_FILENAME"`

# sh files
chmod 500 $DIRECTORY/parts -R

# update packages
echo "updating packets..."
apt-get update
echo "done update"

echo
echo "upgrading packets..."
apt-get upgrade -y
echo "done upgrade"

apt-get install whiptail -y

whiptail \
--title "About" \
--msgbox "Welcome to cod2install.\nVisit https://github.com/lonsofore/cod2install to get more information.\nChoose Ok to continue." 10 60

option=$(whiptail \
--title "Install mode" \
--menu "Choose your option" 10 60 3 \
"1" "Minimal (only CoD2)" \
"2" "Full (CoD2 + Web Server)" \
"3" "Custom" \
3>&1 1>&2 2>&3) || { echo "You chose cancel."; exit 1; }

inst_lib=0
inst_serv=0
inst_user=0
inst_web=0
inst_mysql=0
inst_pma=0
inst_noip=0
inst_zram=0

case $option in
	1) 	
		inst_lib=1
		inst_serv=1
		inst_user=1
		inst_noip=-1
		inst_zram=-1
		;;
		
	2) 	
		inst_lib=1
		inst_serv=1
		inst_user=1
		inst_web=1
		inst_mysql=1
		inst_pma=1
		inst_noip=-1
		inst_zram=-1
		;;
	
	3) 	
		whiptail \
		--title "Custom installation" --checklist \
		"Choose, what do you want to install:" 15 60 8 \
		"cod2-libraries" "All libraries for CoD2" ON \
		"cod2-servers" "Setup your CoD2 servers" ON \
		"new-user" "Create new user (for cod2)" ON \
		"web-server" "Web server" ON \
		"mysql-server" "MySQL server" ON \
		"phpmyadmin" "MySQL administration" ON \
		"noip-client" "Dyn dns (for gametracker.com)" OFF \
		"zram" "Read about it in the internet!" OFF \
		2>settings --separate-output || { echo "You chose cancel."; exit 1; }

		while read choice
		do
			case $choice in
				cod2-libraries) inst_lib=1
				;;
				cod2-servers) 	inst_serv=1
				;;
				new-user) 		inst_user=1
				;;
				web-server) 	inst_web=1
				;;
				mysql-server) 	inst_mysql=1
				;;
				phpmyadmin) 	inst_pma=1
				;;
				noip-client) 	inst_noip=1
				;;
				zram) 			inst_zram=1
				;;
				
			esac
		done < settings
		;;
esac

# settings: web server
if [ $inst_web -eq 1 ]
then
	inst_web_serv=$(whiptail \
	--title "Web server" \
	--menu "Choose your web server" 10 60 2 \
	"1" "lighttpd" \
	"2" "apache2" \
	3>&1 1>&2 2>&3)
fi

# settings: no ip client
if [ $inst_noip -eq -1 ]
then
	if (whiptail --title "No-ip client" --yesno "Install no-ip client? Use can use it for gametracker.com (dynamic dns). It will require your noip account data, register on noip.com first!" 10 60 --defaultno) 
	then
		inst_noip=1
	else
		inst_noip=0
	fi
fi

# settings: compressor
if [ $inst_zram -eq -1 ]
then
	if (whiptail --title "Compressor" --yesno "Install zRam? Read about it before!" 10 60 --defaultno) 
	then
		inst_zram=1
	else
		inst_zram=0
	fi
fi

# tools
echo
echo "installing tools..."
apt-get -y install geoip-bin git vim make screen zip unzip perl aria2
echo "done tools"

# zram
if [ $inst_zram -eq 1 ]
then
	apt-get -y install zram-config
fi	

# cod2 requirements
if [ $inst_lib -eq 1 ]
then
	$DIRECTORY/parts/req.sh
fi

# noip
if [ $inst_noip -eq 1 ]
then
	$DIRECTORY/parts/noip.sh
fi

# web server
if [ $inst_web -eq 1 ]
then	
	# mysql-server
	if [ $inst_mysql -eq 1 ]
	then
		echo
		echo "installing mysql-server..."
		apt-get install mysql-server -y
		echo "done mysql-server"
	fi
	
	# web server: lighttpd or apache2
	if [ $inst_web_serv -eq 1 ]
	then
		echo
		echo "installing lighttpd..."
		apt-get install lighttpd -y
		echo "done lighttpd"
		
		lighty-enable-mod cgi
		lighty-enable-mod fastcgi
		lighty-enable-mod fastcgi-php
		
		service lighttpd stop
	else
		echo
		echo "installing apache2..."
		apt-get install apache2 -y
		echo "done apache2"
	fi
	
	# phpmyadmin
	if [ $inst_pma -eq 1 ]
	then
		# we should install php5-cgi before
		echo
		echo "installing php5-cgi..."
		apt-get install php5-cgi -y
		echo "done php5-cgi"
		
		# increase max file upload to 16M
		sed '/upload_max_filesize/s/2M/16M/g' /etc/php5/cgi/php.ini > ~/php_new.ini 
		mv ~/php_new.ini /etc/php5/cgi/php.ini
		
		# phpmyadmin
		echo
		echo "installing phpmyadmin..."
		apt-get -y install phpmyadmin
		echo "done phpmyadmin"
		ln -s /usr/share/phpmyadmin/ /var/www/
	fi
	
	# protection: phpmyadmin can install apache2
	if [ $inst_web_serv -eq 1 ]
	then
		service lighttpd restart
		#service lighttpd stop
		#service apache2 stop
		#apt-get purge apache2 -y
		#service lighttpd start
	else
		service apache2 restart
	fi
fi

# create new user
if [ $inst_user -eq 1 ]
then
	user=$(whiptail \
	--title "Create new user" \
	--inputbox "Enter the name of new user" 10 60 \
	3>&1 1>&2 2>&3)
	
	echo 
	useradd $user -m -s /bin/bash
	echo "created user $user"
	passwd $user
	echo
	
	# copy files to new user
	cp ~/cod2install /home/$user/cod2install -R
	chown $user:$user /home/$user -R
	chmod 700 /home/$user/cod2install -R
	
	# log in new user and and set up servers
	if [ $inst_serv -eq 1 ]
	then
		sudo -H -u $user sh -c '~/cod2install/parts/cod2_servers.sh'
	fi
else
	# set up servers
	if [ $inst_serv -eq 1 ]
	then
		~/cod2install/parts/cod2.sh
	fi
fi

# final reboot
echo "That's all"
if (whiptail --title "Reboot" --yesno "Reboot the machine?" 10 60) 
then
	reboot
fi
