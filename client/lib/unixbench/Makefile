include ../../../Makefile.config

##############################################################################
#	UnixBench v5.1.1
#  Based on The BYTE UNIX Benchmarks - Release 3
#          Module: Makefile   SID: 3.9 5/15/91 19:30:15
#
##############################################################################
SHELL = /bin/sh
CC=gcc
OPTON = -s -O2 -fomit-frame-pointer -fforce-addr -ffast-math -Wall
CFLAGS = -DTIME -Wall -pedantic -ansi

# local directories
PROGDIR = ./pgms
SRCDIR = ./src
# other directories
INCLDIR = /usr/include
LIBDIR = /lib
SOURCES = arith.c big.c context1.c \
	dummy.c execl.c \
	fstime.c hanoi.c \
	pipe.c spawn.c \
	syscall.c looper.c timeit.c time-polling.c \
	dhry_1.c dhry_2.c dhry.h whets.c

# Program binaries.
BINS = $(PROGDIR)/arithoh $(PROGDIR)/register $(PROGDIR)/short \
	$(PROGDIR)/int $(PROGDIR)/long $(PROGDIR)/float $(PROGDIR)/double \
	$(PROGDIR)/hanoi $(PROGDIR)/syscall $(PROGDIR)/context1 \
	$(PROGDIR)/pipe $(PROGDIR)/spawn $(PROGDIR)/execl \
	$(PROGDIR)/dhry2 $(PROGDIR)/dhry2reg  $(PROGDIR)/looper \
	$(PROGDIR)/fstime $(PROGDIR)/whetstone-double
## These compile only on some platforms...
# $(PROGDIR)/poll $(PROGDIR)/poll2 $(PROGDIR)/select

# Required non-binary files.
REQD = sort.src dc.dat $(PROGDIR)/multi.sh \
	$(PROGDIR)/tst.sh $(PROGDIR)/index.base

# ######################### the big ALL ############################
all: programs $(REQD)

programs: $(BINS)

# Individual programs
$(PROGDIR)/arithoh:	$(SRCDIR)/arith.c
	$(CC) -o $(PROGDIR)/arithoh ${CFLAGS} ${OPTON} -Darithoh $(SRCDIR)/arith.c
$(PROGDIR)/register: $(SRCDIR)/arith.c
	$(CC) -o $(PROGDIR)/register ${CFLAGS} ${OPTON} -Ddatum='register int' $(SRCDIR)/arith.c
$(PROGDIR)/short: $(SRCDIR)/arith.c
	$(CC) -o $(PROGDIR)/short ${CFLAGS} ${OPTON} -Ddatum=short $(SRCDIR)/arith.c
$(PROGDIR)/int: $(SRCDIR)/arith.c
	$(CC) -o $(PROGDIR)/int ${CFLAGS} ${OPTON} -Ddatum=int $(SRCDIR)/arith.c
$(PROGDIR)/long: $(SRCDIR)/arith.c
	$(CC) -o $(PROGDIR)/long ${CFLAGS} ${OPTON} -Ddatum=long $(SRCDIR)/arith.c
$(PROGDIR)/float: $(SRCDIR)/arith.c
	$(CC) -o $(PROGDIR)/float ${CFLAGS} ${OPTON} -Ddatum=float $(SRCDIR)/arith.c
$(PROGDIR)/double: $(SRCDIR)/arith.c
	$(CC) -o $(PROGDIR)/double ${CFLAGS} ${OPTON} -Ddatum=double $(SRCDIR)/arith.c
$(PROGDIR)/whetstone-double: $(SRCDIR)/whets.c
	$(CC) -o $(PROGDIR)/whetstone-double ${CFLAGS} ${OPTON} -DDP -DUNIX -DUNIXBENCH $(SRCDIR)/whets.c -lm
$(PROGDIR)/hanoi: $(SRCDIR)/hanoi.c
	$(CC) -o $(PROGDIR)/hanoi ${CFLAGS} ${OPTON} $(SRCDIR)/hanoi.c

