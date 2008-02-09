%define _ifcfgdir %_sysconfdir/net/ifaces

Name: inquisitor-client
Version: 1.0
Release: alt1

Summary: Inquisitor client for client-server system
License: GPL
Group: Monitoring

Source: %name.tar

Packager: Inquisitor team <team@inquisitor.ru>

BuildRequires: freetype2-devel hwdatabase ruby xorg-x11-devel rpm-build-ruby

%description
Inquisitor client RPM for installation in chroot

%prep
%setup -q -c

%build
%make_build -C client RUBY_SHARE_DIR=%ruby_sitelibdir RUBY_LIB_DIR=%ruby_sitearchdir

%install
%make -C client DESTDIR=%buildroot install

%__mkdir_p %buildroot%_sysconfdir/modutils.d
%__cat << EOF > %buildroot%_sysconfdir/modutils.d/sound
above snd-pcm snd-mixer-oss
above snd-mixer-oss snd-seq-oss
above snd-seq-oss snd-pcm-oss
EOF

%__mkdir_p %buildroot%_sysconfdir/udev/rules.d
%__cat << EOF > %buildroot%_sysconfdir/udev/rules.d/99-msr.rules
KERNEL="msr[0-9]"	NAME="cpu/%%n/msr"
EOF

%__mkdir_p %buildroot%_ifcfgdir/eth0
%__cat << EOF > %buildroot%_ifcfgdir/eth0/options
DISABLE=no
BOOTPROTO=dhcp
ONBOOT=no
USE_HOTPLUG=yes
USE_PCMCIA=yes
PROGRESS=no
VERBOSE=no
EOF

%__cat << EOF > %buildroot%_ifcfgdir/eth0/ifup-post
#!/bin/sh
ADDR=\`grep "^restrict[[:space:]][0-9]" /etc/ntp.conf | tail -1 | cut -d\  -f2\`
IP_DEV=\`ip addr show dev eth0 >/dev/null 2>&1 && ip addr show dev eth0\`
[ -n "\$IP_DEV" ] && echo "\$ADDR" > /etc/ntp/step-tickers
EOF

%files
%_sysconfdir/inquisitor
#%_sysconfdir/X11/xorg.conf*
%_sysconfdir/modutils.d/sound
%_sysconfdir/udev/rules.d/99-msr.rules
%dir %_ifcfgdir/eth0
%_ifcfgdir/eth0/options
%attr(755,root,root) %_ifcfgdir/eth0/ifup-post
%_bindir/*
%_datadir/inquisitor
%_libdir/inquisitor
#%_x11bindir/*
#%_libdir/jtkey
%ruby_sitelibdir/raid
#%ruby_sitearchdir/raid

%changelog
* Mon Sep 17 2007 Inquisitor team <team@inquisitor.ru> 1.0-alt1
- Dummy changelog entry

