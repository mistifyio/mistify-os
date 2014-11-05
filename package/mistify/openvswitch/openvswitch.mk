#
# openvswitch
#
################################################################################

OPENVSWITCH_VERSION = 2.3.0
OPENVSWITCH_SOURCE = openvswitch-$(OPENVSWITCH_VERSION).tar.gz
OPENVSWITCH_SITE = http://openvswitch.org/releases/
OPENVSWITCH_DEPENDENCIES += linux-headers iproute2 vtun
OPENVSWITCH_DEPENDENCIES += iproute2
OPENVSWITCH_DEPENDENCIES += vtun
OPENVSWITCH_LICENSE = Apache-2.0
OPENVSWITCH_CONF_OPT = \
		--with-linux=$(LINUX_DIR) \
		--with-linux-source=$(LINUX_DIR) \
		--localstatedir=/var

# Add --with-openssl
# ifeq ($(BR2_PACKAGE_OPENSSL),y)
#	OPENVSWITCH_DEPENDENCIES += openssl
#	OPENVSWITCH_CONF_OPT += --with-openssl=$(STAGING_DIR)
# endif

define OPENVSWITCH_INSTALL_INIT_SYSV
 	$(INSTALL) -m 755 -D \
		$(BR2_EXTERNAL)/package/mistify/openvswitch/S59openvswitch-vtep \
 		$(TARGET_DIR)/etc/init.d/S59openvswitch-vtep
 	$(INSTALL) -m 755 -D \
		$(BR2_EXTERNAL)/package/mistify/openvswitch/S60openvswitch-switch \
 		$(TARGET_DIR)/etc/init.d/S60openvswitch-switch
 	$(INSTALL) -m 755 -D \
		$(BR2_EXTERNAL)/package/mistify/openvswitch/S61openvswitch-ipsec \
 		$(TARGET_DIR)/etc/init.d/S61openvswitch-ipsec

endef

define OPENVSWITCH_POST_INSTALL_TARGET_HOOKS
	$(MKDIR) $(TARGET_DIR)/etc/openvswitch
endef

$(eval $(autotools-package))
