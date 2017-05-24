#!/bin/bash

# Copyright (©) 2003-2017 Teus Benschop.

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
# It refreshes and updates the bibledit sources.
# It builds a tarball for use on Linux.


LINUXSOURCE=`dirname $0`
cd $LINUXSOURCE
if [ $? -ne 0 ]; then exit; fi
LINUXSOURCE=`pwd`
echo Using source at $LINUXSOURCE
BIBLEDITLINUX=/tmp/bibledit-linux
echo Build directory at $BIBLEDITLINUX


# Synchronize source code.
cd $LINUXSOURCE
if [ $? -ne 0 ]; then exit; fi
echo Synchronizing relevant source code to $BIBLEDITLINUX
mkdir -p $BIBLEDITLINUX
if [ $? -ne 0 ]; then exit; fi
rsync --archive --delete ../cloud/ $BIBLEDITLINUX/
if [ $? -ne 0 ]; then exit; fi
rsync --archive . $BIBLEDITLINUX/
if [ $? -ne 0 ]; then exit; fi
echo Done


echo Working in $BIBLEDITLINUX
cd $BIBLEDITLINUX
if [ $? -ne 0 ]; then exit; fi


# Move the Bibledit Linux GUI sources into place.
mv bibledit.h executable
if [ $? -ne 0 ]; then exit; fi
mv bibledit.cpp executable
if [ $? -ne 0 ]; then exit; fi


# Remove unwanted files.
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
echo Remove macOS extended attributes.
echo The attributes would make their way into the tarball,
echo get unpacked within Debian,
echo and would cause lintian errors.
xattr -r -c *


# Clean source.
./configure
if [ $? -ne 0 ]; then exit; fi
make distclean
if [ $? -ne 0 ]; then exit; fi


# Enable the Linux configuration in config.h.
sed -i.bak 's/ENABLELINUX=no/ENABLELINUX=yes/g' configure.ac
if [ $? -ne 0 ]; then exit; fi
sed -i.bak 's/# linux //g' configure.ac
if [ $? -ne 0 ]; then exit; fi
sed -i.bak 's/.*Tag8.*/AC_DEFINE([HAVE_LINUX], [1], [Enable installation on Linux])/g' configure.ac
if [ $? -ne 0 ]; then exit; fi


# Do not build the unit tests and the generator.
# Rename binary 'server' to 'bibledit'.
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
sed -i.bak '/EXTRA_DIST/ s/$/ *.desktop *.xpm *.png bibledit.1/' Makefile.am
if [ $? -ne 0 ]; then exit; fi
# Do not link with cURL and OpenSSL.
# Both are not used.
# As a result, a Debian package finds itself having unsatisfied dependencies.
# Removing the flags fixes that.
sed -i.bak '/CURL/d' Makefile.am
if [ $? -ne 0 ]; then exit; fi
sed -i.bak '/OPENSSL/d' Makefile.am
if [ $? -ne 0 ]; then exit; fi
# Add the additional Makefile.mk fragment for the Linux app.
echo '' >> Makefile.am
cat Makefile.mk >> Makefile.am
# Remove the consecutive blank lines introduced by the above edit operations.
sed -i.bak '/./,/^$/!d' Makefile.am
if [ $? -ne 0 ]; then exit; fi
# Remove .bak files.
rm *.bak


# Create distribution tarball.
./reconfigure
if [ $? -ne 0 ]; then exit; fi
./configure
if [ $? -ne 0 ]; then exit; fi
make dist --jobs=24
if [ $? -ne 0 ]; then exit; fi


# Copy the tarball to the Desktop
cp *.gz ~/Desktop
if [ $? -ne 0 ]; then exit; fi
