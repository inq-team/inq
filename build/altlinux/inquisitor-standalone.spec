# Note: this spec is maintained inside Inquisitor project. Source
# tarball is pre-configured with "standalone" flavour and is tarred
# specifically for this build.
#
# If this spec is still in main Inquisitor tree, do not rebuild this
# package using just "rpmbuild" - it won't work. Configure it properly
# by editing /Makefile.config and run "make build-package" there.

Name: inquisitor-standalone
Version: 3.1
Release: alt0.svn1418
URL: http://www.inquisitor.ru/

Summary: Hardware detection, testing and monitoring system (demo standalone version)
License: GPL
Group: Monitoring

Source: inquisitor.tar

# Automatically added by buildreq on Tue Feb 26 2008
BuildRequires: glibc-devel-static linux-libc-headers packages-info-i18n-common ruby ruby-module-optparse rpm-build-ruby perl-threads

Conflicts: memtester

%description
Inquisitor is an open-source hardware testing and certification system,
suitable for both enterprise and home use, customizable, modular and
available in both serverless Live CD/DVD format and server-controlled
network boot production system.

This package includes standalone version of Inquisitor, suitable for
installation in any system, such as regular desktops/servers, mostly for
demonstration purposes.

%prep
%setup -q -c

%build
sed -i 's/^TARGET=.*$/TARGET=%_arch/' Makefile.config
sed -i '/^export HOME/ d' client/main/global.in
# Remove Einarc from standalone: it's already a separate package in Sisyphus
sed -i '/^SUBDIRS/ s/einarc //; /cd einarc/ d' client/lib/Makefile
%make_build -C client RUBY_SHARE_DIR=%ruby_sitelibdir RUBY_LIB_DIR=%ruby_sitearchdir

%install
%make -C client DESTDIR=%buildroot install
mkdir -p %buildroot/%_libdir/inquisitor

%files
%_sysconfdir/inquisitor
%_bindir/*
%_datadir/inquisitor
%_libdir/inquisitor

%changelog
* Sat Jan 10 2009 Mikhail Yakshin <greycat@altlinux.org> 3.1-alt0.svn1418
- Updated to svn 2009-01-10
- Removed some commented out parts of the spec

* Mon Jun 09 2008 Mikhail Yakshin <greycat@altlinux.ru> 3.0-alt3.rc
- Updated to svn 2008-09-06

* Fri Apr 11 2008 Mikhail Yakshin <greycat@altlinux.ru> 3.0-alt2.rc
- Added memtester conflict

* Wed Apr 09 2008 Mikhail Yakshin <greycat@altlinux.ru> 3.0-alt1.rc
- Fixed tarball packaging error

* Wed Apr 09 2008 Mikhail Yakshin <greycat@altlinux.ru> 3.0-alt0.rc
- 3.0-rc release

* Tue Feb 26 2008 Mikhail Yakshin <greycat@altlinux.org> 3.0-alt0.beta2
- Initial build

