Summary: @DESCR@
Name: @NAME@
Version: @VERSION@
Vendor: UAM
Release: @RELEASE@
License: http://www.eu-datagrid.org/license.html
Group: @GROUP@
Source: @TARFILE@
BuildArch: noarch
BuildRoot: /var/tmp/%{name}-build
Packager: @AUTHOR@


%description
@DESCR@

%prep
%setup

%build
make

%install
rm -rf $RPM_BUILD_ROOT
make PREFIX=$RPM_BUILD_ROOT install

%package server
Summary: @DESC@ - server side
BuildArch: noarch
Group: @GROUP@

Requires: perl-CAF          >= 1.3.3
Requires: perl-LC
Requires: perl-Crypt-SSLeay
Requires: ccm               >= 2.1.0
Requires: pan-templates     >= 2.7.0
Requires: tftp-server       >= 0.28-2
Requires: xinetd            >= 2.3.11
Requires: syslinux          >= 2.04
Requires: cdb-sync

%description server
@DESCR@

%files server
%defattr(-,root,root)
%attr(550,root,root) @QTTR_SBIN@/aii-shellfe
%attr(550,root,root) @QTTR_SBIN@/aii-dhcp
%attr(555,root,root) @QTTR_SBIN@/aii-installack.cgi
@QTTR_LIB@/aii/nbp/localboot.cfg
%dir @QTTR_DOC@/
%doc @QTTR_DOC@/*
%doc @PAN_TEMPLATESDIR@/@PAN_NAMESPACE_SDIR@/@PAN_QUATTOR_NS@/*
%doc @PAN_TEMPLATESDIR@/@PAN_NAMESPACE_SDIR@/@PAN_SITE_NS@/*
%doc @QTTR_MAN@/man@MANSECT@/aii-shellfe.@MANSECT@.gz
%doc @QTTR_MAN@/man@MANSECT@/aii-dhcp.@MANSECT@.gz
%doc @QTTR_MAN@/man@MANSECT@/aii.@MANSECT@.gz
%doc @QTTR_MAN@/man@MANSECT@/aii-hooks.@MANSECT@.gz
%doc @QTTR_MAN@/man@MANSECT@/aii-update.@MANSECT@.gz


%clean server
rm -rf $RPM_BUILD_ROOT

%post server
mkdir -p /osinstall/nbp 2>/dev/null || :
mkdir -p /osinstall/ks 2>/dev/null || :
mkdir /osinstall/nbp/pxelinux.cfg 2>/dev/null || :
cp -f /usr/lib/syslinux/pxelinux.0 /osinstall/nbp 2>/dev/null || :
if [ ! -f /etc/xinetd.d/tftp ]; then
    cp -f @QTTR_DOC@/eg/tftp.example /etc/xinetd.d/tftp 2>/dev/null || :
    /sbin/service xinetd restart 2>/dev/null || :
else
    echo File /etc/xinetd.d/tftp already exists, I will not overwrite it
    echo You may want to check it against @QTTR_DOC@/eg/tftp.example
fi

if [ ! -d /etc/aii ]; then
    cat <<EOF
Directory /etc/aii/ not found.
All configuration files are now stored on /etc/aii. If you are upgrading from
a previous AII version, just move your old /etc/aii-* files to this directory.
EOF
fi

%package client
Summary: @DESCR@ - client part.
BuildArch: noarch
Group: @GROUP@

Requires: perl-CAF >= 1.3.3
Requires: perl-LC  >= 0.20031127

%description client 
AII Automated Installation Infrastructure - client part.

%files client
%defattr(-,root,root)
%attr(555,root,root) @QTTR_SBIN@/aii-installfe
%doc @QTTR_MAN@/man@MANSECT@/aii-installfe.@MANSECT@.gz
%doc @QTTR_DOC@/eg/aii-installfe.conf

