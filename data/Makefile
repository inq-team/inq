.EXPORT_ALL_VARIABLES:

include ../Makefile.config
include ../flavour/$(FLAVOUR)

DEST_DIR=out

all: \
	$(DEST_DIR)/big_buck_bunny_480p_stereo.ogg
	$(DEST_DIR)/linux-stress.tar

$(DEST_DIR)/big_buck_bunny_480p_stereo.ogg:
	mkdir -p $(DEST_DIR)
	wget -O $@ \
		http://mirrorblender.top-ix.org/peach/bigbuckbunny_movies/big_buck_bunny_480p_stereo.ogg
#		http://mirror.bigbuckbunny.de/peach/bigbuckbunny_movies/big_buck_bunny_480p_stereo.ogg
