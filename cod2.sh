#!/bin/bash

# update packages
apt-get update
echo "DONE update"
apt-get upgrade -y
echo "DONE upgrade"

# sh files
chmod 777 parts -R

# cod2 requirements
./parts/cod2_req.sh

# tools
apt-get -y install geoip-bin git vim make screen zip unzip
echo "DONE tools"

# no-ip
read -p "Install no-ip client? " -r
echo    
if [[ $REPLY =~ ^[Yy]$ ]]
then
	./parts/noip.sh
fi

# web server
read -p "Install web server? " -r
echo    
if [[ $REPLY =~ ^[Yy]$ ]]
then
    apt-get -y install mysql-server
	echo "DONE mysql-server"
	apt-get -y install lighttpd
	echo "DONE lighttpd"
	apt-get -y install php5
	echo "DONE php5"
	lighty-enable-mod cgi
	lighty-enable-mod fastcgi
	lighty-enable-mod fastcgi-php
	sed '/upload_max_filesize/s/2M/16M/g' /etc/php5/cgi/php.ini > ~/php_new.ini # increase max file upload to 16M
	mv ~/php_new.ini /etc/php5/cgi/php.ini
	service ligthhpd restart
	
	read -p "Install phpmyadmin? " -r
	echo    
	if [[ $REPLY =~ ^[Yy]$ ]]
	then
		apt-get -y install phpmyadmin
		echo "DONE phpmyadmin"
		ln -s /usr/share/phpmyadmin/ /var/www/
	fi
fi

# main user
read -p "Enter the name of main user: " -r
echo 
user=$REPLY
useradd $user -G sudo,www-data -b /home -m -s /bin/bash
chown $user:$user /home/$user
echo "created user $user"
passwd $user

#
cp ../cod2install /home/$user/cod2install

# log in new user
su $user

# set up servers
cd ~/
~/cod2install/parts/cod2_servers.sh