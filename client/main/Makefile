include ../../Makefile.config
include ../../flavour/$(FLAVOUR)

all:
	sed -e 's,@@ETC_DIR@@,$(ETC_DIR),g; s,@@BIN_DIR@@,$(BIN_DIR),g; s,@@LIB_DIR@@,$(LIB_DIR),g; s,@@SHARE_DIR@@,$(SHARE_DIR),g; s,@@INQ_VERSION@@,$(INQ_VERSION),g;' <global.in >global

install:
	mkdir -p $(DESTDIR)$(BIN_DIR) $(DESTDIR)$(ETC_DIR) $(DESTDIR)$(SHARE_DIR)
	install -m755 inquisitor $(DESTDIR)$(BIN_DIR)
	install -m644 functions functions-test functions-benchmark outformat lshw.xslt $(DESTDIR)$(SHARE_DIR)
	if [ -n "$(INIT)" ]; then install -m644 init $(DESTDIR)$(SHARE_DIR); fi
	install -m644 global overlaytab remounttab $(DESTDIR)$(ETC_DIR)
	install -m755 add-component $(DESTDIR)$(SHARE_DIR)
	install -m755 inq-detect $(DESTDIR)$(BIN_DIR)
	install -m755 inq-planner $(DESTDIR)$(BIN_DIR)
	install -m755 get-macs $(DESTDIR)$(BIN_DIR)
	install -m755 inq-sensors-detect $(DESTDIR)$(SHARE_DIR)

clean:
	rm -f global
