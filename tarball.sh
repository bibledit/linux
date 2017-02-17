#!/bin/bash

# Copyright (©) 2003-2016 Teus Benschop.

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


# This script runs in a Terminal on OS X.
# It refreshes and updates the bibledit sources.
# It builds a tarball for use on Linux.


# Update debian/changelog
VERSION=`grep PACKAGE_VERSION ../bibledit/lib/config.h | sed 's/#define PACKAGE_VERSION //' | sed 's/"//g'`
rm -f changelog
echo "bibledit ($VERSION) unstable; urgency=low" >> changelog
echo >> changelog
echo "  * new upstream version" >> changelog
echo >> changelog
echo -n " -- Teus Benschop <teusjannette@gmail.com>  " >> changelog
date -R >> changelog
echo >> changelog
cat debian/changelog >> changelog
mv changelog debian/changelog


# Synchronize source code.
LINUXSOURCE=`dirname $0`
cd $LINUXSOURCE
BIBLEDITLINUX=/tmp/bibledit-linux
echo Synchronizing relevant source code to $BIBLEDITLINUX
mkdir -p $BIBLEDITLINUX
rsync --archive --delete ../bibledit/lib/ $BIBLEDITLINUX
rsync --archive --exclude 'output*.txt' . $BIBLEDITLINUX/
echo Done


echo Working in $BIBLEDITLINUX
cd $BIBLEDITLINUX


# Move the Bibledit Linux GUI sources into place.
mv bibledit.h executable
mv bibledit.cpp executable


# Remove some scripts and tests.
rm valgrind
rm bibledit
rm dev
rm -rf unittests


echo Remove macOS clutter.
echo This includes the macOS extended attributes.
echo The attributes make their way into the tarball,
echo get unpacked within Debian,
echo and cause lintian errors.
find . -name .DS_Store -delete
xattr -r -c *


# Clean source.
./configure
make distclean


# Create file with the directories and files to install in the package data directory.
find . | cut -c 2- | sed '/^$/d' | sed '/\.git/d' | sed '/\.DS_Store/d' | sed '/\.Po/d' | sed '/\.cpp$/d' | sed '/\.c$/d' | sed '/\.h$/d' | sed '/\.hpp$/d' | sed '/autom4te/d' | sed '/\.xcodeproj/d' > installdata.txt


# Require $ rsync Todo may go out once new installation is in effect.
sed -i.bak 's/.*Tag1.*/AC_PATH_PROG(RSYNC_PATH, rsync, no)/g' configure.ac
sed -i.bak 's/.*Tag2.*/if test x$RSYNC_PATH = xno; then/g' configure.ac
sed -i.bak 's/.*Tag3.*/  AC_MSG_ERROR(Program "rsync" is needed. Install this first.)/g' configure.ac
sed -i.bak 's/.*Tag4.*/fi/g' configure.ac


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
sed -i.bak '/EXTRA_DIST/ s/$/ *.desktop *.xpm *.png *.1/' Makefile.am


# Add the additional Makefile.mk fragment for the Linux app.
echo '' >> Makefile.am
cat Makefile.mk >> Makefile.am


# Remove the consecutive blank lines introduced by the above edit operations.
sed -i.bak '/./,/^$/!d' Makefile.am


# Clean everything up and create distribution tarball.
rm *.bak
./reconfigure
./configure
make dist

