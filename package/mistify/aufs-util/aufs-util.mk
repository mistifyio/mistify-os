################################################################################
#
# aufs-util
#
################################################################################

AUFS_UTIL_VERSION = aufs3.9
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

define AUFS_UTIL_HEADERS_INSTALL_STAGING_CMDS
	(cd $(LINUX_HEADERS_DIR); \
		$(TARGET_MAKE_ENV) $(MAKE) \
		ARCH=$(KERNEL_ARCH) \
		HOSTCC="$(HOSTCC)" \
		HOSTCFLAGS="$(HOSTCFLAGS)" \
		HOSTCXX="$(HOSTCXX)" \
		INSTALL_HDR_PATH=$(STAGING_DIR)/usr \
		headers_install)
	cp $(GLIBC_DIR)/sysdeps/unix/sysv/linux/scsi/* \
		$(STAGING_DIR)/usr/include/scsi/
endef

AUFS_UTIL_PRE_BUILD_HOOKS += AUFS_UTIL_HEADERS_INSTALL_STAGING_CMDS

$(eval $(generic-package))
