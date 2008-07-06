include ../../Makefile.config
include ../../flavour/$(FLAVOUR)

BIN_FILES=\
	inquisitor \
	inq-detect \
	get-macs \
	inq-wrapper \
	inq-live
SHARE_NOEXEC_FILES=\
	functions \
	functions-test \
	functions-test-tui \
	functions-monitoring \
	outformat \
	lshw.xslt
ETC_FILES=\
	global \
	overlaytab \
	remounttab
SHARE_EXEC_FILES=\
	add-component \
	vendor \
	inq-sensors-detect \
	decode-dimms.pl \
	hal-searcher

all:
	sed -e 's,@@ETC_DIR@@,$(ETC_DIR),g; s,@@BIN_DIR@@,$(BIN_DIR),g; s,@@LIB_DIR@@,$(LIB_DIR),g; s,@@SHARE_DIR@@,$(SHARE_DIR),g; s,@@INQ_VERSION@@,$(INQ_VERSION),g; s,@@DEBUG_TTY@@,$(DEBUG_TTY),g;' <global.in >global

install:
	mkdir -p $(DESTDIR)$(BIN_DIR) $(DESTDIR)$(ETC_DIR) $(DESTDIR)$(SHARE_DIR)
	install -m755 $(BIN_FILES) $(DESTDIR)$(BIN_DIR)
	install -m755 $(SHARE_EXEC_FILES) $(DESTDIR)$(SHARE_DIR)
	install -m644 $(SHARE_NOEXEC_FILES) $(DESTDIR)$(SHARE_DIR)
	if [ -n "$(INIT)" ]; then install -m644 init $(DESTDIR)$(SHARE_DIR); fi
	install -m644 $(ETC_FILES) $(DESTDIR)$(ETC_DIR)

clean:
	rm -f global
