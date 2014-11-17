################################################################################
#
# runit
#
################################################################################

RUNIT_VERSION       = 2.1.2
RUNIT_SOURCE        = runit-$(RUNIT_VERSION).tar.gz
RUNIT_SITE          = http://smarden.org/runit/
RUNIT_LICENSE       = BSD

define RUNIT_BUILD_CMDS
	cd $(@D)/runit-$(RUNIT_VERSION) && \
	package/compile
endef

define RUNIT_INSTALL_TARGET_CMDS
	$(INSTALL) -m 755 -D $(BR2_EXTERNAL)/package/mistify/runit/runsvdir-start \
	$(TARGET_DIR)/usr/sbin/runsvdir-start
	mkdir -p $(TARGET_DIR)/etc/sv
	mkdir -p $(TARGET_DIR)/etc/service

	$(INSTALL) -D $(@D)/runit-$(RUNIT_VERSION)/command/* $(TARGET_DIR)/usr/sbin/
endef

$(eval $(generic-package))
