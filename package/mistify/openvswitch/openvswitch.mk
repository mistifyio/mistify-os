#
# openvswitch
#
################################################################################

OPENVSWITCH_VERSION = 2.3.0
OPENVSWITCH_SOURCE = openvswitch-$(OPENVSWITCH_VERSION).tar.gz
OPENVSWITCH_SITE = http://openvswitch.org/releases/
OPENVSWITCH_DEPENDENCIES += iproute2 vtun
OPENVSWITCH_DEPENDENCIES += iproute2
OPENVSWITCH_DEPENDENCIES += vtun
OPENVSWITCH_LICENSE = Apache-2.0
OPENVSWITCH_CONF_OPTS = \
		--with-linux=$(LINUX_DIR) \
		--with-linux-source=$(LINUX_DIR) \
		--localstatedir=/var

#+
# When using an external toolchain libatomic is not installed by default.
#-
LIB_EXTERNAL_LIBS += libatomic.so*

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

define OPENVSWITCH_INSTALL_STUFF
	test -d $(TARGET_DIR)/etc/openvswitch || \
		$(MKDIR) $(TARGET_DIR)/etc/openvswitch

	test -d $(TARGET_DIR)/var/log/openvswitch || \
		$(MKDIR) -p $(TARGET_DIR)/var/log/openvswitch

	test -s $(TARGET_DIR)/etc/init.d/K50openvswitch-ipsec || \
		(cd $(TARGET_DIR)/etc/init.d && ln -s ./S61openvswitch-ipsec \
			K50openvswitch-ipsec)

	test -s $(TARGET_DIR)/etc/init.d/K51openvswitch-swtitch || \
		(cd $(TARGET_DIR)/etc/init.d && ln -s ./S60openvswitch-switch \
			K51openvswitch-switch)

	test -s $(TARGET_DIR)/etc/init.d/K52openvswitch-vtep || \
		(cd $(TARGET_DIR)/etc/init.d && ln -s ./S59openvswitch-vtep \
			K52openvswitch-vtep)
endef

OPENVSWITCH_POST_INSTALL_TARGET_HOOKS = OPENVSWITCH_INSTALL_STUFF

$(eval $(autotools-package))
