#############################################################
#
# m4
#
#############################################################

SDK_M4_VERSION = 1.4.16
SDK_M4_SOURCE = m4-$(SDK_M4_VERSION).tar.bz2
SDK_M4_SITE = $(BR2_GNU_MIRROR)/m4
SDK_M4_LICENSE = GPLv3+
SDK_M4_LICENSE_FILES = COPYING
SDK_M4_CONF_ENV = gl_cv_func_gettimeofday_clobber=no

ifneq ($(BR2_USE_WCHAR),y)
SDK_M4_CONF_ENV += gt_cv_c_wchar_t=no gl_cv_absolute_wchar_h=__fpending.h
endif

$(eval $(autotools-package))
