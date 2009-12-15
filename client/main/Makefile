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
	inq-monitoring \
	inq-self-id \
	inq-software-detect \
	get-macs \
	inq-wrapper \
	inq-live-wrapper \
	inq-live
SHARE_NOEXEC_FILES=\
	issue \
	motd \
	functions \
	functions-test \
	functions-test-tui \
	functions-monitoring \
	outformat \
	lshw.xslt \
	get_component_version.xslt \
	add_component.xslt \
	add_software_component.xslt \
	inq-live-watchdog.scr \
	profile2assurance.xslt \
	profile2menu_item.xslt \
	profile2test_script.xslt
ETC_FILES=\
	global \
	overlaytab \
	remounttab
SHARE_EXEC_FILES=\
	vendor \
	inq-sensors-detect \
	decode-dimms.pl \
	hal-searcher \
	mencoder_call
INIT_FILES=init

all: motd.inq issue.inq
	sed -e "s,@@ETC_DIR@@,$(ETC_DIR),g; \
		s,@@BIN_DIR@@,$(BIN_DIR),g; \
		s,@@LIB_DIR@@,$(LIB_DIR),g; \
		s,@@SHARE_DIR@@,$(SHARE_DIR),g; \
		s,@@INQ_VERSION@@,$(INQ_VERSION),g; \
		s,@@DEFAULT_FILESYSTEM@@,$(DEFAULT_FILESYSTEM),g; \
		s,@@DEFAULT_FILESYSTEM_FORCE@@,$(DEFAULT_FILESYSTEM_FORCE),g; \
		s,@@DEBUG_TTY@@,$(DEBUG_TTY),g;" <global.in >global

motd.inq:
	./build-motd

issue.inq:
	./build-issue

install:
	mkdir -p $(DESTDIR)$(BIN_DIR) $(DESTDIR)$(ETC_DIR) $(DESTDIR)$(SHARE_DIR)
	install -m755 $(BIN_FILES) $(DESTDIR)$(BIN_DIR)
	install -m755 $(SHARE_EXEC_FILES) $(DESTDIR)$(SHARE_DIR)
	install -m644 $(SHARE_NOEXEC_FILES) $(DESTDIR)$(SHARE_DIR)
	if test -n "$(INIT_FILES)" ; then install -m644 $(INIT_FILES) $(DESTDIR)$(SHARE_DIR); fi
	install -m644 $(ETC_FILES) $(DESTDIR)$(ETC_DIR)
	ln -s $(ETC_DIR)/global $(DESTDIR)$(BIN_DIR)/_inq-config-global

clean:
	rm -f global
