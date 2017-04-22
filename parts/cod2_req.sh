# cod2 requirements
dpkg --add-architecture i386
apt-get -y install libstdc++5:i386 
echo "DONE libstdc++5"
apt-get -y install gcc-multilib
echo "DONE gcc-multilib"
apt-get -y install libmysqlclient-dev:i386
echo "DONE libmysqlclient-dev"
apt-get -y install g++-multilib 
echo "DONE g++-multilib"