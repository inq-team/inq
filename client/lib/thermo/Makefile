include ../../../Makefile.config

all: thermo-init

clean:
	rm -f thermo-init.o thermo-init

thermo-init: thermo-init.o
	$(CC) thermo-init.o -o thermo-init

install:
	mkdir -p $(DESTDIR)$(BIN_DIR)
	install -m755 thermo-init $(DESTDIR)$(BIN_DIR)/
	install -m755 thermo-acquire $(DESTDIR)$(BIN_DIR)/
