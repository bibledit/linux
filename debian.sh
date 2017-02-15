#!/bin/bash


# Redirect stdout ( > ) into a named pipe ( >() ) running "tee"
exec > >(tee outputnew.txt)
# Same for stderr.
exec 2>&1


source ~/scr/sid-ip
echo The IP address of the Debian machine is $DEBIANSID.


echo Check that the Debian machine is alive.
ping -c 1 $DEBIANSID
if [ $? -ne 0 ]; then exit; fi


TMPLINUX=/tmp/bibledit-linux
echo Works with the tarball supposed to be already in $TMPLINUX.


echo Clean the Debian builder and copy the tarball to it.
ssh $DEBIANSID "rm -rf bibledit*"
if [ $? -ne 0 ]; then exit; fi
scp $TMPLINUX/*.gz $DEBIANSID:.
if [ $? -ne 0 ]; then exit; fi


echo Unpack and remove the tarball in Debian.
ssh $DEBIANSID "tar xf bibledit*gz"
if [ $? -ne 0 ]; then exit; fi
ssh $DEBIANSID "rm bibledit*gz"
if [ $? -ne 0 ]; then exit; fi


echo Do a license check.
ssh -tt $DEBIANSID "cd bibledit*; licensecheck --recursive --ignore debian --deb-machine *"
if [ $? -ne 0 ]; then exit; fi


echo Build the Debian packages.
ssh -tt $DEBIANSID "cd bibledit*; debuild -us -uc"
if [ $? -ne 0 ]; then exit; fi


echo Remove the generated build artifacts.
ssh $DEBIANSID "rm bibledit*"


echo Build the Debian package in a chroot.
ssh -tt $DEBIANSID "cd bibledit*; sbuild"
if [ $? -ne 0 ]; then exit; fi


echo Flushing output buffer.
sync


echo Showing difference with processed output.
diff --normal outputnew.txt outputdone.txt > outputdiff.txt
