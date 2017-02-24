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


LINUXSOURCE=`dirname $0`
cd $LINUXSOURCE
LINUXSOURCE=`pwd`
echo Using source at $LINUXSOURCE
BIBLEDITLINUX=/tmp/bibledit-linux
echo Build directory at $BIBLEDITLINUX


function synchronize_source_code ()
{
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
}


function change_to_working_directory ()
{
echo Working in $BIBLEDITLINUX
cd $BIBLEDITLINUX
if [ $? -ne 0 ]; then exit; fi
}


function move_linux_gui_sources_into_place ()
{
# Move the Bibledit Linux GUI sources into place.
mv bibledit.h executable
if [ $? -ne 0 ]; then exit; fi
mv bibledit.cpp executable
if [ $? -ne 0 ]; then exit; fi
}


function remove_unwanted_files ()
{
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
}


function dist_clean_source ()
{
# Clean source.
./configure
if [ $? -ne 0 ]; then exit; fi
make distclean
if [ $? -ne 0 ]; then exit; fi
}


function create_package_data_dir_installer ()
{
# Create file with the directories and files to install in the package data directory.
# Remove the first character of it.
find . | cut -c 2- > installdata.txt
if [ $? -ne 0 ]; then exit; fi
# Remove blank lines.
sed -i.bak '/^$/d' installdata.txt
if [ $? -ne 0 ]; then exit; fi
# Do not install source files.
sed -i.bak '/\.cpp$/d' installdata.txt
if [ $? -ne 0 ]; then exit; fi
sed -i.bak '/\.c$/d' installdata.txt
if [ $? -ne 0 ]; then exit; fi
sed -i.bak '/\.h$/d' installdata.txt
if [ $? -ne 0 ]; then exit; fi
sed -i.bak '/\.hpp$/d' installdata.txt
if [ $? -ne 0 ]; then exit; fi
# Do not install license files.
# This fixes the lintian warning:
# W: bibledit: extra-license-file usr/share/bibledit/COPYING
# What happens that running ./reconfigure creates COPYING.
# That causes the lintian warning.
# So even if present, it should not be installed.
sed -i.bak '/COPYING/d' installdata.txt
if [ $? -ne 0 ]; then exit; fi
}


function enable_linux_in_config_h ()
{
# Enable the Linux app for in config.h.
sed -i.bak 's/ENABLELINUX=no/ENABLELINUX=yes/g' configure.ac
if [ $? -ne 0 ]; then exit; fi
sed -i.bak 's/# linux //g' configure.ac
if [ $? -ne 0 ]; then exit; fi
sed -i.bak 's/.*Tag8.*/AC_DEFINE([HAVE_LINUX], [1], [Enable installation on Linux])/g' configure.ac
if [ $? -ne 0 ]; then exit; fi
}


function update_configure_ac_and_makefile_am ()
{
# Pass the package data directory to config.h.
sed -i.bak 's/.*TagA.*/if test "x${prefix}" = "xNONE"; then/g' configure.ac
if [ $? -ne 0 ]; then exit; fi
sed -i.bak 's/.*TagB.*/  AC_DEFINE_UNQUOTED(PACKAGE_DATA_DIR, "${ac_default_prefix}\/share\/bibledit", [Package data directory])/g' configure.ac
if [ $? -ne 0 ]; then exit; fi
sed -i.bak 's/.*TagC.*/else/g' configure.ac
if [ $? -ne 0 ]; then exit; fi
sed -i.bak 's/.*TagD.*/  AC_DEFINE_UNQUOTED(PACKAGE_DATA_DIR, "${prefix}\/share\/bibledit", [Package data directory])/g' configure.ac
if [ $? -ne 0 ]; then exit; fi
sed -i.bak 's/.*TagE.*/fi/g' configure.ac
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
}


function reconfigure_make_dist ()
{
# Create distribution tarball.
./reconfigure
if [ $? -ne 0 ]; then exit; fi
./configure
if [ $? -ne 0 ]; then exit; fi
make dist --jobs=24
if [ $? -ne 0 ]; then exit; fi
}
