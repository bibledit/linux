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


echo Copying debian repository from macOS to sid.
rsync --archive -v --delete ../debian $DEBIANSID:.
if [ $? -ne 0 ]; then exit; fi


echo Remove untracked files from the working tree.
ssh -tt $DEBIANSID "cd debian; git clean -f"
if [ $? -ne 0 ]; then exit; fi


echo Import upstream tarball and use pristine-tar.
ssh -tt $DEBIANSID "cd debian; gbp import-dsc --create-missing-branches --pristine-tar ../bibledit_*.dsc"
if [ $? -ne 0 ]; then exit; fi


echo Build package from git.
ssh -tt $DEBIANSID "cd debian; gbp buildpackage"
if [ $? -ne 0 ]; then exit; fi


