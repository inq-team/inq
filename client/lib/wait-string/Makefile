include ../../../Makefile.config
include ../../../flavour/$(FLAVOUR)

all: wait-string

install:
	mkdir -p $(DESTDIR)$(BIN_DIR)
	install -m755 wait-string $(DESTDIR)$(BIN_DIR)/

clean:
	rm -f wait-string

wait-string:
	sed 's/@@WAIT_STRING_PORT@@/$(WAIT_STRING_PORT)/g;' <wait-string.in >wait-string
	chmod a+x wait-string
