################################################################################
#
# spl
#
################################################################################

SPL_VERSION = datasetns
SPL_SITE    = https://github.com/mistifyio/spl.git
SPL_SITE_METHOD = git
SPL_LICENSE = GPL v2
SPL_LICENSE_FILES = COPYING
SPL_INSTALL_STAGING = YES

SPL_DEPENDENCIES = linux

SPL_CONF_OPTS = \
    --prefix=/usr \
    --libdir=/lib \
    --with-linux=$(LINUX_DIR) \
    --with-linux-obj=$(LINUX_DIR)

SPL_AUTORECONF = YES
SPL_AUTORECONF_OPTS = -fiv

SPL_MAKE = $(MAKE1)

$(eval $(autotools-package))
