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


source ~/scr/sid-ip
echo The IP address of the Debian machine is $DEBIANSID.


echo Check that the Debian machine is alive.
ping -c 1 $DEBIANSID
if [ $? -ne 0 ]; then exit; fi


# echo Removing any previous build artifacts.
# ssh $DEBIANSID "rm bibledit*" 2>/dev/null


echo Build the Debian source package.
ssh -tt $DEBIANSID "cd bibledit*[0-9]; debuild -S -sa"
if [ $? -ne 0 ]; then exit; fi


echo Upload the Debian source package.
ssh -tt $DEBIANSID "dput mentors *source.changes"
if [ $? -ne 0 ]; then exit; fi


echo Sign the watched archive:
echo $ gpg --armor --detach-sign archive.tar.gz
