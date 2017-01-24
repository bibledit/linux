#!/bin/bash


# This script runs in a Terminal on OS X.
# It refreshes and updates the bibledit sources.
# It builds a tar ball for use on Linux.


# Synchronize source code.
LINUXSOURCE=`dirname $0`
cd $LINUXSOURCE
BIBLEDITLINUX=/tmp/bibledit-linux
echo Synchronizing relevant source code to $BIBLEDITLINUX
mkdir -p $BIBLEDITLINUX
rsync --archive --delete ../bibledit/lib/ $BIBLEDITLINUX
rsync --archive . $BIBLEDITLINUX/
echo Done


echo Working in $BIBLEDITLINUX
cd $BIBLEDITLINUX


# Move the Bibledit Linux GUI sources into place.
mv bibledit.h executable
mv bibledit.cpp executable


# Remove unnecessary code and scripts.
rm valgrind
rm bibledit
rm dev


# Clean source.
./configure
make distclean


# Require $ rsync
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
sed -i.bak '/EXTRA_DIST/ s/$/ *.desktop *.xpm *.1/' Makefile.am


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

