################################################################################
#
# aufs
#
################################################################################

AUFS_VERSION = aufs3.14.21+
AUFS_SITE = git://git.code.sf.net/p/aufs/aufs3-standalone
AUFS_LICENSE = GPLv2
AUFS_LICENSE_FILES = COPYING
AUFS_DEPENDENCIES += linux-headers

define AUFS_CREATE_SERIES
	printf "aufs3-kbuild.patch\naufs3-base.patch\naufs3-mmap.patch\n" \
		> $(AUFS_DIR)/series
endef

define AUFS_INSTALL_HEADERS
	cp -r $(AUFS_DIR)/Documentation $(LINUX_HEADERS_DIR) ; \
	cp -r $(AUFS_DIR)/fs $(LINUX_HEADERS_DIR) ; \
	cp -r $(AUFS_DIR)/include/uapi/linux/aufs_type.h \
		$(LINUX_HEADERS_DIR)/include/uapi/linux/ ;\
	echo "header-y += aufs_type.h" >> \
		$(LINUX_HEADERS_DIR)/include/uapi/linux/Kbuild
endef

define AUFS_HEADERS_INSTALL_STAGING_CMDS
	(cd $(LINUX_HEADERS_DIR); \
		$(TARGET_MAKE_ENV) $(MAKE) \
		ARCH=$(KERNEL_ARCH) \
		HOSTCC="$(HOSTCC)" \
		HOSTCFLAGS="$(HOSTCFLAGS)" \
		HOSTCXX="$(HOSTCXX)" \
		INSTALL_HDR_PATH=$(STAGING_DIR)/usr \
		headers_install)
endef

#+
# The install of the kernel headers removes some header files which are installed
# with glibc. Restore them.
#-
define AUFS_FIX_USR_INCLUDE
	cp -r $(TOOLCHAIN_PATH)/$(TOOLCHAIN_PREFIX)/sysroot/usr/include/scsi/* \
		$(STAGING_DIR)/usr/include/scsi/
endef

AUFS_POST_BUILD_HOOKS += AUFS_CREATE_SERIES
AUFS_POST_BUILD_HOOKS += AUFS_INSTALL_HEADERS
AUFS_POST_BUILD_HOOKS += AUFS_HEADERS_INSTALL_STAGING_CMDS
AUFS_POST_BUILD_HOOKS += AUFS_FIX_USR_INCLUDE

$(eval $(generic-package))
