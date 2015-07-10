################################################################################
#
# zfs
#
################################################################################

ZFS_VERSION = zfs-0.6.4.2
ZFS_SITE    = https://github.com/zfsonlinux/zfs.git
ZFS_SITE_METHOD = git
ZFS_LICENSE = CDDL
ZFS_LICENSE_FILES = OPENSOLARIS.LICENSE
ZFS_INSTALL_STAGING = YES

ZFS_AUTORECONF = YES
ZFS_AUTORECONF_OPTS = -fiv

ZFS_DEPENDENCIES = linux spl

define ZFS_INSTALL_SYSTEM_MAP
	# When the ZFS build invokes depmod it needs a current System.map file.
	# The ZFS build assumes this file is in $(TARGET_DIR)/root. Buildroot
	# doesn't install this file when building an initrd image.
	if [[ "$(BR2_TARGET_ROOTFS_CPIO)" == "y" ]]; then \
	  mkdir -p $(TARGET_DIR)/boot; \
	  cp $(LINUX_DIR)/System.map $(TARGET_DIR)/boot/System.map-$(LINUX_VERSION); \
	fi
endef

ZFS_PRE_BUILD_HOOKS += ZFS_INSTALL_SYSTEM_MAP

define ZFS_REMOVE_INIT_SCRIPT
	# zfs installed its version of the init script.
	# This package assumes the appropriate init script is in the board 
	# rootfs overlay.
	rm $(TARGET_DIR)/etc/init.d/zfs
endef

define ZFS_INSTALL_INIT_SYSTEMD
	mkdir -p $(TARGET_DIR)/etc/systemd/system/multi-user.target.wants
	ln -fs /usr/lib/systemd/system/zfs.target \
		$(TARGET_DIR)/etc/systemd/system/multi-user.target.wants/zfs.target
endef

define ZFS_INSTALL_UDEV_RULES
	$(INSTALL) -m 644 -D \
		$(BR2_EXTERNAL)/package/mistify/zfs/91-zfs-permissions.rules \
		$(TARGET_DIR)/lib/udev/rules.d/91-zfs-permissions.rules
endef

ZFS_POST_INSTALL_TARGET_HOOKS += ZFS_REMOVE_INIT_SCRIPT
ZFS_POST_INSTALL_TARGET_HOOKS += ZFS_INSTALL_UDEV_RULES

ZFS_CONF_OPTS = \
    --prefix=/usr \
    --bindir=/bin \
    --sbindir=/sbin \
    --libdir=/lib \
    --sysconfdir=/etc \
    --with-udevdir=/lib/udev \
    --with-linux=$(LINUX_DIR) \
    --with-linux-obj=$(LINUX_DIR) \
    --with-spl=$(SPL_DIR)  \
    --with-spl-obj=$(SPL_DIR) \
    --with-blkid=yes \
    --disable-silent-rules

ZFS_MAKE = $(MAKE1)

$(eval $(autotools-package))
