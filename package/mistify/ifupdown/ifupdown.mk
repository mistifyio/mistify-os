################################################################################
#
# ifupdown
#
################################################################################

IFUPDOWN_VERSION = 6bbaf922dbd2
IFUPDOWN_SITE = http://hg.debian.org/hg/collab-maint/ifupdown
IFUPDOWN_SITE_METHOD = hg
IFUPDOWN_LICENSE = GPLv2
IFUPDOWN_LICENSE_FILES = COPYING

define IFUPDOWN_BUILD_CMDS
	$(MAKE) -C $(@D)
endef

define IFUPDOWN_INSTALL_TARGET_CMDS
	BASEDIR=$(TARGET_DIR) $(MAKE) -C $(@D) install
endef

$(eval $(generic-package))
