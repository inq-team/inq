include ../../../Makefile.config

all: memtester

memtester: 
	tar xzf memtester-4.0.8.tar.gz
	patch -d memtester-4.0.8 < memtester-4.0.8-inquisitor.patch
	$(MAKE) -C memtester-4.0.8

clean:
	rm -r memtester-4.0.8

install:
	mkdir -p $(DESTDIR)$(BIN_DIR)
	install -m755 memtester-4.0.8/memtester $(DESTDIR)$(BIN_DIR)/memtester
