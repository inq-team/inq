.EXPORT_ALL_VARIABLES:

include ../Makefile.config
include ../flavour/$(FLAVOUR)

all:
	$(MAKE) -C lib all
	$(MAKE) -C main all

install:
	$(MAKE) -C lib install
	$(MAKE) -C main install
#	install -m755 decode-dimm/decode-dimm.rb $(DESTDIR)$(BIN_DIR)/
#	install -m755 planner/planner.rb $(DESTDIR)$(BIN_DIR)/
#	install -m755 interface/interface.rb $(DESTDIR)$(BIN_DIR)/
#	mkdir -p $(DESTDIR)$(LIB_DIR)/jtkey
#	install -m644 interface/TERM.linux $(DESTDIR)$(LIB_DIR)/jtkey/
#	mkdir -p $(DESTDIR)$(SYSCONFDIR)/inquisitor $(DESTDIR)$(SYSCONFDIR)/X11
#	rsync -r '--exclude=*CVS' '--exclude=*X11*' etc/* $(DESTDIR)$(SYSCONFDIR)/inquisitor/
#	rsync -r '--exclude=*CVS' etc/X11/* $(DESTDIR)$(SYSCONFDIR)/X11/
#	install -m755 summarize/summarize $(DESTDIR)$(LIB_DIR)/inquisitor
#	find lib/ -type f | grep -v CVS | xargs install -t $(DESTDIR)$(LIB_DIR)/inquisitor/
#	rsync -r '--exclude=*CVS' ../image/* $(DESTDIR)$(LIB_DIR)/inquisitor/
	mkdir -p \
		$(DESTDIR)$(SHARE_DIR)/detect \
		$(DESTDIR)$(SHARE_DIR)/software-detect \
		$(DESTDIR)$(SHARE_DIR)/test \
		$(DESTDIR)$(SHARE_DIR)/monitoring \
		$(DESTDIR)$(SHARE_DIR)/self-id \
		$(DESTDIR)$(SHARE_DIR)/firmwares
	find detect -type f -and ! -path '*.svn*' | xargs install -m755 -t $(DESTDIR)$(SHARE_DIR)/detect/
	find software-detect -type f -and ! -path '*.svn*' | xargs install -m755 -t $(DESTDIR)$(SHARE_DIR)/software-detect/
	find test -type f -and ! -path '*.svn*' -and ! -path '*legacy*' | xargs install -m755 -t $(DESTDIR)$(SHARE_DIR)/test/
	find monitoring -type f -and ! -path '*.svn*' | xargs install -m755 -t $(DESTDIR)$(SHARE_DIR)/monitoring/
	install -m644 communication/$(COMMUNICATION) $(DESTDIR)$(SHARE_DIR)/communication
	oldIFS=$$IFS; IFS=:; N=0; set -- $(SELF_ID); for I in $$@; do install -m644 self-id/$$I $(DESTDIR)$(SHARE_DIR)/self-id/$$N$$I; N=$$(($$N+1)); done; IFS=$$oldIFS

clean:
	$(MAKE) -C lib clean
	$(MAKE) -C main clean
