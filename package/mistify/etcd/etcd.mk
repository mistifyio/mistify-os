################################################################################
#
# etcd
#
################################################################################

ETCD_VERSION = v2.0.4
ETCD_SITE    = https://github.com/coreos/etcd/archive/
ETCD_SOURCE = $(ETCD_VERSION).tar.gz
ETCD_LICENSE = Apache
ETCD_LICENSE_FILES = LICENSE

GOPATH=$(O)/tmp/GOPATH

define ETCD_BUILD_CMDS
        (cd $(ETCD_DIR) && \
		CGO_ENABLED=0 \
		GOROOT=$(GOROOT) \
		GOPATH=$(GOPATH) \
		PATH=$(GOROOT)/bin:$(PATH) \
		./build)
endef

define ETCD_INSTALL_TARGET_CMDS
	$(INSTALL) -m 755 -D $(ETCD_DIR)/bin/etcd \
		$(TARGET_DIR)/usr/sbin/etcd
	$(INSTALL) -m 755 -D $(ETCD_DIR)/bin/etcdctl \
		$(TARGET_DIR)/usr/bin/etcdctl
	$(INSTALL) -m 755 -D $(ETCD_DIR)/bin/etcd-migrate \
		$(TARGET_DIR)/usr/bin/etcd-migrate
endef

define ETCD_USERS
	etcd 501 daemon -1 * - - - Etcd Daemon
endef

define ETCD_INSTALL_INIT_SYSTEMD
	$(INSTALL) -m 644 -D $(BR2_EXTERNAL)/package/mistify/etcd/etcd.service \
		$(TARGET_DIR)/lib/systemd/system/etcd.service

	$(INSTALL) -m 644 -D $(BR2_EXTERNAL)/package/mistify/etcd/etcd.sysconfig \
		$(TARGET_DIR)/etc/sysconfig/etcd

	ln -sf ../etcd.service \
		$(TARGET_DIR)/lib/systemd/system/multi-user.target.wants/etcd.service

endef

$(eval $(generic-package))

