################################################################################
#
# go
#
################################################################################

HOST_GO_VERSION = 1.3.3
HOST_GO_SOURCE  = go$(HOST_GO_VERSION).linux-amd64.tar.gz
HOST_GO_SITE    = https://storage.googleapis.com/golang
HOST_GO_LICENSE = BSD
HOST_GO_LICENSE_FILES = LICENSE

define HOST_GO_BUILD_CMDS
	@echo "Not compiled for the target. Using amd64 prebuilt binaries."
endef

define HOST_GO_INSTALL_CMDS
	# GO uses a non-traditional install method which is basically an un-tar
	# of the package into the /usr... directory. This simply copies the
	# relevant files to the recommended location.
	# NOTE: GO based packages will need to set paths and environment
	# variables accordingly.
	mkdir -p $(HOST_DIR)/usr/local
	cp -dr --preserve=mode,timestamp $(@D) $(HOST_DIR)/usr/local/go
	
endef

$(eval $(host-generic-package))

GOROOT = $(HOST_DIR)/usr/local/go
