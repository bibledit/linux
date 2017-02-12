#!/bin/sh


source ~/scr/sid-ip
echo The IP address of the Debian machine is $DEBIANSID


echo Create a tarball in /tmp/bibledit-linux.
# ./tarball.sh


echo Check that the Debian machine is alive.
ping -c 1 $DEBIANSID
if [ $? -ne 0 ]; then exit; fi



exit










make dist
if [ $? -ne 0 ]; then exit; fi


echo Clean the Debian builder and copy the tarball to it.
ssh $DEBIANSID "rm -rf bibledit*"
if [ $? -ne 0 ]; then exit; fi
scp *.gz $DEBIANSID:.
if [ $? -ne 0 ]; then exit; fi


echo Clean the working tree in the repository.
make distclean
if [ $? -ne 0 ]; then exit; fi


echo Unpack and remove the tarball in Debian.
ssh $DEBIANSID "tar xf bibledit*gz"
if [ $? -ne 0 ]; then exit; fi
ssh $DEBIANSID "rm bibledit*gz"
if [ $? -ne 0 ]; then exit; fi


echo Do a license check.
ssh $DEBIANSID "cd bibledit*; licensecheck --recursive --ignore debian --deb-machine *"
if [ $? -ne 0 ]; then exit; fi


echo Build the Debian packages.
ssh $DEBIANSID "cd bibledit*; debuild -us -uc"
if [ $? -ne 0 ]; then exit; fi


echo Remove the generated build artifacts.
ssh $DEBIANSID "rm bibledit*"


echo Build the Debian package in a chroot.
ssh -tt $DEBIANSID "cd bibledit*; sbuild"
if [ $? -ne 0 ]; then exit; fi


