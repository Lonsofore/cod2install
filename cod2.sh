#!/bin/bash
apt-get update
echo "DONE update"

apt-get upgrade -y
echo "DONE upgrade"

# cod2 needs
dpkg --add-architecture i386
apt-get -y install libstdc++5:i386 
echo "DONE libstdc++5"
apt-get -y install gcc-multilib
echo "DONE gcc-multilib"
apt-get -y install libmysqlclient-dev:i386
echo "DONE libmysqlclient-dev"
apt-get -y install g++-multilib 
echo "DONE g++-multilib"

# other tools
apt-get -y install geoip-bin git vim make screen
echo "DONE tools"

# web server
read -p "Install web server? " -r
echo    
if [[ $REPLY =~ ^[Yy]$ ]]
then
    apt-get -y install mysql-server
	echo "DONE mysql-server"
	apt-get -y install lighttpd
	echo "DONE lighttpd"
	apt-get -y install php-fpm
	echo "DONE php-fpm"
	lighty-enable-mod cgi
	lighty-enable-mod fastcgi
	lighty-enable-mod fastcgi-php
	sed '/upload_max_filesize/s/2M/16M/g' /etc/php5/cgi/php.ini > ~/php_new.ini # increase max file upload to 16M
	mv ~/php_new.ini /etc/php5/cgi/php.ini
	service ligthhpd restart
	echo "RESTARTED lighttpd"
	apt-get -y install phpmyadmin
	echo "DONE phpmyadmin"
	cd /var/www
	sudo ln -s /usr/share/phpmyadmin/ ./
fi

# main user
read -p "Add new user? " -r
echo    
if [[ $REPLY =~ ^[Yy]$ ]]
then
	read -p "Enter the name of new user: " -r
	echo 
	useradd $REPLY -G sudo,www-data -b /home -m -s /bin/bash
	chown $REPLY:$REPLY /home/$REPLY
	echo "created user $REPLY"
	passwd $REPLY
fi

# no-ip
read -p "Install no-ip client? " -r
echo    
if [[ $REPLY =~ ^[Yy]$ ]]
then
	cd /usr/local/src
	wget http://www.no-ip.com/client/linux/noip-duc-linux.tar.gz
	tar xzf noip-duc-linux.tar.gz
	cd noip-2.1.9-1
	make
	make install
	echo "DONE no-ip"
fi

