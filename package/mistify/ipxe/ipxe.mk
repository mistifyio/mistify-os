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
	export CPATH=$(TARGET_DIR)/usr/include && \
	export LIBRARY_PATH=$(TARGET_DIR)/usr/lib && \
	cp $(BR2_EXTERNAL)/package/mistify/ipxe/netboot.ipxe \
		$(IPXE_DIR)/src && \
	cd $(IPXE_DIR)/src && \
	$(MAKE) EMBED=netboot.ipxe
endef

define IPXE_INSTALL_TARGET_CMDS
	$(INSTALL) -m 644 -D $(IPXE_DIR)/src/bin/undionly.kpxe \
		$(TARGET_DIR)/var/lib/tftpd/undionly.kpxe
endef

$(eval $(generic-package))
