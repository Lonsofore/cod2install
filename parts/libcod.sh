#!/bin/bash

# libcod
cd ~/cod2 || { echo "Error! libcod.sh line 4"; exit 1; }
git clone https://github.com/voron00/libcod
cd libcod || { echo "Error! libcod.sh line 6"; exit 1; }

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