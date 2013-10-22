#!/bin/sh

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
