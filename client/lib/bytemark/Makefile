include ../../../Makefile.config

default: nbench
CC = gcc
CFLAGS = -s -static -Wall -O2 -fomit-frame-pointer -funroll-loops
MACHINE=
DEFINES= -DLINUX $(NO_UNAME)

all: nbench

sysinfoc.c: Makefile
	./sysinfo.sh $(CC) $(MACHINE) $(DEFINES) $(CFLAGS)

sysinfo.c: Makefile
	./sysinfo.sh $(CC) $(MACHINE) $(DEFINES) $(CFLAGS)

hardware.o: hardware.c hardware.h Makefile
	$(CC) $(MACHINE) $(DEFINES) $(CFLAGS)\
		-c hardware.c

nbench0.o: nbench0.h nbench0.c nmglobal.h pointer.h hardware.h\
	   Makefile sysinfo.c sysinfoc.c
	$(CC) $(MACHINE) $(DEFINES) $(CFLAGS)\
		-c nbench0.c

emfloat.o: emfloat.h emfloat.c nmglobal.h pointer.h Makefile
	$(CC) $(MACHINE) $(DEFINES) $(CFLAGS)\
		-c emfloat.c

pointer.h: pointer Makefile
	$(CC) $(MACHINE) $(DEFINES) $(CFLAGS)\
		-o pointer pointer.c
	rm -f pointer.h
	if [ "4" = `./pointer` ] ; then touch pointer.h ;\
	else echo "#define LONG64" >pointer.h ; fi

misc.o: misc.h misc.c Makefile
	$(CC) $(MACHINE) $(DEFINES) $(CFLAGS)\
		-c misc.c

nbench1.o: nbench1.h nbench1.c wordcat.h nmglobal.h pointer.h Makefile
	$(CC) $(MACHINE) $(DEFINES) $(CFLAGS)\
		-c nbench1.c

sysspec.o: sysspec.h sysspec.c nmglobal.h pointer.h Makefile
	$(CC) $(MACHINE) $(DEFINES) $(CFLAGS)\
		-c sysspec.c

nbench: emfloat.o misc.o nbench0.o nbench1.o sysspec.o hardware.o
	$(CC) $(MACHINE) $(DEFINES) $(CFLAGS) $(LINKFLAGS)\
		emfloat.o misc.o nbench0.o nbench1.o sysspec.o hardware.o\
		-o nbench -lm
clean:
	- /bin/rm -f *.o *~ \#* core a.out hello sysinfo.c sysinfoc.c \
		 bug pointer pointer.h debugbit.dat

mrproper: clean
	- /bin/rm -f nbench

install:
	mkdir -p $(DESTDIR)$(BIN_DIR) $(DESTDIR)$(SHARE_DIR)/test/additional
	install -m755 nbench $(DESTDIR)$(BIN_DIR)/
	cp NNET.DAT $(DESTDIR)$(SHARE_DIR)/test/additional/
	cp COM.DAT $(DESTDIR)$(SHARE_DIR)/test/additional/
