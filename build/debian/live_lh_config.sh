#!/bin/bash -x

pushd build/debian

################################################################################
# Decide which kernel flavour to use
################################################################################
if [ "$DEB_TARGET" = "i386" ]; then
	KERNEL_FLAVOUR="686"
else
	KERNEL_FLAVOUR="amd64"
fi

if [ -n "$CUSTOM_KERNEL" ]; then
	CUSTOM_KERNEL_OPTION="--linux-packages none"
else
	CUSTOM_KERNEL_OPTION=""
fi

################################################################################
# Run LiveHelper configuration utility itself
################################################################################
pushd $WORKDIR/$LIVEDIR
lh config --mirror-bootstrap $REPO --mirror-chroot $REPO \
          --linux-flavours $KERNEL_FLAVOUR \
          --linux-packages "linux-image-2.6 aufs-modules-2.6" \
          --architecture $DEB_TARGET \
          --distribution $REPO_BRANCH \
          --iso-application Inquisitor \
          --iso-volume "Inquisitor $INQ_VERSION" \
          --iso-preparer "Sergey Matveev (stargrave@users.sourceforge.net)" \
          --iso-publisher "Sergey Matveev (stargrave@users.sourceforge.net)" \
          --bootappend-live "noautologin nolocales" \
          ${CUSTOM_KERNEL_OPTION} \
          --hostname inq \
          --binary-indices disabled \
          --apt-recommends disabled \
          --apt-secure disabled \
          --bootstrap-flavour minimal \
          --chroot-filesystem squashfs \
          --source disabled \
          --packages-list inq.list \
          --bootloader grub \
          --bootstrap debootstrap \
          --cache disabled \
          --memtest memtest86+ \
          --security disabled \
          --checksums disabled \
          --net-tarball none \
          --apt-options='--allow-unauthenticated --yes'
popd

################################################################################
# Add Debian-multimedia repository
################################################################################
echo "deb $REPO_MULTIMEDIA $REPO_BRANCH main" > $WORKDIR/$LIVEDIR/config/chroot_sources/debian-multimedia.chroot

################################################################################
# Packages list, pressed file, Inquisitor package
################################################################################
cp packages.live $WORKDIR/$LIVEDIR/config/chroot_local-packageslists/inq.list
cp preseed.live $WORKDIR/$LIVEDIR/config/chroot_local-preseed/inq
cp $WORKDIR/build-package/$PACKAGE_DEB $WORKDIR/$LIVEDIR/config/chroot_local-packages

################################################################################
# Needed to be included files (in Tars)
################################################################################
for include in ../../$IMAGE_DIR/*.tar; do
	tar xvfC "$include" $WORKDIR/$LIVEDIR/config/chroot_local-includes
done
cp ../../$IMAGE_DIR/*.deb $WORKDIR/$LIVEDIR/config/chroot_local-packages

################################################################################
# Hooks, splash image
################################################################################
cp live-chroot-hooks/* $WORKDIR/$LIVEDIR/config/chroot_local-hooks/
cp live-binary-hooks/* $WORKDIR/$LIVEDIR/config/binary_local-hooks/
cp live-additional/splash.xpm.gz $WORKDIR/$LIVEDIR/config/binary_grub
[ -s live-additional/menu.lst.in ] && sed "s/\$INQ_VERSION/$INQ_VERSION/g; s/\$DEB_TARGET/$DEB_TARGET/g" < live-additional/menu.lst.in > $WORKDIR/$LIVEDIR/config/binary_grub/menu.lst

################################################################################
# User interface pretty outlook
################################################################################
mkdir $WORKDIR/$LIVEDIR/config/chroot_local-includes/etc
cp live-additional/debian_version $WORKDIR/$LIVEDIR/config/chroot_local-includes/etc
cp live-additional/issue $WORKDIR/$LIVEDIR/config/chroot_local-includes/etc

################################################################################
# Generate motd based on current tests in trunk
################################################################################
cat <<__EOF__ > $WORKDIR/$LIVEDIR/config/chroot_local-includes/etc/motd
Welcome to command-line ${COLOR_YELLOW}Inquisitor${COLOR_NORMAL} interface

You can use commands:

${COLOR_GREEN}inquisitor${COLOR_NORMAL} - execute Inquisitor testing in whole (normal testing mode)
${COLOR_GREEN}inq-detect${COLOR_NORMAL} - execute detects only
${COLOR_GREEN}inq-software-detect${COLOR_NORMAL} - execute software detects only
${COLOR_GREEN}${SHARE_DIR}/test/${COLOR_YELLOW}STAGE${COLOR_NORMAL} - execute particular test ${COLOR_YELLOW}STAGE${COLOR_NORMAL}, one of:
${COLOR_BLUE}
__EOF__

TMPDIR=`mktemp -d`
cp ../../client/test/* $TMPDIR 2>/dev/null
ls --color -C $TMPDIR >> $WORKDIR/$LIVEDIR/config/chroot_local-includes/etc/motd
rm -fr $TMPDIR 2>/dev/null
echo "${COLOR_NORMAL}" >> $WORKDIR/$LIVEDIR/config/chroot_local-includes/etc/motd

popd

