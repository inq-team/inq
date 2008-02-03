PACKAGE_NAME=inquisitor-client
PACKAGE_VERSION=1.0
PACKAGE_RELEASE=1
PACKAGE_DIR=$(PACKAGE_NAME)-$(PACKAGE_VERSION)-$(PACKAGE_RELEASE)
PACKAGE_DEB=$(PACKAGE_NAME)_$(PACKAGE_VERSION)-$(PACKAGE_RELEASE)_$(TARGET).deb

# Local build paths
WORKDIR=$(PWD)/work
REPO=$(PWD)/repo
ROOTDIR=chroot

build-package:
	rm -rf $(WORKDIR)/build-package
	mkdir -p $(WORKDIR)/build-package
	cp -r client $(WORKDIR)/build-package/$(PACKAGE_DIR)
	cp -r flavour Makefile.config $(WORKDIR)/build-package
	cp -r build/debian/debian $(WORKDIR)/build-package/$(PACKAGE_DIR)
	cd $(WORKDIR)/build-package/$(PACKAGE_DIR) && dpkg-buildpackage -b -a$(TARGET) -us -uc

build-root:
	@echo 'Unable to build root for Debian automatically. Please build root manually.' && exit 1

update-package-remote:
	scp $(REPO)/$(PACKAGE_DEB) $(DEPLOY_HOST):
	ssh $(DEPLOY_HOST) -- sudo mv $(PACKAGE_DEB) $(DEPLOY_PATH)
	ssh $(DEPLOY_HOST) -- sudo chroot $(DEPLOY_PATH) dpkg --purge $(PACKAGE_NAME) || true
	ssh $(DEPLOY_HOST) -- sudo chroot $(DEPLOY_PATH) dpkg --install /$(PACKAGE_DEB)
	ssh $(DEPLOY_HOST) -- sudo rm -f $(DEPLOY_PATH)/$(PACKAGE_DEB)
