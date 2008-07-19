.EXPORT_ALL_VARIABLES:

SUBDIRS=wait-string einarc hdd-badblocks bindings thermo

include ../../Makefile.config

all:
	cd einarc && ./configure --modules=$(EINARC_MODULES) && cd ..
	for I in $(SUBDIRS); do $(MAKE) -C $$I all; done

install:
	for I in $(SUBDIRS); do $(MAKE) -C $$I install; done

clean:
	for I in $(SUBDIRS); do $(MAKE) -C $$I clean; done
