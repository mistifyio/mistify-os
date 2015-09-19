################################################################################
#
# flex
#
################################################################################

SDK_FLEX_VERSION = 2.5.37
SDK_FLEX_SITE = http://download.sourceforge.net/project/flex
SDK_FLEX_SOURCE = flex-$(SDK_FLEX_VERSION).tar.bz2
SDK_FLEX_INSTALL_STAGING = YES
SDK_FLEX_LICENSE = FLEX
SDK_FLEX_LICENSE_FILES = COPYING
SDK_FLEX_DEPENDENCIES = \
	$(if $(BR2_PACKAGE_GETTEXT_IF_LOCALE),gettext) host-m4
SDK_FLEX_CONF_ENV = ac_cv_path_M4=/usr/bin/m4

$(eval $(autotools-package))
