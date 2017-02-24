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


# This script runs in a Terminal on macOS.
# It refreshes and updates the bibledit sources.
# It builds a tarball for use on Linux.


# Including shared functions.
source shared.sh
if [ $? -ne 0 ]; then exit; fi


synchronize_source_code
change_to_working_directory
move_linux_gui_sources_into_place
remove_unwanted_files
dist_clean_source
create_package_data_dir_installer
enable_linux_in_config_h
update_configure_ac_and_makefile_am
reconfigure_make_dist

