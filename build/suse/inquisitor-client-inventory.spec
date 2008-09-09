Name: inquisitor-inventory-client
Version: 1.2
Release: 1

License: GPL
Group: Monitoring

Source: %name.tar

Packager: Inquisitor team <team@inquisitor.ru>

BuildRoot: %{_tmppath}/%{name}-%{version}-build
BuildRequires: freetype2-devel ruby xorg-x11-devel

Summary: Inquisitor inventory client for client-server system

%description
Inquisitor inventory client RPM

%prep
%setup -q -c

%build
make -C client RUBY_SHARE_DIR=%{_libdir}/ruby/vendor_ruby/%{rb_ver} RUBY_LIB_DIR=%{_libdir}/ruby/vendor_ruby/%{rb_ver}

%install
make -C client DESTDIR=$RPM_BUILD_ROOT install

%files
%_sysconfdir/inquisitor
#%_sysconfdir/X11/xorg.conf*
%_bindir/*
%_datadir/inquisitor
%_libdir/inquisitor
#%_x11bindir/*
#%_libdir/jtkey
%{_libdir}/ruby/vendor_ruby/%{rb_ver}/raid

%changelog
* Mon Sep 17 2007 Inquisitor team <team@inquisitor.ru> 1.0-alt1
- Dummy changelog entry

