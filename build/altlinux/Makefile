ifeq ($(FLAVOUR), standalone)
PACKAGE_NAME=inquisitor
else
PACKAGE_NAME=inquisitor-client
PACKAGE_VERSION=1.0
PACKAGE_RELEASE=alt1
PACKAGE_RPM=$(PACKAGE_NAME)-$(PACKAGE_VERSION)-$(PACKAGE_RELEASE).$(TARGET).rpm
endif

# Local build paths
#RPM_BUILD_DIR := $(shell rpm --eval %_topdir)
SOURCEDIR := $(shell rpm --eval %_sourcedir | sed "s/%name/$(PACKAGE_NAME)/")
SPECDIR := $(shell rpm --eval %_specdir)
RPMDIR := $(shell rpm --eval %_rpmdir)
WORKDIR=$(PWD)/work
REPO=$(PWD)/repo
ROOTDIR=chroot

build-package:
ifneq ($(FLAVOUR), standalone)
	cp build/altlinux/profile.$(FLAVOUR)/init client/main
endif
	mkdir -p $(SOURCEDIR) $(SPECDIR)
	cp build/altlinux/$(PACKAGE_NAME)-$(FLAVOUR).spec $(SPECDIR)/$(PACKAGE_NAME)-$(FLAVOUR).spec
	rm -f $(SOURCEDIR)/$(PACKAGE_NAME).tar
	tar -cf $(SOURCEDIR)/$(PACKAGE_NAME).tar client flavour Makefile.config
ifeq ($(FLAVOUR), standalone)
	rpmbuild -ba --target=$(TARGET) $(SPECDIR)/$(PACKAGE_NAME)-$(FLAVOUR).spec
else
	rpmbuild -bb --target=$(TARGET) $(SPECDIR)/$(PACKAGE_NAME)-$(FLAVOUR).spec
	mkdir -p $(REPO)/$(TARGET)/RPMS.hasher
	mv -f $(RPMDIR)/$(TARGET)/$(PACKAGE_RPM) $(REPO)/$(TARGET)/RPMS.hasher/
	genbasedir --create --topdir $(REPO) $(TARGET) hasher
endif

ifneq ($(FLAVOUR), standalone)
build-root:
	if [ -d $(WORKDIR)/$(ROOTDIR) ]; then spt-clean -w $(WORKDIR); fi
	rm -rf $(WORKDIR)
	mkdir -p $(WORKDIR)
	ln -sf $(PWD)/build/altlinux/profile.$(FLAVOUR) $(WORKDIR)/profile
	sed -e 's,@@INQ_VERSION@@,$(INQ_VERSION),g; s,@@TARGET@@,$(TARGET),g;' <$(WORKDIR)/profile/config.in >$(WORKDIR)/profile/config
	if [ -d $(REPO) ]; then rm -fr $(WORKDIR)/repo && ln -sf $(PWD)/repo $(WORKDIR); fi
	if [ -d $(REPO_HUGE) ]; then echo "rpm file:$(REPO_HUGE) $(TARGET) huge" >>$(WORKDIR)/aptbox/etc/apt/sources.list; fi
	spt-init-chroot -w $(WORKDIR)
	spt-make-chroot -w $(WORKDIR)
	if [ -d data/out ]; then cp -r data/out $(WORKDIR)/$(ROOTDIR)/data; fi
	if [ -d $(IMAGE_DIR) ]; then cp -r $(IMAGE_DIR) $(WORKDIR)/$(ROOTDIR)/img; fi
	spt-run-scripts -w $(WORKDIR)
	if [ -d data/out ]; then rm -rf $(WORKDIR)/$(ROOTDIR)/data; fi
	if [ -d $(IMAGE_DIR) ]; then rm -rf $(WORKDIR)/$(ROOTDIR)/img; fi

build-huge:
	genbasedir --create --topdir $(REPO_HUGE) $(TARGET) huge

build-boot:
	spt-boot-propagator -w $(WORKDIR)
	spt-boot-gfxboot -w $(WORKDIR)
#	spt-boot-splash -w $(WORKDIR)

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
endif

repo-clean:
	if [ -d $(WORKDIR)/chroot ]; then hsh-rmchroot $(WORKDIR); fi
	rm -f $(REPO)/$(TARGET)/RPMS.hasher/$(PACKAGE_RPM)
