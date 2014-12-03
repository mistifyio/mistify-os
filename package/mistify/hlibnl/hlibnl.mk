################################################################################
#
# hlibnl
#
################################################################################

HLIBNL_VERSION = 3.2.25
HLIBNL_SOURCE = libnl-$(HLIBNL_VERSION).tar.gz
HLIBNL_SITE = http://www.infradead.org/~tgr/libnl/files
HLIBNL_LICENSE = LGPLv2.1+
HLIBNL_LICENSE_FILES = COPYING
HLIBNL_INSTALL_STAGING = YES
HLIBNL_DEPENDENCIES = host-bison host-flex

ifeq ($(BR2_PACKAGE_HOST_HLIBNL_TOOLS),y)
HOST_HLIBNL_CONF_OPTS += --enable-cli
else
HOST_HLIBNL_CONF_OPTS += --disable-cli
endif

$(eval $(host-autotools-package))
