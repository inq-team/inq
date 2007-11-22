.EXPORT_ALL_VARIABLES:

#SUBDIRS=alert hide-mouse memtest pci-patch wait-serial watchdog inquisitor thermometer
SUBDIRS=memtest watchdog wait-string einarc stream-mem whetstone dhrystone

include ../../Makefile.config

all:
	cd einarc && ./configure --module=$(EINARC_MODULES) && cd ..
	for I in $(SUBDIRS); do $(MAKE) -C $$I all; done

install:
	for I in $(SUBDIRS); do $(MAKE) -C $$I install; done

clean:
	for I in $(SUBDIRS); do $(MAKE) -C $$I clean; done
