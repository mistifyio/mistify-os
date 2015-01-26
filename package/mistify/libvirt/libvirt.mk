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
LIBVIRT_DEPENDENCIES  = host-pkgconf lvm2 libnl libxml2 yajl libpciaccess systemd iptables ebtables
HOST_LIBVIRT_DEPENDENCIES = host-pkgconf host-libxml2 host-hlibnl host-hyajl host-lvm2 systemd iptables ebtables

LIBVIRT_CONF_ENV += IPTABLES_PATH=/usr/sbin/iptables
LIBVIRT_CONF_ENV += IP6TABLES_PATH=/usr/sbin/ip6tables

HOST_LIBVIRT_CONF_ENV += IPTABLES_PATH=/usr/sbin/iptables
HOST_LIBVIRT_CONF_ENV += IP6TABLES_PATH=/usr/sbin/ip6tables

LIBVIRT_CONF_OPTS += --with-init-script=systemd
HOST_LIBVIRT_CONF_OPTS += --with-init-script=systemd

define LIBVIRT_INSTALL_SYSCONFIG
	mkdir -p $(TARGET_DIR)/etc/sysconfig
	$(INSTALL) -D -m 644 \
		$(BR2_EXTERNAL)/package/mistify/libvirt/libvirtd.sysconfig \
		$(TARGET_DIR)/etc/sysconfig/libvirtd
endef

define LIBVIRT_REMOVE_VIRBR
	rm -f $(TARGET_DIR)/etc/libvirt/qemu/networks/default.xml
	rm -f $(TARGET_DIR)/etc/libvirt/qemu/networks/autostart/default.xml
endef

define LIBVIRT_INSTALL_INIT_SYSTEMD
	mkdir -p $(TARGET_DIR)/etc/systemd/system/multi-user.target.wants
	ln -fs /usr/lib/systemd/system/libvirtd.service \
		$(TARGET_DIR)/etc/systemd/system/multi-user.target.wants/libvirtd.service
	ln -fs /usr/lib/systemd/system/libvirt-guests.service \
		$(TARGET_DIR)/etc/systemd/system/multi-user.target.wants/libvirt-guests.service
	ln -fs /usr/lib/systemd/system/virtlockd.service \
		$(TARGET_DIR)/etc/systemd/system/multi-user.target.wants/virtlockd.service
endef

LIBVIRT_POST_INSTALL_TARGET_HOOKS += LIBVIRT_INSTALL_SYSCONFIG
LIBVIRT_POST_INSTALL_TARGET_HOOKS += LIBVIRT_REMOVE_VIRBR

$(eval $(autotools-package))
$(eval $(host-autotools-package))
