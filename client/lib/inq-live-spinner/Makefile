include ../../../Makefile.config

all: inq-live-spinner

inq-live-spinner: inq-live-spinner.o
	$(CC) -O2 inq-live-spinner.o -o inq-live-spinner

clean:
	rm -f inq-live-spinner.o inq-live-spinner

install:
	mkdir -p $(DESTDIR)$(BIN_DIR)
	install -m755 inq-live-spinner $(DESTDIR)$(BIN_DIR)/
