################################################################################
#
# statsd
#
################################################################################

STATSD_VERSION       = master
STATSD_SITE          = https://github.com/etsy/statsd.git
STATSD_SITE_METHOD   = git
STATSD_LICENSE       = Etsy
STATSD_LICENSE_FILES = LICENSE

define STATSD_BUILD_CMDS
	@echo "StatsD is based on node.js and therefore doesn't require a build."
endef

define STATSD_INSTALL_TARGET_CMDS
	$(INSTALL) -m 644 -D $(@D)/stats.js $(TARGET_DIR)/usr/share/statsd/stats.js
	mkdir -p $(TARGET_DIR)/usr/share/statsd/lib
	$(INSTALL) -m 644 -D $(@D)/lib/*.js $(TARGET_DIR)/usr/share/statsd/lib/
	mkdir -p $(TARGET_DIR)/usr/share/statsd/servers
	$(INSTALL) -m 644 -D $(@D)/servers/*.js $(TARGET_DIR)/usr/share/statsd/servers/
	mkdir -p $(TARGET_DIR)/usr/share/statsd/backends
	$(INSTALL) -m 644 -D $(@D)/backends/*.js $(TARGET_DIR)/usr/share/statsd/backends/
	mkdir -p $(TARGET_DIR)/etc/statsd
	$(INSTALL) -m 644 -D $(BR2_EXTERNAL)/package/mistify/statsd/Config.js \
	  $(TARGET_DIR)/etc/statsd/Config.js
endef

$(eval $(generic-package))