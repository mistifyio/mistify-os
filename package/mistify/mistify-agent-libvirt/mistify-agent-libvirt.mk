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
	    CGO_LDFLAGS=-L$(TARGET_DIR)/usr/lib \
        GOPATH=$(GOPATH) make install DESTDIR=$(TARGET_DIR) \
          -C $(GOPATH)/src/github.com/mistifyio/mistify-agent-libvirt
	mv $(TARGET_DIR)/opt/mistify/sbin/mistify-libvirt  $(TARGET_DIR)/opt/mistify/sbin/mistify-agent-libvirt
    $(INSTALL) -m 755 -D $(BR2_EXTERNAL)/package/mistify/mistify-agent-libvirt/run \
	    $(TARGET_DIR)/etc/sv/mistify-agent-libvirt/run
	$(INSTALL) -m 755 -D $(BR2_EXTERNAL)/package/mistify/mistify-agent-libvirt/log.run \
	    $(TARGET_DIR)/etc/sv/mistify-agent-libvirt/log/run
	mkdir -p $(TARGET_DIR)/etc/service
    cd $(TARGET_DIR)/etc/service && ln -sf ../sv/mistify-agent-libvirt .

endef

define MISTIFY_AGENT_LIBVIRT_INSTALL_CMDS
	# The install was done as part of the build.
endef

$(eval $(generic-package))

