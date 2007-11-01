include ../../../Makefile.config

all: stream-mem

stream-mem: stream-mem.o
	$(CC) -O2 stream-mem.o -o stream-mem

clean:
	rm -f stream-mem.o stream-mem

install:
	mkdir -p $(DESTDIR)$(BIN_DIR)
	install -m755 stream-mem $(DESTDIR)$(BIN_DIR)/
