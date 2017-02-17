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


echo Updates the repositories that create Ubuntu packages.


# Bibledit support status:
# Precise 12.04: No support: package libwebkit2gtk-4.0-dev cannot be found


TMPLINUX=/tmp/bibledit-linux
echo Works with the tarball supposed to be already in $TMPLINUX.


LAUNCHPADUBUNTU=../launchpad/ubuntu
echo Clean repositoriy at $LAUNCHPADUBUNTU.
rm -rf $LAUNCHPADUBUNTU/*


LAUNCHPADTRUSTY=../launchpad/trusty
echo Clean repositoriy at $LAUNCHPADTRUSTY.
rm -rf $LAUNCHPADTRUSTY/*


echo Unpack tarball into the repositories.
tar --strip-components=1 -C $LAUNCHPADUBUNTU -xzf $TMPLINUX/bibledit*tar.gz
tar --strip-components=1 -C $LAUNCHPADTRUSTY -xzf $TMPLINUX/bibledit*tar.gz


export LANG="C"
export LC_ALL="C"


echo Change directory to repository.
pushd $LAUNCHPADUBUNTU
echo Remove clutter.
find . -name .DS_Store -delete
echo Commit to Launchpad.
bzr add .
bzr commit -m "new upstream version"
bzr push
echo Change directory back to origin.
popd


echo Change directory to repository.
pushd $LAUNCHPADTRUSTY
echo Update dependencies: Trusty has libwebkit2gtk-3.0-dev
sed -i.bak 's/libwebkit2gtk-4.0-dev/libwebkit2gtk-3.0-dev/g' debian/control
rm debian/control.bak
echo Remove clutter.
find . -name .DS_Store -delete
echo Commit to Launchpad.
bzr add .
bzr commit -m "new upstream version"
bzr push
echo Change directory back to origin.
popd
