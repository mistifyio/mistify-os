################################################################################
#
# queensland
#
################################################################################

QUEENSLAND_VERSION = v0.2.0
QUEENSLAND_SITE    = https://github.com/mistifyio/queensland/archive/
QUEENSLAND_SOURCE = $(QUEENSLAND_VERSION).tar.gz
QUEENSLAND_LICENSE = Apache
QUEENSLAND_LICENSE_FILES = LICENSE

GOPATH=$(O)/tmp/GOPATH

define QUEENSLAND_BUILD_CMDS
	(mkdir -p $(GOPATH)/src/github.com/mistifyio && \
		ln -sf $(QUEENSLAND_DIR) $(GOPATH)/src/github.com/mistifyio/queensland && \
		export PATH=$(GOROOT)/bin:$(PATH) && \
		export GOROOT=$(GOROOT) && \
		export GOPATH=$(GOPATH) && \
		cd  $(GOPATH)/src/github.com/mistifyio/queensland && \
		go get -d && \
		go build -x -o $(QUEENSLAND_DIR)/queensland)
endef

define QUEENSLAND_INSTALL_TARGET_CMDS
	$(INSTALL) -m 755 -D $(QUEENSLAND_DIR)/queensland \
		$(TARGET_DIR)/usr/sbin/queensland
endef

$(eval $(generic-package))

