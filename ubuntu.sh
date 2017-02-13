#!/bin/bash


echo Updates the repositories that create Ubuntu packages.


TMPLINUX=/tmp/bibledit-linux
echo Works with the tarball supposed to be already in $TMPLINUX.


LAUNCHPADLINUX=../launchpad/linux
echo Clean repository at LAUNCHPADLINUX.
rm -rf $LAUNCHPADLINUX/*


echo Unpack tarball into the repository.
tar --strip-components=1 -C $LAUNCHPADLINUX -xzf $TMPLINUX/bibledit*tar.gz


echo Commit to Launchpad.
pushd $LAUNCHPADLINUX
bzr add .
bzr commit -m "new upstream version"
bzr push
popd
