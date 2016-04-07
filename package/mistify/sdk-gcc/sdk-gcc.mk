#############################################################
#
# gcc
#
#############################################################

SDK_GCC_VERSION = 5.3.0
SDK_GCC_SITE = $(BR2_GNU_MIRROR)/gcc/releases/gcc-$(SDK_GCC_VERSION)
SDK_GCC_SOURCE = gcc-$(SDK_GCC_VERSION).tar.bz2
SDK_GCC_LICENSE = GPLv3+
SDK_GCC_LICENSE_FILES = COPYING
# SDK_GCC_INSTALL_STAGING = YES

define SDK_GCC_BUILD_CMDS
        cd $(@D) && \
	./contrib/download_prerequisites && \
	mkdir ../sdk-gcc-build && \
	cd ../sdk-gcc-build && \
	$(@D)/configure \
	--prefix=/usr \
	--enable-shared \
	--enable-threads=posix \
	--enable-__cxa_atexit \
	--enable-clocale=gnu \
	--enable-languages=c,c++ \
	--with-gxx-include-dir=/usr/include/c++/$(SDK_GCC_VERSION) && \
	make CC="$(TARGET_CC)" LD="$(TARGET_LD)"
endef


define SDK_GCC_INSTALL_STAGING_CMDS
	cd $(@D)/../sdk-gcc-build && \
	make DESTDIR=$(STAGING_DIR) install
endef



define SDK_GCC_INSTALL_TARGET_CMDS
	cd $(@D)/../sdk-gcc-build && \
	make DESTDIR=$(TARGET_DIR) install
	#  HACK ALERT
	# Buildroot removes the include files from the target directory before
	# creating the target file system and the gcc build for some reason
	# produces a link error when attempting to install to both the staging
	# and target directories. So, to work around install to the target and
	# then copy the header files to staging. These are then copied back
	# out of staging in the post build script. This way the link problem
	# can be solved later.
	cp -r $(TARGET_DIR)/usr/include/c++ $(STAGING_DIR)/usr/include
endef


$(eval $(generic-package))
