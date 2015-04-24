################################################################################
#
# lochness
#
################################################################################

LOCHNESS_VERSION = 20150424
LOCHNESS_SITE    = git@github.com:mistifyio/lochness.git
LOCHNESS_SITE_METHOD = git
LOCHNESS_LICENSE = Apache
LOCHNESS_LICENSE_FILES = LICENSE
# NOTE: Need to add a dependency for etcd.
LOCHNESS_DEPENDENCIES = mistify-agent

GOPATH=$(O)/tmp/GOPATH

define LOCHNESS_BUILD_CMDS
	# GO apparently wants the install path to be independent of the
	# build path. Use a temporary directory to do the build.
	mkdir -p $(GOPATH)/src/github.com/mistifyio/lochness
	rsync -av --delete-after --exclude=.git --exclude-from=$(@D)/.gitignore \
		$(@D)/ $(GOPATH)/src/github.com/mistifyio/lochness/
	GOROOT=$(GOROOT) \
	PATH=$(GOROOT)/bin:$(PATH) \
        GOPATH=$(GOPATH) make \
           install DESTDIR=$(TARGET_DIR) \
          -C $(GOPATH)/src/github.com/mistifyio/lochness

endef

define LOCHNESS_INSTALL_TARGET_CMDS
	$(INSTALL) -m 644 -D $(BR2_EXTERNAL)/package/mistify/lochness/kappa.service \
		$(TARGET_DIR)/lib/systemd/system/kappa.service

	ln -sf ../kappa.service \
		$(TARGET_DIR)/lib/systemd/system/multi-user.target.wants/kappa.service
endef


$(eval $(generic-package))

