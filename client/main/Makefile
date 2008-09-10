include ../../Makefile.config
include ../../flavour/$(FLAVOUR)


ifeq ($(FLAVOUR), inventory)
BIN_FILES_FLAVOUR=\
	inq-inventory \
	inq-inventory-stop
else
BIN_FILES_FLAVOUR=\
	inquisitor
endif
BIN_FILES=\
	$(BIN_FILES_FLAVOUR) \
	inq-detect \
	inq-software-detect \
	get-macs \
	inq-wrapper \
	inq-live
SHARE_NOEXEC_FILES=\
	functions \
	functions-test \
	functions-test-tui \
	functions-monitoring \
	outformat \
	lshw.xslt \
	get_component_version.xslt
ETC_FILES=\
	global \
	overlaytab \
	remounttab
SHARE_EXEC_FILES=\
	add-component \
	vendor \
	inq-sensors-detect \
	decode-dimms.pl \
	hal-searcher \
	mencoder_call

ETC_DIR_REPLACING_FILES=$(BIN_FILES) $(SHARE_NOEXEC_FILES) $(SHARE_EXEC_FILES)

all:
	sed -e "s,@@ETC_DIR@@,$(ETC_DIR),g; \
		s,@@BIN_DIR@@,$(BIN_DIR),g; \
		s,@@LIB_DIR@@,$(LIB_DIR),g; \
		s,@@SHARE_DIR@@,$(SHARE_DIR),g; \
		s,@@INQ_VERSION@@,$(INQ_VERSION),g; \
		s,@@DEFAULT_FILESYSTEM@@,$(DEFAULT_FILESYSTEM),g; \
		s,@@DEFAULT_FILESYSTEM_FORCE@@,$(DEFAULT_FILESYSTEM_FORCE),g; \
		s,@@DEBUG_TTY@@,$(DEBUG_TTY),g;" <global.in >global
	for i in $(ETC_DIR_REPLACING_FILES); do sed -e "s,@@ETC_DIR@@,$(ETC_DIR),g" < $$i > $${i}_; mv $${i}_ $${i}; done

install:
	mkdir -p $(DESTDIR)$(BIN_DIR) $(DESTDIR)$(ETC_DIR) $(DESTDIR)$(SHARE_DIR)
	install -m755 $(BIN_FILES) $(DESTDIR)$(BIN_DIR)
	install -m755 $(SHARE_EXEC_FILES) $(DESTDIR)$(SHARE_DIR)
	install -m644 $(SHARE_NOEXEC_FILES) $(DESTDIR)$(SHARE_DIR)
	if [ -n "$(INIT)" ]; then install -m644 init $(DESTDIR)$(SHARE_DIR); fi
	install -m644 $(ETC_FILES) $(DESTDIR)$(ETC_DIR)

clean:
	rm -f global
