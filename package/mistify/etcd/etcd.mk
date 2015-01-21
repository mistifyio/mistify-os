################################################################################
#
# etcd
#
################################################################################

ETCD_VERSION = v2.0.0-rc.1
ETCD_SITE    = https://github.com/coreos/etcd.git
ETCD_SITE_METHOD = git
ETCD_LICENSE = Apache
ETCD_LICENSE_FILES = LICENSE

GOPATH=$(O)/tmp/GOPATH

define ETCD_BUILD_CMDS
	# GO apparently wants the install path to be independent of the
	# build path. Use a temporary directory to do the build.
	GOROOT=$(GOROOT) \
	PATH=$(GOROOT)/bin:$(PATH)
        (cd $(ETCD_DIR) && \
		GOROOT=$(GOROOT) \
		GOPATH=$(GOPATH) \
		PATH=$(GOROOT)/bin:$(PATH) \
		./build)
endef

define ETCD_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/etc/etcd
	$(INSTALL) -m 755 -D $(ETCD_DIR)/bin/etcd \
		$(TARGET_DIR)/usr/sbin/etcd
	$(INSTALL) -m 755 -D $(ETCD_DIR)/bin/etcdctl \
		$(TARGET_DIR)/usr/bin/etcdctl
	$(INSTALL) -m 755 -D $(ETCD_DIR)/bin/etcd-migrate \
		$(TARGET_DIR)/usr/bin/etcd-migrate
endef

define ETCD_USERS
	etcd 500 etcd 500 * - - - etcd daemon
endef

define ETCD_INSTALL_INIT_SYSTEMD
	$(INSTALL) -m 644 -D $(BR2_EXTERNAL)/package/mistify/etcd/etcd.service \
		$(TARGET_DIR)/etc/systemd/system/etcd.service

	$(INSTALL) -m 644 -D $(BR2_EXTERNAL)/package/mistify/etcd/etcd.sysconfig \
		$(TARGET_DIR)/etc/sysconfig/etcd

	ln -sf ../etcd.service \
		$(TARGET_DIR)/etc/systemd/system/multi-user.target.wants/etcd.service

endef

$(eval $(generic-package))

