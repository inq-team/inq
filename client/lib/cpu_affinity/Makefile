include ../../../Makefile.config

all: cpu_affinity

cpu_affinity: cpu_affinity.o
	$(CC) cpu_affinity.o -o cpu_affinity

clean:
	rm -f cpu_affinity.o cpu_affinity

install:
	mkdir -p $(DESTDIR)$(BIN_DIR)
	install -m755 cpu_affinity $(DESTDIR)$(BIN_DIR)/
