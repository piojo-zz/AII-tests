COMP=ks
NAME=aii-$(COMP)
AUTHOR=Luis Fernando Muñoz Mejías
MAINTAINER=Luis Fernando Muñoz Mejías
DESCRIPTION=AII plug-in that generates Kickstart files.
DESCR=$(DESCRIPTION)
VERSION=2.3.0
RELEASE=ms14
PAN_PATH_DEV=/system/blockdevices/
PAN_PATH_FS=/system/filesystems/
PACKAGE_PATH=NCM
NCM_EXTRA_REQUIRES=ncm-lib-blockdevices >= 0.18.3 aii-server >= 0.99 pan-templates > 3.0.7 ccm >= 2.1.0 perl-CAF >= 1.7.0 ncm-ncd >= 1.3.3
DATE=24/06/11 17:00
