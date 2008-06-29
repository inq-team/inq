# Note: this spec is maintained inside Inquisitor project. Source
# tarball is pre-configured with "standalone" flavour and is tarred
# specifically for this build.
#
# If this spec is still in main Inquisitor tree, do not rebuild this
# package using just "rpmbuild" - it won't work. Configure it properly
# by editing /Makefile.config and run "make build-package" there.

Name: inquisitor-standalone
Version: 3.0
Release: alt0.rc
URL: http://www.inquisitor.ru/

Summary: Hardware detection, testing and monitoring system (demo standalone version)
License: GPL
Group: Monitoring

Source: inquisitor.tar

# Automatically added by buildreq on Tue Feb 26 2008
BuildRequires: glibc-devel-static linux-libc-headers packages-info-i18n-common ruby ruby-module-optparse rpm-build-ruby

%description
Inquisitor is an open-source hardware testing and certification system,
suitable for both enterprise and home use, customizable, modular and
available in both serverless Live CD/DVD format and server-controlled
network boot production system.

This package includes standalone version of Inquisitor, suitable for
installation in any system, such as regular desktops/servers.

%prep
%setup -q -c

%build
sed -i 's/^TARGET=.*$/TARGET=%_arch/' Makefile.config
sed -i '/^export HOME/ d' client/main/global.in
%make_build -C client RUBY_SHARE_DIR=%ruby_sitelibdir RUBY_LIB_DIR=%ruby_sitearchdir

%install
%make -C client DESTDIR=%buildroot install

%files
%_sysconfdir/inquisitor
#%_sysconfdir/X11/xorg.conf*
%_bindir/*
%_datadir/inquisitor
%_libdir/inquisitor
#%_x11bindir/*
#%_libdir/jtkey
%ruby_sitelibdir/raid
#%ruby_sitearchdir/raid

%changelog
* Wed Apr 09 2008 Mikhail Yakshin <greycat@altlinux.ru> 3.0-alt0.rc
- 3.0-rc release

* Tue Feb 26 2008 Mikhail Yakshin <greycat@altlinux.org> 3.0-alt0.beta2
- Initial build

