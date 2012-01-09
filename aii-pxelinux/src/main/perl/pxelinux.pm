# ${license-info}
# ${developer-info
# ${author-info}
# ${build-info}
# File: pxelinux.pm
# Implementation of ncm-pxelinux
# Author: Luis Fernando Muñoz Mejías
# Version: 1.1.12 : 05/01/12 19:24
#  ** Generated file : do not edit **
#
# Capitalized methods are "public" methods. Methods in lowercase are
# "private" methods.

package NCM::Component::pxelinux;

use strict;
use warnings;
use NCM::Component;
use EDG::WP4::CCM::Property;
use NCM::Check;
use CAF::FileWriter;
use NCM::Component::ks qw (ksuserhooks);
use LC::Fatal qw (symlink);
use File::stat;
use Time::localtime;

use constant PXEROOT	=> "/system/aii/nbp/pxelinux";
use constant NBPDIR	=> 'nbpdir';
use constant LOCALBOOT	=> 'bootconfig';
use constant HOSTNAME	=> "/system/network/hostname";
use constant DOMAINNAME	=> "/system/network/domainname";
use constant ETH	=> "/system/network/interfaces";
use constant INSTALL	=> 'install';
use constant BOOT	=> 'boot';
use constant RESCUE	=> 'rescue';
use constant RESCUEBOOT => 'rescueconfig';
# Hooks for NBP plug-in
use constant RESCUE_HOOK_PATH	=> '/system/aii/hooks/rescue';
use constant INSTALL_HOOK_PATH	=> '/system/aii/hooks/install';
use constant REMOVE_HOOK_PATH	=> '/system/aii/hooks/remove';
use constant BOOT_HOOK_PATH	=> '/system/aii/hooks/boot';

our @ISA = qw (NCM::Component);
our $EC = LC::Exception::Context->new->will_store_all;
our $this_app = $main::this_app;

# Returns the absolute path where the PXE file must be written.
sub filepath
{
    my $cfg = shift;

    my $h = $cfg->getElement (HOSTNAME)->getValue;
    my $d = $cfg->getElement (DOMAINNAME)->getValue;
    my $dir = $this_app->option (NBPDIR);
    $this_app->debug(3, "NBP directory = $dir");
    return "$dir/$h.$d.cfg";
}

# Prints the PXE configuration file.
sub pxeprint
{
    my  $cfg = shift;
    my $t = $cfg->getElement (PXEROOT)->getTree;
    my $fh = CAF::FileWriter->open (filepath ($cfg),
				    log => $this_app);
    $t->{append} = "" unless exists $t->{append};
    $fh->print (<<EOF
# File generated by pxelinux AII plug-in.
# Do not edit.
default $t->{label}
    label $t->{label}
    kernel $t->{kernel}
    append ramdisk=32768 initrd=$t->{initrd} ks=$t->{kslocation} ksdevice=$t->{ksdevice} $t->{append}
EOF
	       );

    $fh->close();
}

# Prints an IP address in hexadecimal.
sub hexip
{
    my $ip = shift || "";

    return sprintf ("%02X%02X%02X%02X", $1, $2, $3, $4) if ($ip =~ m/^(\d+)\.(\d+)\.(\d+)\.(\d+)$/);
}

# Creates a symbolic link for PXE. This means creating a symlink named
# after the node's IP in hexadecimal to a PXE file.
sub pxelink
{
    my ($cfg, $cmd) = @_;

    my $t = $cfg->getElement (ETH)->getTree;
    my $path;
    if (!$cmd) {
	$path = $this_app->option (LOCALBOOT);
	$this_app->debug (5, "Configuring on $path");
    } elsif ($cmd eq BOOT) {
	$path = $this_app->option (LOCALBOOT);
	unless ($path =~ m{^([-.\w]+)$}) {
	    $this_app->error ("Unexpected BOOT configuration file");
	    return -1;
	}
	$path = $1;
	$this_app->debug (5, "Local booting from $path");
    } elsif ($cmd eq RESCUE) {
	$path = $this_app->option (RESCUEBOOT);
	unless ($path =~ m{^([-.\w]+)$}) {
	    $this_app->error ("Unexpected RESCUE configuration file");
	    return -1;
	}
	$path = $1;
	$this_app->debug (5, "Rescueing from: $path");
    } elsif ($cmd eq INSTALL) {
	$path = filepath ($cfg);
	$this_app->debug (5, "Installing on $path");
    } else {
	$this_app->debug (5, "Unknown command");
	return -1;
    }
    # Set the same settings for every network interface that has a
    # defined IP address.
    foreach my $st (values (%$t)) {
	next unless exists ($st->{ip});
	my $dir = $this_app->option (NBPDIR);
	my $lnname = "$dir/".hexip ($st->{ip});
	if ($cmd || ! -l $lnname) {
	    unlink ($lnname);
	    # This must be stripped to work with chroot'edg
	    # environments.
	    $path =~ s{$dir/?}{};
	    symlink ($path, $lnname);
	}
    }
    return 0;
}

