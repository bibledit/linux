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


echo Updating the debian/changelog.
VERSION=`grep PACKAGE_VERSION ../bibledit/lib/config.h | sed 's/#define PACKAGE_VERSION //' | sed 's/"//g'`
rm -f changelog
echo "bibledit ($VERSION-1) unstable; urgency=low" >> changelog
echo >> changelog
echo "  * new upstream version" >> changelog
echo >> changelog
echo -n " -- Teus Benschop <teusjannette@gmail.com>  " >> changelog
date -R >> changelog
echo >> changelog
cat debian/changelog >> changelog
mv changelog debian/changelog
