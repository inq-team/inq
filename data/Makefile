.EXPORT_ALL_VARIABLES:

include ../Makefile.config
include ../flavour/$(FLAVOUR)

DEST_DIR=out

all: \
	$(DEST_DIR) \
	$(DEST_DIR)/linux-stress.tar.gz \
	$(DEST_DIR)/big_buck_bunny_480p_stereo.ogg \
	$(DEST_DIR)/audiosample.wav \
	$(DEST_DIR)/stress-small.tar.gz

$(DEST_DIR):
	mkdir -p $(DEST_DIR)

# ==============================================================================

$(DEST_DIR)/big_buck_bunny_480p_stereo.ogg:
	mkdir -p $(DEST_DIR)
	wget -O $@ \
		http://mirrorblender.top-ix.org/peach/bigbuckbunny_movies/big_buck_bunny_480p_stereo.ogg
#		http://mirror.bigbuckbunny.de/peach/bigbuckbunny_movies/big_buck_bunny_480p_stereo.ogg

# ==============================================================================

LINUX_PKG=linux-2.6.32

$(DEST_DIR)/linux-stress.tar.gz: $(LINUX_PKG).tar.bz2
	rm -rf linux-stress
	tar -xf $(LINUX_PKG).tar.bz2
	mv $(LINUX_PKG) linux-stress
	cd linux-stress && true | make config
	tar -czf $@ linux-stress

$(LINUX_PKG).tar.bz2:
	wget -O $@ \
		http://www.kernel.org/pub/linux/kernel/v2.6/$(LINUX_PKG).tar.bz2

# ==============================================================================

$(DEST_DIR)/audiosample.wav:
	wget -O - http://www.gnu.org/music/free-software-song.ogg | oggdec -o $@ -

# ==============================================================================

SED_PKG=sed-4.2

$(DEST_DIR)/stress-small.tar.gz: $(SED_PKG).tar.bz2
	tar -xf $(SED_PKG).tar.bz2
	mv $(SED_PKG) stress-small
	cd stress-small && ./configure --disable-nls --disable-i18n --disable-acl
	tar -czf $@ stress-small 

$(SED_PKG).tar.bz2:
	wget -O $@ http://ftp.gnu.org/gnu/sed/$(SED_PKG).tar.gz
