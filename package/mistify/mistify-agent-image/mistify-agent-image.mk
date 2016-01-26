################################################################################
#
# mistify-agent-image
#
################################################################################

MISTIFY_AGENT_IMAGE_VERSION = ee2bfbdced4e991d3a9f295e2bd867a1337681be
MISTIFY_AGENT_IMAGE_SITE    = git@github.com:mistifyio/mistify-agent-image.git
MISTIFY_AGENT_IMAGE_SITE_METHOD = git
MISTIFY_AGENT_IMAGE_LICENSE = Apache
MISTIFY_AGENT_IMAGE_LICENSE_FILES = LICENSE
MISTIFY_AGENT_IMAGE_DEPENDENCIES = mistify-agent

GOPATH=$(O)/tmp/GOPATH

define MISTIFY_AGENT_IMAGE_BUILD_CMDS
	# GO apparently wants the install path to be independent of the
	# build path. Use a temporary directory to do the build.
	mkdir -p $(GOPATH)/src/github.com/mistifyio/mistify-agent-image
	rsync -av --delete-after --exclude=.git --exclude-from=$(@D)/.gitignore \
		$(@D)/ $(GOPATH)/src/github.com/mistifyio/mistify-agent-image/
	GOROOT=$(GOROOT) \
	PATH=$(GOROOT)/bin:$(PATH) \
        GOPATH=$(GOPATH) make install DESTDIR=$(TARGET_DIR) \
		-C $(GOPATH)/src/github.com/mistifyio/mistify-agent-image
endef

define MISTIFY_AGENT_IMAGE_INSTALL_TARGET_CMDS
	# The install was done as part of the build.
endef

define MISTIFY_AGENT_IMAGE_INSTALL_INIT_SYSTEMD
	$(INSTALL) -m 644 -D $(BR2_EXTERNAL)/package/mistify/mistify-agent-image/mistify-agent-image.service \
		$(TARGET_DIR)/lib/systemd/system/mistify-agent-image.service

	$(INSTALL) -m 644 -D $(BR2_EXTERNAL)/package/mistify/mistify-agent-image/mistify-agent-image.sysconfig \
		$(TARGET_DIR)/etc/sysconfig/mistify-agent-image
endef

$(eval $(generic-package))

