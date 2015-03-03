################################################################################
#
# lochness
#
################################################################################

LOCHNESS_VERSION = 5eb2d96b359092151293227f45ecaf21572a1d3f
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
	rsync -av --exclude .git $(@D)/* $(GOPATH)/src/github.com/mistifyio/lochness/
	GOROOT=$(GOROOT) \
	PATH=$(GOROOT)/bin:$(PATH) \
        GOPATH=$(GOPATH) make \
           install DESTDIR=$(TARGET_DIR) \
          -C $(GOPATH)/src/github.com/mistifyio/lochness

endef

define LOCHNESS_INSTALL_CMDS
	# The install was done as part of the build.
endef


$(eval $(generic-package))

