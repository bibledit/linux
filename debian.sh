#!/bin/sh

# ./configure
# make clean
# make distclean
# ./configure
# make dist
# make
# sudo make install
# sudo make uninstall

DEBIAN=192.168.2.106
FOLDER=bibledit-1.0.100

rsync -av --delete ../linux/ $DEBIAN:$FOLDER/
ssh $DEBIAN "cd $FOLDER; debuild -us -uc"
