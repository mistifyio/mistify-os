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
HOST_LIBVIRT_DEPENDENCIES = host-pkgconf host-libxml2 host-hlibnl

define LIBVIRT_INSTALL_INIT_SYSV
	$(INSTALL) -m 755 -D \
		$(BR2_EXTERNAL)/package/mistify/libvirt/libvirt-bin.init \
	$(TARGET_DIR)/etc/init.d/S65libvirt-bin
endef

define LIBVIRT_INSTALL_DEFAULTS
	$(INSTALL) -m 644 -D \
		$(BR2_EXTERNAL)/package/mistify/libvirt/libvirt-bin.defaults \
		$(TARGET_DIR)/etc/default/libvirt-bin
endef

define LIBVIRT_INSTALL_STOPSCRIPT
	test -s $(TARGET_DIR)/etc/init.d/K30libvirt-bin || \
		(cd $(TARGET_DIR)/etc/init.d && ln -s ./S65libvirt-bin \
			K40libvirt-bin)
endef

LIBVIRT_POST_INSTALL_TARGET_HOOKS += LIBVIRT_INSTALL_DEFAULTS
LIBVIRT_POST_INSTALL_TARGET_HOOKS += LIBVIRT_INSTALL_STOPSCRIPT

$(eval $(autotools-package))
$(eval $(host-autotools-package))
