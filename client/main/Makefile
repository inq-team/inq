include ../../Makefile.config

all:
	sed -e 's,@@ETC_DIR@@,$(ETC_DIR),g; s,@@BIN_DIR@@,$(BIN_DIR),g; s,@@LIB_DIR@@,$(LIB_DIR),g; s,@@SHARE_DIR@@,$(SHARE_DIR),g;' <global.in >global

install:
	mkdir -p $(DESTDIR)$(BIN_DIR) $(DESTDIR)$(ETC_DIR) $(DESTDIR)$(SHARE_DIR)
	install -m755 inquisitor $(DESTDIR)$(BIN_DIR)
	install -m644 functions outformat $(DESTDIR)$(SHARE_DIR)
ifdef $(INIT)
	install -m644 init $(DESTDIR)$(SHARE_DIR)
endif
	install -m644 global $(DESTDIR)$(ETC_DIR)

clean:
	rm -f global
