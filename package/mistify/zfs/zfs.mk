################################################################################
#
# zfs
#
################################################################################

ZFS_VERSION = master
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

define ZFS_INSTALL_MOUNT_SYMLINK
	# zfs installs mount.zfs to /usr/sbin, when it really should be in /sbin
	# so that mount(1M) can find it.
	ln -fs /sbin/mount.zfs $(TARGET_DIR)/usr/sbin/mount.zfs
endef

define ZFS_INSTALL_INIT_SYSTEMD
	ln -fs /usr/lib/systemd/system/zfs.target \
		$(TARGET_DIR)/etc/systemd/system/multi-user.target.wants/zfs.target
endef

ZFS_POST_INSTALL_TARGET_HOOKS += ZFS_REMOVE_INIT_SCRIPT
ZFS_POST_INSTALL_TARGET_HOOKS += ZFS_INSTALL_MOUNT_SYMLINK

ZFS_CONF_OPTS = \
    --prefix=/ \
    --includedir=/usr/include \
    --libdir=/lib \
    --with-linux=$(LINUX_DIR) \
    --with-linux-obj=$(LINUX_DIR) \
    --datarootdir=/usr/share \
    --with-spl=$(SPL_DIR)  \
    --with-spl-obj=$(SPL_DIR) \
    --with-blkid=yes \
    --disable-silent-rules

ZFS_MAKE = $(MAKE1)

$(eval $(autotools-package))
