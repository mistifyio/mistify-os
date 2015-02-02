################################################################################
#
# libcontainer
#
################################################################################

LIBCONTAINER_VERSION = e59984353acde7207aa1115e261847bf4ddd9a8f
LIBCONTAINER_SITE    = git@github.com:docker/libcontainer.git
LIBCONTAINER_SITE_METHOD = git
LIBCONTAINER_LICENSE = Apache
LIBCONTAINER_LICENSE_FILES = LICENSE

GOPATH=$(O)/tmp/GOPATH

define LIBCONTAINER_BUILD_CMDS
	# GO apparently wants the install path to be independent of the
	# build path. Use a temporary directory to do the build.
	mkdir -p $(GOPATH)/src/github.com/docker/libcontainer
	rsync -av --exclude .git $(@D)/* $(GOPATH)/src/github.com/docker/libcontainer/

	# Fetch and install Go coverage tool in $(GOPATH)
	GOROOT=$(GOROOT) \
	PATH=$(GOROOT)/bin:$(PATH) \
	GOPATH=$(GOPATH) \
	go get golang.org/x/tools/cmd/cover

	# Fetch and install Docker term package
	GOROOT=$(GOROOT) \
	PATH=$(GOROOT)/bin:$(PATH) \
	GOPATH=$(GOPATH):$(GOPATH)/src/github.com/docker/libcontainer/vendor \
	go get github.com/docker/docker/pkg/term

	cd $(GOPATH)/src/github.com/docker/libcontainer && \
	GOROOT=$(GOROOT) \
	PATH=$(GOROOT)/bin:$(PATH) \
	GOPATH=$(GOPATH):$(GOPATH)/src/github.com/docker/libcontainer/vendor \
	GOROOT=$(GOROOT) \
	go get -d -v ./...

	GOROOT=$(GOROOT) \
	PATH=$(GOROOT)/bin:$(PATH) \
	GOPATH=$(GOPATH):$(GOPATH)/src/github.com/docker/libcontainer/vendor \
	make direct-build \
	 -C $(GOPATH)/src/github.com/docker/libcontainer
endef

define LIBCONTAINER_INSTALL_CMDS
	GOROOT=$(GOROOT) \
	PATH=$(GOROOT)/bin:$(PATH) \
	GOPATH=$(GOPATH):$(GOPATH)/src/github.com/docker/libcontainer/vendor \
	make direct-install \
	 -C $(GOPATH)/src/github.com/docker/libcontainer
endef

$(eval $(generic-package))
