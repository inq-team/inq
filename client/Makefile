# client/Makefile - A part of Inquisitor project
# Copyright (C) 2004-2008 by Iquisitor team 
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

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
		$(DESTDIR)$(SHARE_DIR)/test \
		$(DESTDIR)$(SHARE_DIR)/monitoring \
		$(DESTDIR)$(SHARE_DIR)/self-id \
		$(DESTDIR)$(SHARE_DIR)/firmwares
	find detect -type f -and ! -path '*.svn*' | xargs install -m644 -t $(DESTDIR)$(SHARE_DIR)/detect/
	find test -type f -and ! -path '*.svn*' | xargs install -m755 -t $(DESTDIR)$(SHARE_DIR)/test/
	find monitoring -type f -and ! -path '*.svn*' | xargs install -m644 -t $(DESTDIR)$(SHARE_DIR)/monitoring/
	install -m644 communication/$(COMMUNICATION) $(DESTDIR)$(SHARE_DIR)/communication
	oldIFS=$$IFS; IFS=:; N=0; set -- $(SELF_ID); for I in $$@; do install -m644 self-id/$$I $(DESTDIR)$(SHARE_DIR)/self-id/$$N$$I; N=$$(($$N+1)); done; IFS=$$oldIFS

clean:
	$(MAKE) -C lib clean
	$(MAKE) -C main clean
