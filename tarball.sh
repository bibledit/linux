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


# Clean source.
./configure
make distclean


# Update the source for the configuration.
sed -i.bak 's/ENABLELINUX=no/ENABLELINUX=yes/g' configure.ac
sed -i.bak 's/# linux //g' configure.ac
sed -i.bak 's/.*Tag8.*/AC_DEFINE([HAVE_LINUX], [1], [Enable installation on Linux])/g' configure.ac


# Do not build the unit tests and the generator.
# Rename binary 'server' to 'bibledit'.
sed -i.bak 's/server unittest generate/bibledit/g' Makefile.am
sed -i.bak 's/server_/bibledit_/g' Makefile.am
sed -i.bak '/unittest/d' Makefile.am
sed -i.bak '/generate_/d' Makefile.am


sed -i.bak 's/bin_PROGRAMS/noinst_PROGRAMS/g' Makefile.am


# Update what to distribute.
sed -i.bak 's/bible bibledit/bible/g' Makefile.am
sed -i.bak '/EXTRA_DIST/ s/$/ *.desktop *.xpm *.sh *.1/' Makefile.am


# Install the man pages.
echo '' >> Makefile.am
echo 'man_MANS = *.1' >> Makefile.am


# Install the desktop shortcut.
echo '' >> Makefile.am
echo 'applicationdir = $(datadir)/applications' >> Makefile.am
echo 'application_DATA = bibledit.desktop' >> Makefile.am


# Install the application icon.
echo '' >> Makefile.am
echo 'appicondir = $(datadir)/pixmaps' >> Makefile.am
echo 'appicon_DATA = bibledit.xpm' >> Makefile.am


# Install the startup script.
echo '' >> Makefile.am
echo 'bin_SCRIPTS = bibledit.sh' >> Makefile.am


# Remove consecutive blank lines.
sed -i.bak '/./,/^$/!d' Makefile.am


# Move the GUI sources into place.
mv bibledit.h executable
mv bibledit.cpp executable


# Remove unnecessary programs.
rm valgrind
rm bibledit
rm dev
rm *.bak


# Clean everything up and create distribution tarball.
./reconfigure
make distclean
./configure
make dist

