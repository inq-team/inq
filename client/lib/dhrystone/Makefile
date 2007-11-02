include ../../../Makefile.config

all: dhrystone

dhrystone: dhry_1.o dhry_2.o
	$(CC) -O2 -o dhrystone dhry_1.o dhry_2.o

dhry_1.o:
	$(CC) -O2 -DTIME -c dhry_1.c

dhry_2.o:
	$(CC) -O2 -DTIME -c dhry_2.c

clean:
	rm -f dhry_1.o dhry_2.o dhrystone

install:
	mkdir -p $(DESTDIR)$(BIN_DIR)
	install -m755 dhrystone $(DESTDIR)$(BIN_DIR)/
