################################################################################
#
# mistify-agent
#
################################################################################

MISTIFY_AGENT_VERSION = bda06d66c501188f77b7747d0d15604f58283de4
MISTIFY_AGENT_SITE    = https://github.com/mistifyio/mistify-agent.git
MISTIFY_AGENT_SITE_METHOD = git
MISTIFY_AGENT_LICENSE = Apache
MISTIFY_AGENT_LICENSE_FILES = LICENSE
MISTIFY_AGENT_DEPENDENCIES = systemd

GOPATH=$(O)/tmp/GOPATH

define MISTIFY_AGENT_BUILD_CMDS
	# GO apparently wants the install path to be independent of the
	# build path. Use a temporary directory to do the build.
	mkdir -p $(GOPATH)/src/github.com/mistifyio/mistify-agent
	rsync -av --exclude .git $(@D)/* $(GOPATH)/src/github.com/mistifyio/mistify-agent/
	GOROOT=$(GOROOT) \
	PATH=$(GOROOT)/bin:$(PATH) \
        GOPATH=$(GOPATH) make install DESTDIR=$(TARGET_DIR) \
          -C $(GOPATH)/src/github.com/mistifyio/mistify-agent

endef

define MISTIFY_AGENT_INSTALL_CMDS
	# The install was done as part of the build.
endef

define MISTIFY_AGENT_INSTALL_INIT_SYSTEMD
	$(INSTALL) -m 644 -D $(BR2_EXTERNAL)/package/mistify/mistify-agent/mistify-agent.service \
		$(TARGET_DIR)/etc/systemd/system/mistify-agent.service

	$(INSTALL) -m 644 -D $(BR2_EXTERNAL)/package/mistify/mistify-agent/mistify-agent.sysconfig \
		$(TARGET_DIR)/etc/sysconfig/mistify-agent

	ln -sf ../mistify-agent.service \
		$(TARGET_DIR)/etc/systemd/system/multi-user.target.wants/mistify-agent.service

endef

$(eval $(generic-package))

