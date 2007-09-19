include ../../../Makefile.config

all: watchdog

watchdog: watchdog.o
	$(CC) watchdog.o -o watchdog

clean:
	rm -f watchdog.o watchdog

install:
	mkdir -p $(DESTDIR)$(BIN_DIR)
	install -m755 watchdog $(DESTDIR)$(BIN_DIR)/
