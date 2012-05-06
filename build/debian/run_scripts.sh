#!/bin/sh

export CHROOT_PATH REPO BRANCH SERVER DEBUG_TTY

cd build/debian/scripts
for script in *; do
	echo; echo "Running $script"
	./$script
	echo; echo "$script done"
done
