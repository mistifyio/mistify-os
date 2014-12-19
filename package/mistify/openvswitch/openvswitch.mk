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

define OPENVSWITCH_INSTALL_INIT_SYSTEMD
	$(INSTALL) -m 644 -D $(OPENVSWITCH_DIR)/rhel/usr_lib_systemd_system_openvswitch-nonetwork.service \
		$(TARGET_DIR)/etc/systemd/system/openvswitch-nonetwork.service

	$(INSTALL) -m 644 -D $(OPENVSWITCH_DIR)/rhel/usr_lib_systemd_system_openvswitch.service \
		$(TARGET_DIR)/etc/systemd/system/openvswitch.service

	ln -sf ../openvswitch-nonetwork.service \
		$(TARGET_DIR)/etc/systemd/system/multi-user.target.wants/openvswitch-nonetwork.service

	ln -sf ../openvswitch.service \
		$(TARGET_DIR)/etc/systemd/system/multi-user.target.wants/openvswitch.service
endef

define OPENVSWITCH_INSTALL_STUFF
	test -d $(TARGET_DIR)/etc/openvswitch || \
		$(MKDIR) $(TARGET_DIR)/etc/openvswitch

	test -d $(TARGET_DIR)/var/log/openvswitch || \
		$(MKDIR) -p $(TARGET_DIR)/var/log/openvswitch
endef

OPENVSWITCH_POST_INSTALL_TARGET_HOOKS = OPENVSWITCH_INSTALL_STUFF

$(eval $(autotools-package))
