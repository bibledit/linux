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


# Redirect stdout ( > ) into a named pipe ( >() ) running "tee"
exec > >(tee ~/Desktop/debian.txt)
# Same for stderr.
exec 2>&1


source ~/scr/sid-ip
echo The IP address of the Debian machine is $DEBIANSID.


echo Check that the Debian machine is alive.
ping -c 1 $DEBIANSID
if [ $? -ne 0 ]; then exit; fi


TMPLINUX=/tmp/bibledit-linux
echo Works with the tarball supposed to be already in $TMPLINUX.


echo Clean the Debian builder and copy the tarball to it.
ssh $DEBIANSID "rm -rf bibledit*"
if [ $? -ne 0 ]; then exit; fi
scp $TMPLINUX/*.gz $DEBIANSID:.
if [ $? -ne 0 ]; then exit; fi


echo Unpack and remove the tarball in Debian.
ssh $DEBIANSID "tar xf bibledit*gz"
if [ $? -ne 0 ]; then exit; fi
ssh $DEBIANSID "rm bibledit*gz"
if [ $? -ne 0 ]; then exit; fi


echo Link with the system-provided mbed TLS library.
# A fix for lintian error "embedded-library usr/bin/bibledit: mbedtls"
# is to remove mbedtls from the list of sources to compile
# and to add -lmbedtls to the linker flags instead.
ssh -tt $DEBIANSID "cd bibledit*; sed -i.bak '/mbedtls\//d' Makefile.am"
if [ $? -ne 0 ]; then exit; fi
ssh -tt $DEBIANSID "cd bibledit*; sed -i.bak 's/# debian//g' Makefile.am"
if [ $? -ne 0 ]; then exit; fi


echo Reconfiguring the source.
ssh -tt $DEBIANSID "cd bibledit*; ./reconfigure"
if [ $? -ne 0 ]; then exit; fi
ssh -tt $DEBIANSID "cd bibledit*; rm -rf autom4te.cache"
if [ $? -ne 0 ]; then exit; fi


echo Remove extra license files.
# Fix the lintian warnings "extra-license-file".
ssh -tt $DEBIANSID "find . -name COPYING -delete"
if [ $? -ne 0 ]; then exit; fi
ssh -tt $DEBIANSID "find . -name LICENSE -delete"
if [ $? -ne 0 ]; then exit; fi


echo Remove extra font files.
# Fix the lintian warning "duplicate-font-file".
ssh -tt $DEBIANSID "cd bibledit*; rm fonts/SILEOT.ttf"
if [ $? -ne 0 ]; then exit; fi


echo Do a license check.
ssh -tt $DEBIANSID "cd bibledit*; licensecheck --recursive --ignore debian --deb-machine *"
if [ $? -ne 0 ]; then exit; fi


echo Build the Debian packages.
ssh -tt $DEBIANSID "cd bibledit*; debuild -us -uc"
if [ $? -ne 0 ]; then exit; fi


echo Do a pedantic lintian check.
ssh -tt $DEBIANSID "lintian --pedantic bibledit*changes"
if [ $? -ne 0 ]; then exit; fi


echo Remove the generated build artifacts.
ssh $DEBIANSID "rm bibledit*"


echo Build the Debian package in a chroot.
ssh -tt $DEBIANSID "cd bibledit*; sbuild"
if [ $? -ne 0 ]; then exit; fi


