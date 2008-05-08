#!/bin/sh
# server/tftpd-log-parser/tftpd-log-parser.sh - A part of Inquisitor project
# Copyright (C) 2004-2008 by Iquisitor team 
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Resolve working directory from xinetd's configuration
WORK_DIR=`sed -n '/server_args/ s/^.*-s \(.*\).*$/\1/gp' /etc/xinetd.d/tftp`

cd $WORK_DIR

# Main cycle
while read line; do
	`echo $line | grep -q "tftpd\[[0-9]*\]: SENT"` || continue
	filename=`echo $line | sed -n '/SENT/ s/^.*: SENT \(.*\) to .*$/\1/gp'`

	if `echo $filename | grep -q "pxelinux\.cfg\/01-"`; then
		rm `sed -n "s/^#//;1 p" $filename`
	else
		[ -k "$filename" ] && rm $filename
	fi
done
