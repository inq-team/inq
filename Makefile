include Makefile.config
.SILENT: default

#===============================================================================
# Major targets
#===============================================================================

default:
	echo 'Use "make all" if you really want to rebuild everything from scratch'

client:
	$(MAKE) -C client

server:
	$(MAKE) -C server

ifeq ($(FLAVOUR), enterprise)
all: build-package build-root rsync build-server rsync-server
else
ifeq ($(FLAVOUR), live)
all: build-package build-root build-boot build-live
else
ifeq ($(FLAVOUR), standalone)
all: build-package
else
ifeq ($(FLAVOUR), inventory)
all: build-package
else
all:
	echo 'Edit Makefile.config to set up FLAVOUR to one of the valid values'
endif
endif
endif
endif

#===============================================================================
# Misc targets
#===============================================================================

clean: repo-clean
	rm -Rf $(WORKDIR)
	CONFIG=$(CONFIG) $(MAKE) -C client clean

# Files with metadata, gathered from client modules
metadata:
	cd server/web/lib/planner && ./configure
	cd ../web && ./generate-from-metadata

# Generate API documentation for the website
doc:
	cd ../web && ./generate-api-doc

#===============================================================================
# Client image deployment
#===============================================================================

rsync:
	ssh $(DEPLOY_HOST) "mkdir -p $(DEPLOY_PATH); sudo chown root:inquisitor $(DEPLOY_PATH)"
	sudo rsync -rlptv --delete-after --exclude=usr/lib/inquisitor/images --exclude=etc/inquisitor/users $(WORKDIR)/$(ROOTDIR)/* root@$(DEPLOY_HOST):$(DEPLOY_PATH)
	ssh $(DEPLOY_HOST) "sudo rm -f $(DEPLOY_PATH)/dev/console $(DEPLOY_PATH)/dev/null; sudo mknod $(DEPLOY_PATH)/dev/console c 5 1; sudo mknod $(DEPLOY_PATH)/dev/null c 1 3"

rsync-list:
	rsync -rlptvn --delete-after --exclude=usr/lib/inquisitor/images --exclude=etc/inquisitor/users $(WORKDIR)/$(ROOTDIR)/* $(DEPLOY_HOST):$(DEPLOY_PATH)

#rsync-images:
#	ssh $(DEPLOY_HOST) mkdir -p $(DEPLOY_PATH)/usr/lib/inquisitor/images
#	rsync -rlptv --delete image-huge/images/* $(DEPLOY_HOST):$(DEPLOY_PATH)/usr/lib/inquisitor/images

#rsync-repository:
#	ssh $(DEPLOY_HOST) "mkdir -p $(DEPLOY_PATH)$(COMPACT_PATH); sudo chown -R greycat.inquisitor $(DEPLOY_PATH)$(COMPACT_PATH)"
#	rsync -vrpl --exclude=files/SRPMS /raid/Sisyphus-branch-3.0 $(DEPLOY_HOST):$(DEPLOY_PATH)$(COMPACT_PATH)

#===============================================================================
# Server deployment
#===============================================================================

rsync-server:
	rsync -rlptv --delete server $(DEPLOY_HOST):
	rsync -rlptv --delete configs $(DEPLOY_HOST):
	ssh $(DEPLOY_HOST) "cd server; CONFIG=$(CONFIG) sudo make install"

#===============================================================================

# Some sanity checks
ifndef CLIENT_BASE
$(error CLIENT_BASE not defined. Please edit Makefile.config to specify your build system Linux distribution in CLIENT_BASE.)
endif

# Include client platform-dependent build instructions
include build/$(CLIENT_BASE)/Makefile
