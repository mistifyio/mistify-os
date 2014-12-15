################################################################################
#
# libvirt
#
################################################################################

LIBVIRT_VERSION       = 1.2.9
LIBVIRT_SOURCE        = libvirt-$(LIBVIRT_VERSION).tar.gz
LIBVIRT_SITE          = http://libvirt.org/sources/
LIBVIRT_LICENSE       = GPLv2 LGPLv2.1
LIBVIRT_LICENSE_FILES = COPYING COPYING.LESSER
LIBVIRT_DEPENDENCIES  = host-pkgconf lvm2 libnl libxml2 yajl libpciaccess
HOST_LIBVIRT_DEPENDENCIES = host-pkgconf host-libxml2 host-hlibnl host-hyajl host-lvm2

define LIBVIRT_INSTALL_SYSCONFIG
	mkdir -p $(TARGET_DIR)/etc/sysconfig
	$(INSTALL) -D -m 644 \
		$(BR2_EXTERNAL)/package/mistify/libvirt/libvirtd.sysconfig \
		$(TARGET_DIR)/etc/sysconfig/libvirtd
endef

define LIBVIRT_INSTALL_INIT_SYSTEMD
	$(INSTALL) -D -m 644 \
		$(BR2_EXTERNAL)/package/mistify/libvirt/libvirtd.service \
		$(TARGET_DIR)/etc/systemd/system/libvirtd.service
	mkdir -p $(TARGET_DIR)/etc/systemd/system/multi-user.target.wants
	ln -fs ../libvirtd.service \
		$(TARGET_DIR)/etc/systemd/system/multi-user.target.wants/libvirtd.service
endef

LIBVIRT_POST_INSTALL_TARGET_HOOKS += LIBVIRT_INSTALL_SYSCONFIG

$(eval $(autotools-package))
$(eval $(host-autotools-package))
