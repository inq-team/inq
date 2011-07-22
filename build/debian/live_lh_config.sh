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
lb config \
	--mirror-bootstrap $REPO \
	--mirror-chroot $REPO \
	--linux-flavours $KERNEL_FLAVOUR \
	--linux-packages "linux-image-2.6" \
	--architecture $DEB_TARGET \
	--distribution $REPO_BRANCH \
	--iso-application Inquisitor \
	--iso-volume "Inquisitor $INQ_VERSION" \
	--iso-preparer "Sergey Matveev (stargrave@users.sourceforge.net)" \
	--iso-publisher "Sergey Matveev (stargrave@users.sourceforge.net)" \
	--bootappend-live "noautologin nolocales" \
	${CUSTOM_KERNEL_OPTION} \
	--apt-options='--allow-unauthenticated --yes' \
	--hostname inq \
	--binary-indices none \
	--apt-recommends false \
	--apt-secure false \
	--chroot-filesystem squashfs \
	--source false \
	--packages-lists inq.list \
	--bootloader syslinux \
	--bootstrap debootstrap \
	--cache false \
	--memtest memtest86+ \
	--security false \
	--checksums none \
	--net-tarball none \

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
# Hooks, splash image
################################################################################
cp live-chroot-hooks/* $WORKDIR/$LIVEDIR/config/chroot_local-hooks/
cp live-binary-hooks/* $WORKDIR/$LIVEDIR/config/binary_local-hooks/
cp live-additional/splash.xpm.gz $WORKDIR/$LIVEDIR/config/binary_grub
[ -s live-additional/menu.lst.in ] && sed "s/\$INQ_VERSION/$INQ_VERSION/g; s/\$DEB_TARGET/$DEB_TARGET/g" < live-additional/menu.lst.in > $WORKDIR/$LIVEDIR/config/binary_grub/menu.lst

################################################################################
# User interface pretty outlook
################################################################################
mkdir -p $WORKDIR/$LIVEDIR/config/chroot_local-includes/etc
cp live-additional/debian_version $WORKDIR/$LIVEDIR/config/chroot_local-includes/etc
cp live-additional/issue $WORKDIR/$LIVEDIR/config/chroot_local-includes/etc

popd

################################################################################
# Needed to be included files (in Tars)
################################################################################
for I in $IMAGE_DIR/*.tar $IMAGE_DIR/*.tar.gz $IMAGE_DIR/*.tar.bz2; do
	[ -r "$I" ] || break
	echo -n "Unpacking $I... "
	tar xf $I
	echo OK
done
cp $IMAGE_DIR/*.deb $WORKDIR/$LIVEDIR/config/chroot_local-packages || :
