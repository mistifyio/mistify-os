################################################################################
#
# mistify-agent-libvirt
#
################################################################################

MISTIFY_AGENT_LIBVIRT_VERSION = 186e47cfba2b2d4777bae61a22fb9746220efa10
MISTIFY_AGENT_LIBVIRT_SITE    = git@github.com:mistifyio/mistify-agent-libvirt.git
MISTIFY_AGENT_LIBVIRT_SITE_METHOD = git
MISTIFY_AGENT_LIBVIRT_LICENSE = Apache
MISTIFY_AGENT_LIBVIRT_LICENSE_FILES = LICENSE
MISTIFY_AGENT_LIBVIRT_DEPENDENCIES = host-libvirt mistify-agent

GOPATH=$(O)/tmp/GOPATH

define MISTIFY_AGENT_LIBVIRT_BUILD_CMDS
	# GO apparently wants the install path to be independent of the
	# build path. Use a temporary directory to do the build.
	mkdir -p $(GOPATH)/src/github.com/mistifyio/mistify-agent-libvirt
	rsync -av --exclude .git $(@D)/* $(GOPATH)/src/github.com/mistifyio/mistify-agent-libvirt/
	GOROOT=$(GOROOT) \
	PATH=$(GOROOT)/bin:$(PATH) \
	CGO_CPPFLAGS=-I$(HOST_DIR)/usr/include \
	CGO_LDFLAGS="-L$(TARGET_DIR)/lib -L$(TARGET_DIR)/usr/lib -lsystemd" \
	GOPATH=$(GOPATH) make install DESTDIR=$(TARGET_DIR) \
	 -C $(GOPATH)/src/github.com/mistifyio/mistify-agent-libvirt
	mv $(TARGET_DIR)/opt/mistify/sbin/mistify-libvirt  $(TARGET_DIR)/opt/mistify/sbin/mistify-agent-libvirt
endef

define MISTIFY_AGENT_LIBVIRT_INSTALL_CMDS
	# The install was done as part of the build.
endef

define MISTIFY_AGENT_LIBVIRT_INSTALL_INIT_SYSTEMD
	$(INSTALL) -m 644 -D $(BR2_EXTERNAL)/package/mistify/mistify-agent-libvirt/mistify-agent-libvirt.service \
		$(TARGET_DIR)/etc/systemd/system/mistify-agent-libvirt.service

	$(INSTALL) -m 644 -D $(BR2_EXTERNAL)/package/mistify/mistify-agent-libvirt/mistify-agent-libvirt.sysconfig \
		$(TARGET_DIR)/etc/sysconfig/mistify-agent-libvirt

	ln -sf ../mistify-agent-libvirt.service \
		$(TARGET_DIR)/etc/systemd/system/multi-user.target.wants/mistify-agent-libvirt.service
endef

$(eval $(generic-package))

