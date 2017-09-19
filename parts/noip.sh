#!/bin/bash

# no-ip
echo
cd /usr/local/src || { echo "Error! noip.sh line 5"; exit 1; }
wget http://www.no-ip.com/client/linux/noip-duc-linux.tar.gz
tar xzf noip-duc-linux.tar.gz
cd noip* || { echo "Error! noip.sh line 8"; exit 1; }
make
make install
cd ../ || { echo "Error! noip.sh line 11"; exit 1; }
rm noip-duc-linux.tar.gz
echo "done no-ip"