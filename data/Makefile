.EXPORT_ALL_VARIABLES:

include ../Makefile.config
include ../flavour/$(FLAVOUR)

DEST_DIR=out

all: \
	$(DEST_DIR)/linux-stress.tar.gz \
	$(DEST_DIR)/big_buck_bunny_480p_stereo.ogg

# ==============================================================================

$(DEST_DIR)/big_buck_bunny_480p_stereo.ogg:
	mkdir -p $(DEST_DIR)
	wget -O $@ \
		http://mirrorblender.top-ix.org/peach/bigbuckbunny_movies/big_buck_bunny_480p_stereo.ogg
#		http://mirror.bigbuckbunny.de/peach/bigbuckbunny_movies/big_buck_bunny_480p_stereo.ogg

# ==============================================================================

LINUX_PKG=linux-2.6.32

$(DEST_DIR)/linux-stress.tar.gz: $(LINUX_PKG).tar.bz2
	tar -xf $(LINUX_PKG).tar.bz2
	cd $(LINUX_PKG) && true | make config
	tar -czf $@ $(LINUX_PKG)

$(LINUX_PKG).tar.bz2:
	wget -O $@ \
		http://www.kernel.org/pub/linux/kernel/v2.6/$(LINUX_PKG).tar.bz2
