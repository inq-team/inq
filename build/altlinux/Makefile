PACKAGE_NAME=inquisitor-client
PACKAGE_VERSION=1.0
PACKAGE_RELEASE=alt1
PACKAGE_RPM=$(PACKAGE_NAME)-$(PACKAGE_VERSION)-$(PACKAGE_RELEASE).$(TARGET).rpm

# Local build paths
RPM_BUILD_DIR=$(HOME)
WORKDIR=$(PWD)/work
REPO=$(PWD)/repo
ROOTDIR=chroot

build-package: 
	mkdir -p $(RPM_BUILD_DIR)/RPM/SOURCES $(RPM_BUILD_DIR)/RPM/SPECS $(REPO)/$(TARGET)/RPMS.hasher
	cp build/altlinux/$(PACKAGE_NAME)-$(FLAVOUR).spec $(RPM_BUILD_DIR)/RPM/SPECS/$(PACKAGE_NAME).spec
	rm -f $(RPM_BUILD_DIR)/RPM/SOURCES/$(PACKAGE_NAME).tar
	tar -cf $(RPM_BUILD_DIR)/RPM/SOURCES/$(PACKAGE_NAME).tar client flavour Makefile.config
	rpmbuild -bb --target=$(TARGET) $(RPM_BUILD_DIR)/RPM/SPECS/$(PACKAGE_NAME).spec
	mv -f $(RPM_BUILD_DIR)/RPM/RPMS/$(TARGET)/$(PACKAGE_RPM) $(REPO)/$(TARGET)/RPMS.hasher/
	genbasedir --create --topdir $(REPO) $(TARGET) hasher

build-root:
	if [ -d $(WORKDIR)/$(ROOTDIR) ]; then spt-clean -w $(WORKDIR); fi
	rm -rf $(WORKDIR)
	mkdir -p $(WORKDIR)
	ln -sf ../build/altlinux/profile.$(FLAVOUR) $(WORKDIR)/profile
	sed -i 's/^ARCH=.*$/ARCH=$(TARGET)/' $(WORKDIR)/profile/config 
	if [ -d $(REPO) ]; then rm -fr $(WORKDIR)/repo && ln -sf ../repo $(WORKDIR); fi
	if [ -d $(REPO_HUGE) ]; then echo "rpm file:$(REPO_HUGE) $(TARGET) huge" >>$(WORKDIR)/aptbox/etc/apt/sources.list; fi
	spt-init-chroot -w $(WORKDIR)
	spt-make-chroot -w $(WORKDIR)
	spt-run-scripts -w $(WORKDIR)

build-huge:
	genbasedir --create --topdir $(REPO_HUGE) $(TARGET) huge

build-boot:
	spt-boot-propagator -w $(WORKDIR)

build-live:
	spt-pack-squashfs -w $(WORKDIR)
	spt-pack-iso -w $(WORKDIR)

update-package:
	if hsh-run $(WORKDIR) -- rpm -q $(PACKAGE_NAME); then hsh-run --rooter $(WORKDIR) -- rpm -e $(PACKAGE_NAME); fi
	cp $(REPO)/$(TARGET)/RPMS.hasher/$(PACKAGE_RPM) $(WORKDIR)/$(ROOTDIR)
	hsh-run --rooter $(WORKDIR) -- rpm -U /$(PACKAGE_RPM)
	rm -f $(WORKDIR)/$(ROOTDIR)/$(PACKAGE_RPM)

update-package-remote:
	scp $(REPO)/$(TARGET)/RPMS.hasher/$(PACKAGE_RPM) $(DEPLOY_HOST):
	ssh $(DEPLOY_HOST) -- sudo mv $(PACKAGE_RPM) $(DEPLOY_PATH)
	ssh $(DEPLOY_HOST) -- sudo chroot $(DEPLOY_PATH) rpm -e $(PACKAGE_NAME) || true
	ssh $(DEPLOY_HOST) -- sudo chroot $(DEPLOY_PATH) rpm -U /$(PACKAGE_RPM)
	ssh $(DEPLOY_HOST) -- sudo rm -f $(DEPLOY_PATH)/$(PACKAGE_RPM)
