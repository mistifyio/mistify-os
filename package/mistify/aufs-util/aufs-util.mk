################################################################################
#
# aufs-util
#
################################################################################

AUFS_UTIL_VERSION = aufs4.0
AUFS_UTIL_SITE = git://git.code.sf.net/p/aufs/aufs-util
AUFS_UTIL_LICENSE = GPLv2
AUFS_UTIL_LICENSE_FILES = COPYING
AUFS_UTIL_DEPENDENCIES += aufs
AUFS_UTIL_DEPENDENCIES += linux
AUFS_UTIL_DEPENDENCIES += linux-headers

AUFS_UTIL_CPPFLAGS = \
	-I$(STAGING_DIR)/usr/include \
	-I$(STAGING_DIR)/usr/include/uapi

define AUFS_UTIL_BUILD_CMDS
	$(MAKE) \
		CC="$(TARGET_CC)" \
		LD="$(TARGET_LD)" \
		CPPFLAGS="$(AUFS_UTIL_CPPFLAGS)" \
		BuildFHSM=no \
		-C $(@D) \
		all
endef

define AUFS_UTIL_INSTALL_TARGET_CMDS
	$(MAKE) \
		CC="$(TARGET_CC)" \
		LD="$(TARGET_LD)" \
		CPPFLAGS="$(AUFS_UTIL_CPPFLAGS)" \
		DESTDIR="$(TARGET_DIR)" \
		Install="$(INSTALL)" \
		BuildFHSM=no \
		-C $(@D) \
		install_sbin install_ubin install_etc
endef


$(eval $(generic-package))
