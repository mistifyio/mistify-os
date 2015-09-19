#############################################################
#
# bison
#
#############################################################

SDK_BISON_VERSION = 2.7
SDK_BISON_SITE = $(BR2_GNU_MIRROR)/bison
SDK_BISON_SOURCE = bison-$(SDK_BISON_VERSION).tar.gz
SDK_BISON_LICENSE = GPLv3+
SDK_BISON_LICENSE_FILES = COPYING
SDK_BISON_CONF_ENV = ac_cv_path_M4=$(TARGET_DIR)/usr/bin/m4
SDK_BISON_DEPENDENCIES = sdk-m4

define SDK_BISON_DISABLE_EXAMPLES
	echo 'all install:' > $(@D)/examples/Makefile
endef

SDK_BISON_POST_CONFIGURE_HOOKS += SDK_BISON_DISABLE_EXAMPLES

$(eval $(autotools-package))
