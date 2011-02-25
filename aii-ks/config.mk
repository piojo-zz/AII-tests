COMP=ks
NAME=aii-$(COMP)
AUTHOR=Luis Fernando Muñoz Mejías
MAINTAINER=Luis Fernando Muñoz Mejías
DESCRIPTION=AII plug-in that generates Kickstart files.
DESCR=$(DESCRIPTION)
VERSION=1.1.32
RELEASE=1
PAN_PATH_DEV=/system/blockdevices/
PAN_PATH_FS=/system/filesystems/
PACKAGE_PATH=NCM
NCM_EXTRA_REQUIRES=ncm-lib-blockdevices >= 0.18.3 aii-server >= 0.99 pan-templates > 3.0.7 ccm >= 2.1.0 perl-CAF >= 1.7.0
DATE=13/01/11 17:08
