#############################################################
#
# gcc
#
#############################################################

SDK_GCC_VERSION = 4.9.2
SDK_GCC_SITE = http://www.netgull.com/gcc/releases/gcc-$(SDK_GCC_VERSION)
SDK_GCC_SOURCE = gcc-$(SDK_GCC_VERSION).tar.bz2
SDK_GCC_LICENSE = GPLv3+
SDK_GCC_LICENSE_FILES = COPYING

define SDK_GCC_BUILD_CMDS
        cd $(@D) && \
	./contrib/download_prerequisites && \
	mkdir ../sdk-gcc-build && \
	cd ../sdk-gcc-build && \
	$(@D)/configure \
	--prefix=$(TARGET_DIR)/usr \
	--enable-shared \
	--enable-threads=posix \
	--enable-__cxa_atexit \
	--enable-clocale=gnu \
	--enable-languages=c,c++,go,objc,obj-c++,fortran \
	--disable-multilib  && \
	make CC="$(TARGET_CC)" LD="$(TARGET_LD)"
endef

$(eval $(generic-package))
