################################################################################
#
# ipxe
#
################################################################################

IPXE_VERSION       = 6b7157c233541a4cb3c90021e8ca219b0b5dd358
IPXE_SITE          = git://git.ipxe.org/ipxe.git
IPXE_DEPENDENCIES  = host-xz host-lzma
IPXE_LICENSE       = GPLv2
IPXE_LICENSE_FILES = COPYING COPYING.GPLv2

define IPXE_BUILD_CMDS
	cp $(BR2_EXTERNAL)/package/mistify/ipxe/netboot.ipxe \
		$(@D)/src
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D)/src				\
		CROSS_COMPILE="$(TARGET_CROSS)"				\
		HOST_CC="$(HOSTCC)"					\
		HOST_CFLAGS="$(HOST_CFLAGS) $(HOST_LDFLAGS)"		\
		ISOLINUX_BIN="$(BINARIES_DIR)/syslinux/isolinux.bin"	\
		EMBED=netboot.ipxe V=1					\
		bin/undionly.kpxe
endef

define IPXE_INSTALL_TARGET_CMDS
	$(INSTALL) -m 644 -D $(@D)/src/bin/undionly.kpxe \
		$(TARGET_DIR)/var/lib/tftpd/undionly.kpxe
endef

$(eval $(generic-package))