$(PROGDIR)/poll: $(SRCDIR)/time-polling.c
	$(CC) -DHAS_POLL -DUNIXBENCH -o $(PROGDIR)/poll ${CFLAGS} ${OPTON} $(SRCDIR)/time-polling.c

$(PROGDIR)/poll2: $(SRCDIR)/time-polling.c
	$(CC) -DHAS_POLL2 -DUNIXBENCH -o $(PROGDIR)/poll2 ${CFLAGS} ${OPTON} $(SRCDIR)/time-polling.c

$(PROGDIR)/select: $(SRCDIR)/time-polling.c
	$(CC) -DHAS_SELECT -DUNIXBENCH -o $(PROGDIR)/select ${CFLAGS} ${OPTON} $(SRCDIR)/time-polling.c

$(PROGDIR)/fstime: $(SRCDIR)/fstime.c
	$(CC) -o $(PROGDIR)/fstime ${CFLAGS} ${OPTON} $(SRCDIR)/fstime.c

$(PROGDIR)/syscall: $(SRCDIR)/syscall.c
	$(CC) -o $(PROGDIR)/syscall ${CFLAGS} ${OPTON} $(SRCDIR)/syscall.c
$(PROGDIR)/context1: $(SRCDIR)/context1.c
	$(CC) -o $(PROGDIR)/context1 ${CFLAGS} ${OPTON} $(SRCDIR)/context1.c
$(PROGDIR)/pipe: $(SRCDIR)/pipe.c
	$(CC) -o $(PROGDIR)/pipe ${CFLAGS} ${OPTON} $(SRCDIR)/pipe.c
$(PROGDIR)/spawn: $(SRCDIR)/spawn.c
	$(CC) -o $(PROGDIR)/spawn ${CFLAGS} ${OPTON} $(SRCDIR)/spawn.c
$(PROGDIR)/execl: $(SRCDIR)/execl.c $(SRCDIR)/big.c
	$(CC) -o $(PROGDIR)/execl ${CFLAGS} ${OPTON} $(SRCDIR)/execl.c

$(PROGDIR)/dhry2: $(SRCDIR)/dhry_1.c $(SRCDIR)/dhry_2.c $(SRCDIR)/dhry.h
	cd $(SRCDIR); $(CC) -c ${CFLAGS} -DHZ=${HZ} ${OPTON} dhry_1.c
	cd $(SRCDIR); $(CC) -c ${CFLAGS} -DHZ=${HZ} ${OPTON} dhry_2.c
	$(CC) -o $(PROGDIR)/dhry2 ${CFLAGS} ${OPTON} $(SRCDIR)/dhry_1.o $(SRCDIR)/dhry_2.o
	cd $(SRCDIR); rm -f dhry_1.o dhry_2.o
$(PROGDIR)/dhry2reg: $(SRCDIR)/dhry_1.c $(SRCDIR)/dhry_2.c $(SRCDIR)/dhry.h
	cd $(SRCDIR); $(CC) -c ${CFLAGS} -DREG=register -DHZ=${HZ} ${OPTON} dhry_1.c
	cd $(SRCDIR); $(CC) -c ${CFLAGS} -DREG=register -DHZ=${HZ} ${OPTON} dhry_2.c
	$(CC) -o $(PROGDIR)/dhry2reg ${CFLAGS} ${OPTON} $(SRCDIR)/dhry_1.o $(SRCDIR)/dhry_2.o
	cd $(SRCDIR); rm -f dhry_1.o dhry_2.o

$(PROGDIR)/looper: $(SRCDIR)/looper.c
	$(CC) -o $(PROGDIR)/looper ${CFLAGS} ${OPTON} $(SRCDIR)/looper.c

clean:
	rm -f $(BINS) core *~ */*~

install:
	mkdir -p $(DESTDIR)$(BIN_DIR) $(DESTDIR)$(LIB_DIR)/unixbench
	cp pgms/* $(DESTDIR)$(LIB_DIR)/unixbench/
	cp dc.dat $(DESTDIR)$(LIB_DIR)/unixbench/
	cp sort.src $(DESTDIR)$(LIB_DIR)/unixbench/
	install -m755 Run $(DESTDIR)$(BIN_DIR)/unixbench
