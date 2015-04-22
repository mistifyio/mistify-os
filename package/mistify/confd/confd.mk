################################################################################
#
# confd
#
################################################################################

CONFD_VERSION = v0.7.1
CONFD_SITE    = https://github.com/kelseyhightower/confd.git
CONFD_SITE_METHOD = git
CONFD_LICENSE_FILES = LICENSE
CONFD_DEPENDENCIES += etcd

GOPATH = $(O)/tmp/GOPATH
CONFD_GOSRC = $(GOPATH)/src/github.com/kelseyhightower/confd

define CONFD_BUILD_CMDS
	# GO apparently wants the install path to be independent of the
	# build path. Use a temporary directory to do the build.
	mkdir -p $(CONFD_GOSRC)
	rsync -av --delete-after --exclude=.git --exclude-from=$(@D)/.gitignore \
		$(@D)/ $(CONFD_GOSRC)/

	cd $(CONFD_GOSRC) && \
		GOROOT=$(GOROOT) \
		PATH=$(GOROOT)/bin:$(PATH) \
		GOPATH=$(GOPATH) \
		go get -v ./...

	cd $(CONFD_GOSRC) && \
		GOROOT=$(GOROOT) \
		PATH=$(GOROOT)/bin:$(PATH) \
		GOPATH=$(GOPATH) \
		go build -x
endef

define CONFD_INSTALL_TARGET_CMDS
	$(INSTALL) -m 755 -D $(CONFD_GOSRC)/confd \
		$(TARGET_DIR)/usr/sbin/confd
endef

$(eval $(generic-package))

