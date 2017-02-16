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


SRCDIR=$1
DESTDIR=$2
PKGDATADIR=$3

FILE=$SRCDIR/installdata.txt
PATHS=`cat $FILE`

for PATH in $PATHS;
do
if [ -d "$SRCDIR/$PATH" ]
then
echo $PATH
mkdir $DESTDIR$PKGDATADIR$PATH
else
cp $SRCDIR/$PATH $DESTDIR$PKGDATADIR$PATH
fi

done
