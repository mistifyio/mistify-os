################################################################################
#
# spl
#
################################################################################

SPL_VERSION = master
SPL_SITE    = https://github.com/zfsonlinux/spl.git
SPL_SITE_METHOD = git
SPL_LICENSE = GPL v2
SPL_LICENSE_FILES = COPYING
SPL_INSTALL_STAGING = YES

SPL_DEPENDENCIES = linux

define SPL_INSTALL_SYSTEM_MAP                                                                                   
        # When the SPL build invokes depmod it needs a current System.map file.                                 
        # The SPL build assumes this file is in $(TARGET_DIR)/root. Buildroot                                   
        # doesn't install this file when building an initrd image.                                              
        if [[ "$(BR2_TARGET_ROOTFS_CPIO)" == "y" ]]; then \                                                     
          mkdir -p $(TARGET_DIR)/boot; \                                                                        
          cp $(LINUX_DIR)/System.map $(TARGET_DIR)/boot/System.map-$(LINUX_VERSION); \                          
        fi                                                                                                      
endef                                                                                                           
                                                                                                                
SPL_PRE_BUILD_HOOKS += SPL_INSTALL_SYSTEM_MAP

SPL_CONF_OPTS = \
    --prefix=/usr \
    --libdir=/lib \
    --with-linux=$(LINUX_DIR) \
    --with-linux-obj=$(LINUX_DIR)

SPL_AUTORECONF = YES
SPL_AUTORECONF_OPTS = -fiv

SPL_MAKE = $(MAKE1)

$(eval $(autotools-package))
