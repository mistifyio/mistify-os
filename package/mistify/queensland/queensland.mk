################################################################################
#
# queensland
#
################################################################################

QUEENSLAND_VERSION = master
QUEENSLAND_SITE    = https://github.com/mistifyio/queensland.git
QUEENSLAND_SITE_METHOD = git
QUEENSLAND_LICENSE = Apache
QUEENSLAND_LICENSE_FILES = LICENSE

GOPATH=$(O)/tmp/GOPATH

define QUEENSLAND_BUILD_CMDS
	(cd $(QUEENSLAND_DIR) && \
		export PATH=$(GOROOT)/bin:$(PATH) && \
		export GOROOT=$(GOROOT) && \
		export GOPATH=$(GOPATH) && \
		go get github.com/mistifyio/queensland && \
		go build -x) 
endef

define QUEENSLAND_INSTALL_TARGET_CMDS
	$(INSTALL) -m 755 -D $(QUEENSLAND_DIR)/queensland-$(QUEENSLAND_VERSION) \
		$(TARGET_DIR)/usr/sbin/queensland
endef

$(eval $(generic-package))

