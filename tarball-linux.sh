#!/bin/bash

# Copyright (©) 2003-2022 Teus Benschop.

# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.


# This script runs in a Terminal on macOS.
# It requires a Linux machine accessible via the network.
# It refreshes and updates the bibledit sources.
# It generates a tarball for a Linux Bibledit client.


BUILDDIR=/tmp/bibledit-linux
echo Build directory at $BUILDDIR
cd $BUILDDIR
if [ $? -ne 0 ]; then exit; fi


echo Working in $BUILDDIR


echo Move the Bibledit Linux GUI sources into place
mv bibledit.h executable
if [ $? -ne 0 ]; then exit; fi

mv bibledit.cpp executable
if [ $? -ne 0 ]; then exit; fi


echo Remove unwanted files
rm valgrind
rm bibledit
rm dev
rm -rf unittests
find . -name .DS_Store -delete
rm -rf .git
find . -name "*.Po" -delete
rm -rf autom4te.cache
rm -rf *.xcodeproj
rm -rf xcode
#echo Remove macOS extended attributes.
#echo The attributes would make their way into the tarball,
#echo get unpacked within Debian,
#echo and would cause lintian errors.
#xattr -r -c *


echo Install build requirements
#sudo apt --yes --assume-yes install build-essential
#sudo apt --yes --assume-yes install autoconf
#sudo apt --yes --assume-yes install automake
#sudo apt --yes --assume-yes install autoconf-archive
#sudo apt --yes --assume-yes install git
#sudo apt --yes --assume-yes install zip
#sudo apt --yes --assume-yes install pkgconf
#sudo apt --yes --assume-yes install libcurl4-openssl-dev
#sudo apt --yes --assume-yes install libssl-dev
#sudo apt --yes --assume-yes install libatspi2.0-dev
#sudo apt --yes --assume-yes install libgtk-3-dev
#sudo apt --yes --assume-yes install libwebkit2gtk-3.0-dev
#sudo apt --yes --assume-yes install libwebkit2gtk-4.0-dev
#sudo apt --yes --assume-yes install curl
#sudo apt --yes --assume-yes install make


echo Clean source
./configure
if [ $? -ne 0 ]; then exit; fi
make distclean
if [ $? -ne 0 ]; then exit; fi


echo Enable the Linux configuration in config.h
sed -i.bak 's/ENABLELINUX=no/ENABLELINUX=yes/g' configure.ac
if [ $? -ne 0 ]; then exit; fi
sed -i.bak 's/# linux //g' configure.ac
if [ $? -ne 0 ]; then exit; fi
sed -i.bak 's/.*Tag8.*/AC_DEFINE([HAVE_LINUX], [1], [Enable installation on Linux])/g' configure.ac
if [ $? -ne 0 ]; then exit; fi
# A client does not need the cURL library.
sed -i.bak '/curl/d' configure.ac
if [ $? -ne 0 ]; then exit; fi
sed -i.bak '/CURL/d' configure.ac
if [ $? -ne 0 ]; then exit; fi
# A client does not need the OpenSSL library.
sed -i.bak '/OPENSSL/d' configure.ac
if [ $? -ne 0 ]; then exit; fi


echo Do not build the unit tests and the generator
echo Rename binary 'server' to 'bibledit'
sed -i.bak 's/server unittest generate/bibledit/g' Makefile.am
if [ $? -ne 0 ]; then exit; fi
sed -i.bak 's/server_/bibledit_/g' Makefile.am
if [ $? -ne 0 ]; then exit; fi
sed -i.bak '/unittest/d' Makefile.am
if [ $? -ne 0 ]; then exit; fi
sed -i.bak '/generate_/d' Makefile.am
if [ $? -ne 0 ]; then exit; fi
# Update what to distribute.
sed -i.bak 's/bible bibledit/bible/g' Makefile.am
if [ $? -ne 0 ]; then exit; fi
sed -i.bak '/EXTRA_DIST/ s/$/ *.desktop *.xpm *.png *.xml/' Makefile.am
if [ $? -ne 0 ]; then exit; fi
echo Do not link with cURL and OpenSSL
echo Both are not used
echo As a result, a Debian package finds itself having unsatisfied dependencies
echo Removing the flags fixes that
sed -i.bak '/CURL/d' Makefile.am
if [ $? -ne 0 ]; then exit; fi
sed -i.bak '/OPENSSL/d' Makefile.am
if [ $? -ne 0 ]; then exit; fi
echo Add the additional Makefile.mk fragment for the Linux app
echo '' >> Makefile.am
cat Makefile.mk >> Makefile.am
echo Remove the consecutive blank lines introduced by the above edit operations
sed -i.bak '/./,/^$/!d' Makefile.am
if [ $? -ne 0 ]; then exit; fi
echo Do not include "bibledit" in the distribution tarball
sed -i.bak '/^EXTRA_DIST/ s/bibledit//' Makefile.am
if [ $? -ne 0 ]; then exit; fi

echo Remove bibledit-cloud man file
rm man/bibledit-cloud.1
if [ $? -ne 0 ]; then exit; fi
sed -i.bak 's/man\/bibledit-cloud\.1//g' Makefile.am


# Update the network port number to a value different from 8080.
# This enables running Bibledit (client) and Bibledit Cloud simultaneously.
# This is no longer needed since Bibledit finds its own free port to run on.
# sed -i.bak 's/8080/9876/g' config/logic.cpp
# if [ $? -ne 0 ]; then exit; fi


echo Remove .bak files
find . -name "*.bak" -delete


echo Create distribution tarball
./reconfigure
if [ $? -ne 0 ]; then exit; fi
./configure
if [ $? -ne 0 ]; then exit; fi
make dist --jobs=2
if [ $? -ne 0 ]; then exit; fi


echo Copy the tarball to the Desktop
rm -f ~/bibledit*gz
cp *.gz ~
if [ $? -ne 0 ]; then exit; fi
