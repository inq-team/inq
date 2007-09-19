include ../Makefile.config
include ../flavour/$(FLAVOUR)

all:
	$(MAKE) -C lib all
	$(MAKE) -C main all

install:
	$(MAKE) -C lib install
	$(MAKE) -C main install
#	mkdir -p $(DESTDIR)$(BIN_DIR)
#	install -m755 inquisitor/inquisitor $(DESTDIR)$(BIN_DIR)/
#	install -m755 decode-dimm/decode-dimm.rb $(DESTDIR)$(BIN_DIR)/
#	install -m755 planner/planner.rb $(DESTDIR)$(BIN_DIR)/
#	install -m755 interface/interface.rb $(DESTDIR)$(BIN_DIR)/
#	mkdir -p $(DESTDIR)$(LIB_DIR)/jtkey
#	install -m644 interface/TERM.linux $(DESTDIR)$(LIB_DIR)/jtkey/
#	mkdir -p $(DESTDIR)$(SYSCONFDIR)/inquisitor $(DESTDIR)$(SYSCONFDIR)/X11
#	rsync -r '--exclude=*CVS' '--exclude=*X11*' etc/* $(DESTDIR)$(SYSCONFDIR)/inquisitor/
#	rsync -r '--exclude=*CVS' etc/X11/* $(DESTDIR)$(SYSCONFDIR)/X11/
#	mkdir -p $(DESTDIR)$(LIB_DIR)/inquisitor/info.d
#	find info.d/ -type f | grep -v CVS | xargs install -m644 -t $(DESTDIR)$(LIB_DIR)/inquisitor/info.d/
#	mkdir -p $(DESTDIR)$(LIB_DIR)/inquisitor/test.d
#	install -m755 summarize/summarize $(DESTDIR)$(LIB_DIR)/inquisitor
#	find test.d/ -type f | grep -v CVS | xargs install -m644 -t $(DESTDIR)$(LIB_DIR)/inquisitor/test.d/
#	find lib/ -type f | grep -v CVS | xargs install -t $(DESTDIR)$(LIB_DIR)/inquisitor/
#	rsync -r '--exclude=*CVS' ../image/* $(DESTDIR)$(LIB_DIR)/inquisitor/
	mkdir -p \
		$(DESTDIR)$(SHARE_DIR)/detect \
		$(DESTDIR)$(SHARE_DIR)/test \
		$(DESTDIR)$(SHARE_DIR)/monitoring
	find detect -type f | xargs install -m644 -t $(DESTDIR)$(SHARE_DIR)/detect/
	find test -type f | xargs install -m644 -t $(DESTDIR)$(SHARE_DIR)/test/
	find monitoring -type f | xargs install -m644 -t $(DESTDIR)$(SHARE_DIR)/monitoring/
	install -m644 communication/$(COMMUNICATION) $(DESTDIR)$(SHARE_DIR)/communication
	install -m644 self-id/$(SELF_ID) $(DESTDIR)$(SHARE_DIR)/self-id

clean:
	$(MAKE) -C lib clean
	$(MAKE) -C main clean
