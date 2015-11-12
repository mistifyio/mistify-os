################################################################################
#
# sdk-texinfo
#
################################################################################

# We are intentionally not using the latest version 5.x, because it
# causes issues with the documentation building process when creating
# a toolchain with the Crosstool-NG backend.

SDK_TEXINFO_VERSION = 4.13a
SDK_TEXINFO_SITE = $(BR2_GNU_MIRROR)/texinfo
SDK_TEXINFO_SOURCE = texinfo-$(SDK_TEXINFO_VERSION).tar.gz
SDK_TEXINFO_LICENSE = GPLv3+
SDK_TEXINFO_LICENSE_FILES = COPYING
SDK_TEXINFO_DEPENDENCIES = ncurses

define SDK_TEXINFO_BUILD_CMDS
	$(MAKE) CC="$(TARGET_CC)" \
		LD="$(TARGET_LD)" \
		RANLIB="$(TARGET_RANLIB)" \
		-C $(@D)/tools/gnulib/lib

	$(MAKE) CC="$(TARGET_CC)" \
		LD="$(TARGET_LD)" \
		RANLIB="$(TARGET_RANLIB)" \
		-C $(@D)
endef

$(eval $(autotools-package))
