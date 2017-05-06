#!/bin/bash

# no-ip
echo
cd /usr/local/src
wget http://www.no-ip.com/client/linux/noip-duc-linux.tar.gz
tar xzf noip-duc-linux.tar.gz
cd noip*
make
make install
cd ../
rm noip-duc-linux.tar.gz
echo "done no-ip"