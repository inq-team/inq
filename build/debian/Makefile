DEB_TARGET=$(TARGET)
ifeq ($(TARGET), i586)
DEB_TARGET=i386
endif
ifeq ($(TARGET), x86_64)
DEB_TARGET=amd64
endif

ifeq ($(FLAVOUR), enterprise)
build-root: build-root-enterprise
else
ifeq ($(FLAVOUR), live)
build-root: build-root-live
endif
endif

PACKAGE_NAME=inquisitor-client
PACKAGE_VERSION=1.0
PACKAGE_RELEASE=1
PACKAGE_DIR=$(PACKAGE_NAME)-$(PACKAGE_VERSION)-$(PACKAGE_RELEASE)
PACKAGE_DEB=$(PACKAGE_NAME)_$(PACKAGE_VERSION)-$(PACKAGE_RELEASE)_$(DEB_TARGET).deb

# Local build paths
WORKDIR=$(PWD)/work
ROOTDIR=chroot
LIVEDIR=live
DEBS=$(PWD)/repo

.PHONY: build-package

rebuild_deb=\
	rm -rf $(WORKDIR)/build-package; \
	mkdir -p $(WORKDIR)/build-package; \
	cp -r client $(WORKDIR)/build-package/$(PACKAGE_DIR); \
	cp -r flavour Makefile.config $(WORKDIR)/build-package; \
	cp -r build/debian/debian $(WORKDIR)/build-package/$(PACKAGE_DIR); \
	cp build/debian/init.$(FLAVOUR) $(WORKDIR)/build-package/$(PACKAGE_DIR)/main/init; \
	cd $(WORKDIR)/build-package/$(PACKAGE_DIR) && dpkg-buildpackage -b -a$(DEB_TARGET) -us -uc

build-package:
	$(rebuild_deb)

$(WORKDIR)/build-package/$(PACKAGE_DEB):
	$(rebuild_deb)

build-root-enterprise: $(WORKDIR)/build-package/$(PACKAGE_DEB)
	@if [ "$(REPO)" = ftp://your.mirror.here/debian ]; then echo 'REPO not defined. Please edit Makefile.config to specify your Debian-compatible repository in REPO.'; exit 1; fi
	# Cleanup from previous build
	rm -rf $(WORKDIR)/$(ROOTDIR)
	mkdir -p $(WORKDIR)/$(ROOTDIR)
	# Creating chroot itself
	debootstrap $(REPO_BRANCH) $(WORKDIR)/$(ROOTDIR) $(REPO)
	# Copy additional .deb packages
	if [ -d $(DEBS) ]; then cp $(DEBS)/* $(WORKDIR)/$(ROOTDIR); fi
	# Copy images if present
	if [ -d $(IMAGE_DIR) ]; then cp -r $(IMAGE_DIR) $(WORKDIR)/$(ROOTDIR)/img; fi
	# Copy Inquisitor client package
	cp $(WORKDIR)/build-package/$(PACKAGE_DEB) $(WORKDIR)/$(ROOTDIR)
	# Copy build-specific temporary files
	cp build/debian/packages \
	   build/debian/remove_packages \
	   build/debian/debs \
	   build/debian/preseed $(WORKDIR)/$(ROOTDIR)
	# Run post-debootstrap installation scripts
	CHROOT_PATH=$(WORKDIR)/$(ROOTDIR) \
		REPO=$(REPO) \
		REPO_MULTIMEDIA=$(REPO_MULTIMEDIA) \
		BRANCH=$(REPO_BRANCH) \
		SERVER=$(shell sed -n 's/^SERVER=\(.*\)$$/\1/p' < $(PWD)/client/main/global.in) \
		DEBUG_TTY=$(DEBUG_TTY) build/debian/run_scripts.sh

build-boot:
	echo "There is no real build-boot target. It is dummy."

build-live-configure:
	mkdir -p $(WORKDIR)/$(LIVEDIR)
	cd $(WORKDIR)/$(LIVEDIR) && lh_clean
	rm -rf $(WORKDIR)/$(LIVEDIR)/*
	# Run LiveCD LiveHelper configuration helper script
	WORKDIR=$(WORKDIR) LIVEDIR=$(LIVEDIR) \
		REPO=$(REPO) REPO_MULTIMEDIA=$(REPO_MULTIMEDIA) \
		REPO_SECTIONS=$(REPO_SECTIONS) \
		REPO_BRANCH=$(REPO_BRANCH) DEB_TARGET=$(DEB_TARGET) \
		PACKAGE_DEB=$(PACKAGE_DEB) INQ_VERSION=$(INQ_VERSION) \
		SHARE_DIR=$(SHARE_DIR) \
		IMAGE_DIR=$(IMAGE_DIR) \
		build/debian/live_lh_config.sh

build-root-live: build-live-configure
	cd $(WORKDIR)/$(LIVEDIR) && export MKSQUASHFS_OPTIONS="-e boot" && lh_bootstrap
	cd $(WORKDIR)/$(LIVEDIR) && export MKSQUASHFS_OPTIONS="-e boot" && lh_chroot

build-live:
	cd $(WORKDIR)/$(LIVEDIR) && lh_clean --binary
	cd $(WORKDIR)/$(LIVEDIR) && export MKSQUASHFS_OPTIONS="-e boot" && lh_binary

update-package:
	sudo cp $(WORKDIR)/build-package/$(PACKAGE_DEB) $(WORKDIR)/$(ROOTDIR)
	sudo chroot $(WORKDIR)/$(ROOTDIR) dpkg --purge $(PACKAGE_NAME) || :
	sudo chroot $(WORKDIR)/$(ROOTDIR) dpkg --install /$(PACKAGE_DEB) || :
	sudo rm -f $(WORKDIR)/$(ROOTDIR)/$(PACKAGE_DEB)

update-package-remote:
	scp $(WORKDIR)/build-package/$(PACKAGE_DEB) $(DEPLOY_HOST):
	ssh $(DEPLOY_HOST) -- sudo mv $(PACKAGE_DEB) $(DEPLOY_PATH)
	ssh $(DEPLOY_HOST) -- sudo chroot $(DEPLOY_PATH) dpkg --purge $(PACKAGE_NAME) || true
	ssh $(DEPLOY_HOST) -- sudo chroot $(DEPLOY_PATH) dpkg --install /$(PACKAGE_DEB)
	ssh $(DEPLOY_HOST) -- sudo rm -f $(DEPLOY_PATH)/$(PACKAGE_DEB)

repo-clean:
	rm -f $(WORKDIR)/build-package/$(PACKAGE_DEB)
