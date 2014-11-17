################################################################################
#
# mistify-agent
#
################################################################################

MISTIFY_AGENT_VERSION = 925caf45a50ffbd71630b3091685c7baa2a14f56
MISTIFY_AGENT_SITE    = https://github.com/mistifyio/mistify-agent.git
MISTIFY_AGENT_SITE_METHOD = git
MISTIFY_AGENT_LICENSE = Apache
MISTIFY_AGENT_LICENSE_FILES = LICENSE

GOPATH=$(O)/tmp/mistify-agent-GOPATH

define MISTIFY_AGENT_BUILD_CMDS
	# GO apparently wants the install path to be independent of the
	# build path. Use a temporary directory to do the build.
	mkdir -p $(GOPATH)/src/github.com/mistifyio/mistify-agent
	rsync -av --exclude .git $(@D)/* $(GOPATH)/src/github.com/mistifyio/mistify-agent/
	GOROOT=$(GOROOT) \
	PATH=$(PATH):$(GOROOT)/bin \
        GOPATH=$(GOPATH) make install DESTDIR=$(TARGET_DIR) \
          -C $(GOPATH)/src/github.com/mistifyio/mistify-agent
    $(INSTALL) -m 755 -D $(BR2_EXTERNAL)/package/mistify/mistify-agent/run \
	    $(TARGET_DIR)/etc/sv/mistify-agent/run
	$(INSTALL) -m 755 -D $(BR2_EXTERNAL)/package/mistify/mistify-agent/log.run \
	    $(TARGET_DIR)/etc/sv/mistify-agent/log/run
	mkdir -p $(TARGET_DIR)/etc/service
    cd $(TARGET_DIR)/etc/service && ln -sf ../sv/mistify-agent .
	$(INSTALL) -m 644 -D $(BR2_EXTERNAL)/package/mistify/mistify-agent/agent.json \
	    $(TARGET_DIR)/etc/mistify/agent.json

endef

define MISTIFY_AGENT_INSTALL_CMDS
	# The install was done as part of the build.
endef

$(eval $(generic-package))

