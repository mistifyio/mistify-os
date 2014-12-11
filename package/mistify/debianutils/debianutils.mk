################################################################################
#
# debianutils
#
################################################################################

DEBIANUTILS_VERSION = debian/4.4
DEBIANUTILS_SITE = git://git.debian.org/users/clint/debianutils.git
DEBIANUTILS_LICENSE = GPLv2
DEBIANUTILS_LICENSE_FILES = COPYING

DEBIANUTILS_AUTORECONF = YES
DEBIANUTILS_AUTORECONF_OPTS = -fiv

define DEBIANUTILS_CREATE_ACINCLUDE
	printf "define(DEBIANUTILS_VERSION, %s)\n" $(DEBIANUTILS_VERSION) \
		> $(DEBIANUTILS_DIR)/acinclude.m4
endef

define DEBIANUTILS_BUILD_CMDS
	$(MAKE) CC="$(TARGET_CC)" LD="$(TARGET_LD)" -C $(@D) run-parts
endef

define DEBIANUTILS_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/run-parts $(TARGET_DIR)/bin
endef

DEBIANUTILS_POST_EXTRACT_HOOKS += DEBIANUTILS_CREATE_ACINCLUDE


$(eval $(autotools-package))
