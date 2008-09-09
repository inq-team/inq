PACKAGE_NAME=inquisitor-client
PACKAGE_VERSION=1.0
PACKAGE_RELEASE=2
PACKAGE_RPM=$(PACKAGE_NAME)-$(PACKAGE_VERSION)-$(PACKAGE_RELEASE).$(TARGET).rpm

# Local build paths
RPM_BUILD_DIR := $(shell rpm --eval %_topdir)
WORKDIR=$(PWD)/work
REPO=$(PWD)/repo
ROOTDIR=chroot

build-package:
	mkdir -p $(RPM_BUILD_DIR)/SOURCES $(RPM_BUILD_DIR)/SPECS $(REPO)
	cp build/suse/$(PACKAGE_NAME)-$(FLAVOUR).spec $(RPM_BUILD_DIR)/SPECS/$(PACKAGE_NAME).spec
	rm -f $(RPM_BUILD_DIR)/SOURCES/$(PACKAGE_NAME).tar
	tar -cf $(RPM_BUILD_DIR)/SOURCES/$(PACKAGE_NAME).tar client flavour Makefile.config
	rpmbuild -bb --target=$(TARGET) $(RPM_BUILD_DIR)/SPECS/$(PACKAGE_NAME).spec
	mv -f $(RPM_BUILD_DIR)/RPMS/$(TARGET)/$(PACKAGE_RPM) $(REPO)

build-root:
	@echo 'Unable to build root for SuSE automatically. Please build root manually.' && exit 1

update-package-remote:
	scp $(REPO)/$(PACKAGE_RPM) $(DEPLOY_HOST):
	ssh $(DEPLOY_HOST) -- sudo mv $(PACKAGE_RPM) $(DEPLOY_PATH)
	ssh $(DEPLOY_HOST) -- sudo chroot $(DEPLOY_PATH) rpm -e $(PACKAGE_NAME) || true
	ssh $(DEPLOY_HOST) -- sudo chroot $(DEPLOY_PATH) rpm -U /$(PACKAGE_RPM)
	ssh $(DEPLOY_HOST) -- sudo rm -f $(DEPLOY_PATH)/$(PACKAGE_RPM)
