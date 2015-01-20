################################################################################
#
# mistify-etcd
#
################################################################################

MISTIFY_ETCD_VERSION = v2.0.0-rc.1
MISTIFY_ETCD_SITE    = https://github.com/coreos/etcd.git
MISTIFY_ETCD_SITE_METHOD = git
MISTIFY_ETCD_LICENSE = Apache
MISTIFY_ETCD_LICENSE_FILES = LICENSE

GOPATH=$(O)/tmp/GOPATH

define MISTIFY_ETCD_BUILD_CMDS
	# GO apparently wants the install path to be independent of the
	# build path. Use a temporary directory to do the build.
	GOROOT=$(GOROOT) \
	PATH=$(GOROOT)/bin:$(PATH)
        (cd $(MISTIFY_ETCD_DIR) && \
		GOROOT=$(GOROOT) \
		GOPATH=$(GOPATH) \
		PATH=$(GOROOT)/bin:$(PATH) \
		./build)
endef

define MISTIFY_ETCD_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/etc/etcd
	$(INSTALL) -m 755 -D $(MISTIFY_ETCD_DIR)/bin/etcd \
		$(TARGET_DIR)/usr/sbin/etcd
	$(INSTALL) -m 755 -D $(MISTIFY_ETCD_DIR)/bin/etcdctl \
		$(TARGET_DIR)/usr/bin/etcdctl
	$(INSTALL) -m 755 -D $(MISTIFY_ETCD_DIR)/bin/etcd-migrate \
		$(TARGET_DIR)/usr/bin/etcd-migrate
endef

define MISTIFY_ETCD_USERS
	etcd 500 etcd 500 * - - - etcd daemon
endef

define MISTIFY_ETCD_INSTALL_INIT_SYSTEMD
	$(INSTALL) -m 644 -D $(BR2_EXTERNAL)/package/mistify/mistify-etcd/etcd.service \
		$(TARGET_DIR)/etc/systemd/system/etcd.service

	$(INSTALL) -m 644 -D $(BR2_EXTERNAL)/package/mistify/mistify-etcd/etcd.sysconfig \
		$(TARGET_DIR)/etc/sysconfig/etcd

	ln -sf ../etcd.service \
		$(TARGET_DIR)/etc/systemd/system/multi-user.target.wants/etcd.service

endef

$(eval $(generic-package))

