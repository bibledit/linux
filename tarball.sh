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


# Synchronize source code.
LINUXSOURCE=`dirname $0`
cd $LINUXSOURCE
BIBLEDITLINUX=/tmp/bibledit-linux
echo Synchronizing relevant source code to $BIBLEDITLINUX
rm -rf $BIBLEDITLINUX/*
rm -rf $BIBLEDITLINUX/.* 2> /dev/null
mkdir -p $BIBLEDITLINUX
rsync --archive ../bibledit/lib/ $BIBLEDITLINUX
rsync --archive . $BIBLEDITLINUX/
echo Done


echo Working in $BIBLEDITLINUX
cd $BIBLEDITLINUX


# Move the Bibledit Linux GUI sources into place.
mv bibledit.h executable
mv bibledit.cpp executable


# Remove unwanted files.
rm valgrind
rm bibledit
rm dev
rm -rf unittests
rm debian*.txt
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
make distclean


# Create file with the directories and files to install in the package data directory.
# Remove blank lines.
# Do not install source files.
find . | cut -c 2- | sed '/^$/d' | sed '/\.cpp$/d' | sed '/\.c$/d' | sed '/\.h$/d' | sed '/\.hpp$/d' > installdata.txt


# Enable the Linux app for in config.h.
sed -i.bak 's/ENABLELINUX=no/ENABLELINUX=yes/g' configure.ac
sed -i.bak 's/# linux //g' configure.ac
sed -i.bak 's/.*Tag8.*/AC_DEFINE([HAVE_LINUX], [1], [Enable installation on Linux])/g' configure.ac


# Pass the package data directory to config.h.
sed -i.bak 's/.*TagA.*/if test "x${prefix}" = "xNONE"; then/g' configure.ac
sed -i.bak 's/.*TagB.*/  AC_DEFINE_UNQUOTED(PACKAGE_DATA_DIR, "${ac_default_prefix}\/share\/bibledit", [Package data directory])/g' configure.ac
sed -i.bak 's/.*TagC.*/else/g' configure.ac
sed -i.bak 's/.*TagD.*/  AC_DEFINE_UNQUOTED(PACKAGE_DATA_DIR, "${prefix}\/share\/bibledit", [Package data directory])/g' configure.ac
sed -i.bak 's/.*TagE.*/fi/g' configure.ac


# Do not build the unit tests and the generator.
# Rename binary 'server' to 'bibledit'.
sed -i.bak 's/server unittest generate/bibledit/g' Makefile.am
sed -i.bak 's/server_/bibledit_/g' Makefile.am
sed -i.bak '/unittest/d' Makefile.am
sed -i.bak '/generate_/d' Makefile.am


# Update what to distribute.
sed -i.bak 's/bible bibledit/bible/g' Makefile.am
sed -i.bak '/EXTRA_DIST/ s/$/ *.desktop *.xpm *.png bibledit.1/' Makefile.am


# Add the additional Makefile.mk fragment for the Linux app.
echo '' >> Makefile.am
cat Makefile.mk >> Makefile.am


# Remove the consecutive blank lines introduced by the above edit operations.
sed -i.bak '/./,/^$/!d' Makefile.am


# Clean everything up and create distribution tarball.
rm *.bak
./reconfigure
./configure
make dist --jobs=24