# Sets the node's status to install.
sub Install
{
    my ($self, $cfg) = @_;

    if ($NoAction) {
	$self->info ("Would run " . ref ($self) . "::Install");
	return 1;
    }
    unless (pxelink ($cfg, INSTALL)==0) {
	$self->error ("Failed to change the status to install");
	return 0;
    }
    ksuserhooks ($cfg, INSTALL_HOOK_PATH);
    return 1;
}

# Sets the node's status to rescue.
sub Rescue
{
    my ($self, $cfg) = @_;

    if ($NoAction) {
	$self->info ("Would run " . ref ($self) . "::Rescue");
	return 1;
    }
    unless (pxelink ($cfg, RESCUE)==0) {
	$self->error ("Failed to change the status to rescue");
	return 0;
    }
    ksuserhooks ($cfg, RESCUE_HOOK_PATH);
    return 1;
}

# Prints the status of the node.
sub Status
{
    my ($self, $cfg) = @_;

    my $t = $cfg->getElement (ETH)->getTree;
    my $dir = $this_app->option (NBPDIR);
    my $h = $cfg->getElement (HOSTNAME)->getValue;
    my $d = $cfg->getElement (DOMAINNAME)->getValue;
    my $fqdn = "$h.$d";
    my $boot = $this_app->option (LOCALBOOT);
    my $rescue = $this_app->option (RESCUE);
    foreach my $s (values (%$t)) {
	next unless exists ($s->{ip});
	my $ln = hexip ($s->{ip});
	my $since = "unknown";
	my $st;
	if (-l "$dir/$ln") {
	    $since = ctime(lstat("$dir/$ln")->ctime());
	    my $name = readlink ("$dir/$ln");
	    if (! -e "$dir/$name") {
		$st = "broken";
	    } elsif ($name =~ m{^(?:.*/)?$fqdn\.cfg$}) {
		$st = "install";
	    } elsif ($name =~ m{^$boot$}) {
		$st = "boot";
	    } else {
		$st = "rescue";
	    }
	} else {
	    $st = "undefined";
	}
	$self->info(ref($self), " status for $fqdn: $s->{ip} $st ",
		    "since: $since");
    }
    return 1;
}

# Sets the node's status to boot from local boot.
sub Boot
{
    my ($self, $cfg) = @_;
    if ($NoAction) {
	$self->info ("Would run ". ref ($self) ."::Boot");
	return 1;
    }
    pxelink ($cfg, BOOT);
    ksuserhooks ($cfg, BOOT_HOOK_PATH);
    return 1;
}

# Creates the PXE configuration file.
sub Configure
{
    my ($self, $cfg) = @_;

    if ($NoAction) {
	my $hostname = $cfg->getElement (HOSTNAME)->getValue;
	$self->info ("Would execute " . ref ($self) . " on $hostname");
	return 1;
    }

    pxeprint ($cfg);
    pxelink ($cfg);

    return 1;
}

# Removes PXE files and symlinks for the node. To be called by --remove.
sub Unconfigure
{
    my ($self, $cfg) = @_;

    if ($NoAction) {
	$self->info ("Would remove " . ref ($self));
	return 1;
    }

    my $t = $cfg->getElement (ETH)->getTree;
    my $path = filepath ($cfg);
    my $dir = $this_app->option (NBPDIR);
    # Set the same settings for every network interface.
    unlink ($path);
    unlink ("$dir/" . hexip ($_->{ip})) foreach values (%$t);
    ksuserhooks ($cfg, REMOVE_HOOK_PATH);
    return 1;
}