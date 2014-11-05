################################################################################
#
# mistify-agent
#
################################################################################

MISTIFY_AGENT_VERSION = master
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
endef

define MISTIFY_AGENT_INSTALL_CMDS
	# The install was done as part of the build.
endef

$(eval $(generic-package))

