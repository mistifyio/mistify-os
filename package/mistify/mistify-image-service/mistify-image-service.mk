################################################################################
#
# mistify-image-service
#
################################################################################

MISTIFY_IMAGE_SERVICE_VERSION = 42f9e5727f6a6f3d03a1119bd74cb242059ed63c
MISTIFY_IMAGE_SERVICE_SITE    = https://github.com/mistifyio/mistify-image-service.git
MISTIFY_IMAGE_SERVICE_SITE_METHOD = git
MISTIFY_IMAGE_SERVICE_LICENSE = Apache
MISTIFY_IMAGE_SERVICE_LICENSE_FILES = LICENSE

GOPATH=$(O)/tmp/GOPATH

define MISTIFY_IMAGE_SERVICE_BUILD_CMDS
	# GO apparently wants the install path to be independent of the
	# build path. Use a temporary directory to do the build.
	mkdir -p $(GOPATH)/src/github.com/mistifyio/mistify-image-service
	rsync -av --delete-after --exclude=.git --exclude-from=$(@D)/.gitignore \
		$(@D)/ $(GOPATH)/src/github.com/mistifyio/mistify-image-service/
	GOROOT=$(GOROOT) \
	PATH=$(GOROOT)/bin:$(PATH) \
	GOPATH=$(GOPATH) make install DESTDIR=$(TARGET_DIR) \
		-C $(GOPATH)/src/github.com/mistifyio/mistify-image-service
endef

define MISTIFY_IMAGE_SERVICE_INSTALL_TARGET_CMDS
    # The install was done as part of the build.
endef

$(eval $(generic-package))
