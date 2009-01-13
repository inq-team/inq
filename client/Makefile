.EXPORT_ALL_VARIABLES:

include ../Makefile.config
include ../flavour/$(FLAVOUR)

all:
	$(MAKE) -C lib all
	$(MAKE) -C main all

install:
	$(MAKE) -C lib install
	$(MAKE) -C main install
	mkdir -p \
		$(DESTDIR)$(SHARE_DIR)/detect \
		$(DESTDIR)$(SHARE_DIR)/software-detect \
		$(DESTDIR)$(SHARE_DIR)/test \
		$(DESTDIR)$(SHARE_DIR)/profile/live \
		$(DESTDIR)$(SHARE_DIR)/monitoring \
		$(DESTDIR)$(SHARE_DIR)/self-id \
		$(DESTDIR)$(SHARE_DIR)/firmwares
	find detect -type f -and ! -path '*.svn*' | xargs install -m755 -t $(DESTDIR)$(SHARE_DIR)/detect/
	find software-detect -type f -and ! -path '*.svn*' | xargs install -m755 -t $(DESTDIR)$(SHARE_DIR)/software-detect/
	find test -type f -and ! -path '*.svn*' -and ! -path '*legacy*' -and ! -path '*profile*' | xargs install -m755 -t $(DESTDIR)$(SHARE_DIR)/test/
	find profile -maxdepth 1 -type f -and ! -path '*.svn*' | xargs install -m644 -t $(DESTDIR)$(SHARE_DIR)/profile/
	find profile/live -maxdepth 1 -type f -and ! -path '*.svn*' | xargs install -m644 -t $(DESTDIR)$(SHARE_DIR)/profile/live/
	find monitoring -type f -and ! -path '*.svn*' | xargs install -m755 -t $(DESTDIR)$(SHARE_DIR)/monitoring/
	install -m644 communication/$(COMMUNICATION) $(DESTDIR)$(SHARE_DIR)/communication
	oldIFS=$$IFS; IFS=:; N=0; set -- $(SELF_ID); for I in $$@; do install -m644 self-id/$$I $(DESTDIR)$(SHARE_DIR)/self-id/$$N$$I; N=$$(($$N+1)); done; IFS=$$oldIFS

clean:
	$(MAKE) -C lib clean
	$(MAKE) -C main clean
