################################################################################
#
# sdk-ccache
#
################################################################################

SDK_CCACHE_VERSION = 3.2.2
SDK_CCACHE_SITE = https://samba.org/ftp/ccache
SDK_CCACHE_SOURCE = ccache-$(SDK_CCACHE_VERSION).tar.xz
SDK_CCACHE_LICENSE = GPLv3+, others
SDK_CCACHE_LICENSE_FILES = LICENSE.txt GPL-3.0.txt

$(eval $(autotools-package))
