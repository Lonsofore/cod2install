#!/bin/bash

# sh files
chmod 777 parts -R

# update packages
echo "updating packets..."
apt-get update > /dev/null
echo "done update"

echo
echo "upgrading packets..."
apt-get upgrade -y > /dev/null
echo "done upgrade"

# cod2 requirements
./parts/cod2_req.sh

# tools
echo
echo "installing tools..."
apt-get -y install geoip-bin git vim make screen zip unzip > /dev/null
echo "done tools"

# no-ip
echo
read -p "Install no-ip client? " -r
if [[ $REPLY =~ ^[Yy]$ ]]
then
	./parts/noip.sh
fi

# web server
echo
read -p "Install web server? " -r
if [[ $REPLY =~ ^[Yy]$ ]]
then
	echo
	echo "installing mysql-server..."
    apt-get -y install mysql-server
	echo "done mysql-server"
	
	echo
	echo "installing lighttpd..."
	apt-get -y install lighttpd > /dev/null
	echo "done lighttpd"
	
	lighty-enable-mod cgi
	lighty-enable-mod fastcgi
	lighty-enable-mod fastcgi-php
	sed '/upload_max_filesize/s/2M/16M/g' /etc/php5/cgi/php.ini > ~/php_new.ini # increase max file upload to 16M
	mv ~/php_new.ini /etc/php5/cgi/php.ini
	service lighttpd stop
	
	echo
	read -p "Install phpmyadmin? " -r
	if [[ $REPLY =~ ^[Yy]$ ]]
	then
		echo "installing phpmyadmin..."
		apt-get -y install phpmyadmin
		echo "done phpmyadmin"
		ln -s /usr/share/phpmyadmin/ /var/www/
	fi
	
	# bicycle! bicycle!
	echo
	service lighttpd stop
	service apache2 stop
	apt-get purge apache2 -y
	service lighttpd start
fi

# main user
echo
read -p "Enter the name of main user: " -r
echo 
user=$REPLY
useradd $user -G sudo,www-data -b /home -m -s /bin/bash
echo "created user $user"
passwd $user
echo

# copy files to new user
cp ~/cod2install /home/$user/cod2install -R
chmod 777 /home/$user/cod2install -R
chown $user:$user /home/$user -R

# log in new user and and set up servers
sudo -H -u $user sh -c '~/cod2install/parts/cod2_servers.sh'

# and after all we need to reboot
echo
echo "That's all, let's reboot now"
reboot