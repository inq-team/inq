# client/main/Makefile - A part of Inquisitor project
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

include ../../Makefile.config
include ../../flavour/$(FLAVOUR)

all:
	sed -e 's,@@ETC_DIR@@,$(ETC_DIR),g; s,@@BIN_DIR@@,$(BIN_DIR),g; s,@@LIB_DIR@@,$(LIB_DIR),g; s,@@SHARE_DIR@@,$(SHARE_DIR),g; s,@@INQ_VERSION@@,$(INQ_VERSION),g; s,@@DEBUG_TTY@@,$(DEBUG_TTY),g;' <global.in >global

install:
	mkdir -p $(DESTDIR)$(BIN_DIR) $(DESTDIR)$(ETC_DIR) $(DESTDIR)$(SHARE_DIR)
	install -m755 inquisitor $(DESTDIR)$(BIN_DIR)
	install -m644 functions functions-test functions-monitoring outformat lshw.xslt $(DESTDIR)$(SHARE_DIR)
	if [ -n "$(INIT)" ]; then install -m644 init $(DESTDIR)$(SHARE_DIR); fi
	install -m644 global overlaytab remounttab $(DESTDIR)$(ETC_DIR)
	install -m755 add-component $(DESTDIR)$(SHARE_DIR)
	install -m755 vendor $(DESTDIR)$(SHARE_DIR)
	install -m755 inq-detect inq-planner get-macs inq-wrapper inq-live $(DESTDIR)$(BIN_DIR)
	install -m755 inq-sensors-detect $(DESTDIR)$(SHARE_DIR)
	install -m755 decode-dimms.pl $(DESTDIR)$(SHARE_DIR)
	install -m755 hal-searcher $(DESTDIR)$(SHARE_DIR)

clean:
	rm -f global
