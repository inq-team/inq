#!/bin/sh

# Resolve working directory from xinetd's configuration
cd `sed -n '/server_args/ s/^.*-s \(.*\).*$/\1/gp' /etc/xinetd.d/tftp`

# Main cycle
while read line; do
	`echo $line | grep -q "tftpd\[[0-9]*\]: SENT"` || continue
	filename=`echo $line | sed -n '/SENT/ s/^.*: SENT \(.*\) to .*$/\1/gp'`

	if `echo $filename | grep -q "pxelinux\.cfg\/01-"`; then
		to_del=`sed -n "s/^#//;1 p" $filename`
		for i in "$to_del"; do rm $i; done
	else
		[ -k "$filename" ] && rm $filename
	fi
done
