################################################################################
#
# hyajl
#
################################################################################

HYAJL_VERSION = $(YAJL_VERSION)
HYAJL_SITE = $(call github,lloyd,yajl,$(HYAJL_VERSION))
#HYAJL_INSTALL_STAGING = YES
HYAJL_LICENSE = ISC
HYAJL_LICENSE_FILES = COPYING

HOST_HYAJL_CONF_OPT += -DBUILD_SHARED_LIBS=ON 

$(eval $(host-cmake-package))
