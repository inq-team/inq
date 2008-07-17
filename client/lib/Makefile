.EXPORT_ALL_VARIABLES:

SUBDIRS=watchdog wait-string einarc stream-mem whetstone dhrystone bytemark unixbench hdd-badblocks bindings memtester thermo

include ../../Makefile.config

all:
	cd einarc && ./configure --modules=$(EINARC_MODULES) && cd ..
	for I in $(SUBDIRS); do $(MAKE) -C $$I all; done

install:
	for I in $(SUBDIRS); do $(MAKE) -C $$I install; done

clean:
	for I in $(SUBDIRS); do $(MAKE) -C $$I clean; done
