#!/bin/bash

# Copyright (©) 2003-2020 Teus Benschop.

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


echo Using Debian sid as builder
source ~/scr/sid-ip


LINUXSOURCE=`dirname $0`
cd $LINUXSOURCE
if [ $? -ne 0 ]; then exit; fi
LINUXSOURCE=`pwd`
echo Using source at $LINUXSOURCE
BUILDDIR=/tmp/bibledit-linux
echo Build directory at $BUILDDIR


# Synchronize source code.
cd $LINUXSOURCE
if [ $? -ne 0 ]; then exit; fi
echo Synchronizing relevant source code to $BUILDDIR
rm -rf $BUILDDIR
if [ $? -ne 0 ]; then exit; fi
mkdir -p $BUILDDIR
if [ $? -ne 0 ]; then exit; fi
rsync --archive ../cloud/ $BUILDDIR/
if [ $? -ne 0 ]; then exit; fi
rsync --archive . $BUILDDIR/
if [ $? -ne 0 ]; then exit; fi
echo Done


echo Copying $BUILDDIR to $DEBIANSID and working there
rsync --archive --delete $BUILDDIR/ $DEBIANSID:$BUILDDIR/
scp tarball-linux.sh $DEBIANSID:.
if [ $? -ne 0 ]; then exit; fi
ssh $DEBIANSID "./tarball-linux.sh"
if [ $? -ne 0 ]; then exit; fi

echo Copying resulting tarball
rm -f ~/Desktop/bibledit*gz
scp $DEBIANSID:"bibledit*gz" ~/Desktop

