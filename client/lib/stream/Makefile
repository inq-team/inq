include ../../../Makefile.config

all: stream

stream: stream.o
	$(CC) -O2 stream.o -o stream

clean:
	rm -f stream.o stream

install:
	mkdir -p $(DESTDIR)$(BIN_DIR)
	install -m755 stream $(DESTDIR)$(BIN_DIR)/
