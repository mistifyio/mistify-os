#
# openvswitch
#
################################################################################

OPENVSWITCH_VERSION = f823133594320cd15071564126d3b5d554563562
OPENVSWITCH_SITE = https://github.com/openvswitch/ovs.git
OPENVSWITCH_SITE_METHOD = git
OPENVSWITCH_DEPENDENCIES += vtun
OPENVSWITCH_DEPENDENCIES += iproute2
OPENVSWITCH_DEPENDENCIES += python
OPENVSWITCH_DEPENDENCIES += host-python
OPENVSWITCH_DEPENDENCIES += linux
OPENVSWITCH_AUTORECONF = YES
OPENVSWITCH_AUTORECONF_OPTS = --install --force
OPENVSWITCH_LICENSE = Apache-2.0
OPENVSWITCH_CONF_ENV += PYTHON=/usr/bin/python
OPENVSWITCH_CONF_OPTS = \
		--with-linux=$(LINUX_DIR) \
		--with-linux-source=$(LINUX_DIR) \
		--localstatedir=/var

#+
# When using an external toolchain libatomic is not installed by default.
#-
LIB_EXTERNAL_LIBS += libatomic.so*

define OPENVSWITCH_INSTALL_INIT_SYSTEMD
	$(INSTALL) -m 644 -D $(OPENVSWITCH_DIR)/rhel/usr_lib_systemd_system_openvswitch-nonetwork.service \
		$(TARGET_DIR)/lib/systemd/system/openvswitch-nonetwork.service

	$(INSTALL) -m 644 -D $(OPENVSWITCH_DIR)/rhel/usr_lib_systemd_system_openvswitch.service \
		$(TARGET_DIR)/lib/systemd/system/openvswitch.service

	ln -sf ../openvswitch-nonetwork.service \
		$(TARGET_DIR)/lib/systemd/system/multi-user.target.wants/openvswitch-nonetwork.service

	ln -sf ../openvswitch.service \
		$(TARGET_DIR)/lib/systemd/system/multi-user.target.wants/openvswitch.service
endef

define OPENVSWITCH_INSTALL_KMOD
	$(MAKE) -C $(LINUX_DIR) \
		M=$(@D)/datapath/linux \
		$(LINUX_MAKE_FLAGS) \
		INSTALL_MOD_PATH=$(TARGET_DIR) \
		modules_install
endef

define OPENVSWITCH_INSTALL_STUFF
	test -d $(TARGET_DIR)/etc/openvswitch || \
		$(MKDIR) $(TARGET_DIR)/etc/openvswitch

	test -d $(TARGET_DIR)/var/log/openvswitch || \
		$(MKDIR) -p $(TARGET_DIR)/var/log/openvswitch

	test -f $(TARGET_DIR)/etc/modules-load.d/openvswitch.conf || \
		echo "openvswitch" > \
			$(TARGET_DIR)/etc/modules-load.d/openvswitch.conf
	$(INSTALL) -m 755 -D \
		$(BR2_EXTERNAL)/package/mistify/openvswitch/ovsbridge \
		$(TARGET_DIR)/usr/sbin/ovsbridge
	$(INSTALL) -m 644 -D \
		$(BR2_EXTERNAL)/package/mistify/openvswitch/40-openvswitch.rules \
		$(TARGET_DIR)/etc/udev/rules.d/40-openvswitch.rules
	$(INSTALL) -m 644 -D \
		$(BR2_EXTERNAL)/package/mistify/openvswitch/ovsbridge.service \
		$(TARGET_DIR)/lib/systemd/system/ovsbridge.service
	ln -sf ../ovsbridge.service \
		$(TARGET_DIR)/lib/systemd/system/multi-user.target.wants/ovsbridge.service
endef

OPENVSWITCH_POST_INSTALL_TARGET_HOOKS += OPENVSWITCH_INSTALL_KMOD
OPENVSWITCH_POST_INSTALL_TARGET_HOOKS += OPENVSWITCH_INSTALL_STUFF

$(eval $(autotools-package))
