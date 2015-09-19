#############################################################
#
# automake
#
#############################################################

SDK_AUTOMAKE_VERSION = 1.11.6
SDK_AUTOMAKE_SITE = $(BR2_GNU_MIRROR)/automake
SDK_AUTOMAKE_SOURCE = automake-$(SDK_AUTOMAKE_VERSION).tar.gz
SDK_AUTOMAKE_LICENSE = GPLv2+
SDK_AUTOMAKE_LICENSE_FILES = COPYING

SDK_AUTOMAKE_DEPENDENCIES = sdk-autoconf perl

$(eval $(autotools-package))

