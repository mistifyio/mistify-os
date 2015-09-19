#############################################################
#
# autoconf
#
#############################################################

SDK_AUTOCONF_VERSION = 2.68
SDK_AUTOCONF_SOURCE = autoconf-$(SDK_AUTOCONF_VERSION).tar.gz
SDK_AUTOCONF_SITE = $(BR2_GNU_MIRROR)/autoconf

SDK_AUTOCONF_LICENSE = GPLv3+ with exceptions
SDK_AUTOCONF_LICENSE_FILES = COPYINGv3 COPYING.EXCEPTION

SDK_AUTOCONF_CONF_ENV = EMACS="no" ac_cv_path_M4=$(TARGET_DIR)/usr/bin/m4 \
		    ac_cv_prog_gnu_m4_gnu=no

SDK_AUTOCONF_DEPENDENCIES = sdk-m4 perl

$(eval $(autotools-package))

