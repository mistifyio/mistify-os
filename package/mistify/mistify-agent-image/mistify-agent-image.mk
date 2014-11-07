################################################################################
#
# mistify-agent-image
#
################################################################################

MISTIFY_AGENT_IMAGE_VERSION = master
MISTIFY_AGENT_IMAGE_SITE    = git@github.com:mistifyio/mistify-agent-image.git
MISTIFY_AGENT_IMAGE_SITE_METHOD = git
MISTIFY_AGENT_IMAGE_LICENSE = Apache
MISTIFY_AGENT_IMAGE_LICENSE_FILES = LICENSE

GOPATH=$(O)/tmp/mistify-agent-image-GOPATH

define MISTIFY_AGENT_IMAGE_BUILD_CMDS
	# GO apparently wants the install path to be independent of the
	# build path. Use a temporary directory to do the build.
	mkdir -p $(GOPATH)/src/github.com/mistifyio/mistify-agent-image
	rsync -av --exclude .git $(@D)/* $(GOPATH)/src/github.com/mistifyio/mistify-agent-image/
	GOROOT=$(GOROOT) \
	PATH=$(PATH):$(GOROOT)/bin \
        GOPATH=$(GOPATH) make install DESTDIR=$(TARGET_DIR) \
          -C $(GOPATH)/src/github.com/mistifyio/mistify-agent-image
    $(INSTALL) -m 755 -D $(BR2_EXTERNAL)/package/mistify/mistify-agent-image/run \
	    $(TARGET_DIR)/etc/sv/mistify-agent-image/run
	$(INSTALL) -m 755 -D $(BR2_EXTERNAL)/package/mistify/mistify-agent-image/log.run \
	    $(TARGET_DIR)/etc/sv/mistify-agent-image/log/run
	mkdir -p $(TARGET_DIR)/etc/service
    cd $(TARGET_DIR)/etc/service && ln -sf ../sv/mistify-agent-image .

endef

define MISTIFY_AGENT_IMAGE_INSTALL_CMDS
	# The install was done as part of the build.
endef

$(eval $(generic-package))

