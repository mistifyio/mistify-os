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

define CONFD_USERS
	confd -1 demon -1 * - - - ConfD Daemon
endef

define CONFD_INSTALL_INIT_SYSTEMD
	$(INSTALL) -m 644 -D $(BR2_EXTERNAL)/package/mistify/confd/confd.service \
		$(TARGET_DIR)/lib/systemd/system/confd.service

	$(INSTALL) -m 755 -D $(BR2_EXTERNAL)/package/mistify/confd/confd-setup \
		$(TARGET_DIR)/usr/lib/systemd/scripts/confd-setup
	$(INSTALL) -m 644 -D $(BR2_EXTERNAL)/package/mistify/confd/confd-setup.service \
		$(TARGET_DIR)/lib/systemd/system/confd-setup.service


	$(INSTALL) -m 644 -D $(BR2_EXTERNAL)/package/mistify/confd/confd.sysconfig \
		$(TARGET_DIR)/etc/sysconfig/confd

	ln -sf ../confd-setup.service \
		$(TARGET_DIR)/lib/systemd/system/multi-user.target.wants/confd-setup.service

	ln -sf ../confd.service \
		$(TARGET_DIR)/lib/systemd/system/multi-user.target.wants/confd.service

endef

$(eval $(generic-package))

