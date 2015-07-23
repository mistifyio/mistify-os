################################################################################
#
# mistify-agent-ovs
#
################################################################################

MISTIFY_AGENT_OVS_VERSION = b557cc81ae2f4c020179878352d404dd8fb65e60
MISTIFY_AGENT_OVS_SITE    = git@github.com:mistifyio/mistify-agent-ovs.git
MISTIFY_AGENT_OVS_SITE_METHOD = git
MISTIFY_AGENT_OVS_LICENSE = Apache
MISTIFY_AGENT_OVS_LICENSE_FILES = LICENSE
MISTIFY_AGENT_OVS_DEPENDENCIES = mistify-agent

GOPATH=$(O)/tmp/GOPATH

define MISTIFY_AGENT_OVS_BUILD_CMDS
	# GO apparently wants the install path to be independent of the
	# build path. Use a temporary directory to do the build.
	mkdir -p $(GOPATH)/src/github.com/mistifyio/mistify-agent-ovs
	rsync -av --delete-after --exclude=.git --exclude-from=$(@D)/.gitignore \
		$(@D)/ $(GOPATH)/src/github.com/mistifyio/mistify-agent-ovs/
	GOROOT=$(GOROOT) \
	PATH=$(GOROOT)/bin:$(PATH) \
	GOPATH=$(GOPATH) make install DESTDIR=$(TARGET_DIR) \
		-C $(GOPATH)/src/github.com/mistifyio/mistify-agent-ovs
endef

define MISTIFY_AGENT_OVS_INSTALL_TARGET_CMDS
	# The install was done as part of the build.
endef

define MISTIFY_AGENT_OVS_INSTALL_INIT_SYSTEMD
	$(INSTALL) -m 644 -D $(BR2_EXTERNAL)/package/mistify/mistify-agent-ovs/mistify-agent-ovs.service \
		$(TARGET_DIR)/lib/systemd/system/mistify-agent-ovs.service

	$(INSTALL) -m 644 -D $(BR2_EXTERNAL)/package/mistify/mistify-agent-ovs/mistify-agent-ovs.sysconfig \
		$(TARGET_DIR)/etc/sysconfig/mistify-agent-ovs
endef

$(eval $(generic-package))
