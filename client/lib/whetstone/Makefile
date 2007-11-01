include ../../../Makefile.config

all: whetstone

whetstone: whetstone.o
	$(CC) -O2 whetstone.o -o whetstone -lm

clean:
	rm -f whetstone.o whetstone

install:
	mkdir -p $(DESTDIR)$(BIN_DIR)
	install -m755 whetstone $(DESTDIR)$(BIN_DIR)/
