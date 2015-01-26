################################################################################
#
# confd
#
################################################################################

CONFD_VERSION = v0.7.1
CONFD_SITE    = https://github.com/kelseyhightower/confd.git
CONFD_SITE_METHOD = git
CONFD_LICENSE_FILES = LICENSE

GOPATH=$(O)/tmp/GOPATH

define CONFD_BUILD_CMDS
	(cd $(CONFD_DIR) && \
		export PATH=$(GOROOT)/bin:$(PATH) && \
		export GOROOT=$(GOROOT) && \
		export GOPATH=$(GOPATH) && \
		go get github.com/kelseyhightower/confd && \
		go build -x) 
endef

define CONFD_INSTALL_TARGET_CMDS
	$(INSTALL) -m 755 -D $(CONFD_DIR)/confd-$(CONFD_VERSION) \
		$(TARGET_DIR)/usr/sbin/confd
endef

$(eval $(generic-package))

