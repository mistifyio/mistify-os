################################################################################
#
# libcontainer
#
################################################################################

LIBCONTAINER_VERSION = a4a648ce3016ad7a5d0bb40359ec2ca81aa7640c
LIBCONTAINER_SITE    = https://github.com/docker/libcontainer.git
LIBCONTAINER_SITE_METHOD = git
LIBCONTAINER_LICENSE = Apache
LIBCONTAINER_LICENSE_FILES = LICENSE

GOPATH = $(O)/tmp/GOPATH
LIBCONTAINER_GOSRC = $(GOPATH)/src/github.com/docker/libcontainer

define LIBCONTAINER_BUILD_CMDS
	mkdir -p $(LIBCONTAINER_GOSRC)
	rsync -av --delete-after --exclude=.git --exclude-from=$(@D)/.gitignore \
		$(@D)/ $(LIBCONTAINER_GOSRC)/

	# Need Docker term package, can't rely on $(DOCKER_DOCKER_GOSRC)
	mkdir -p $(LIBCONTAINER_GOSRC)/vendor/src/github.com/docker
	rm -rf $(LIBCONTAINER_GOSRC)/vendor/src/github.com/docker/docker \
		&& git clone https://github.com/docker/docker.git \
			$(LIBCONTAINER_GOSRC)/vendor/src/github.com/docker/docker \
		&& (cd $(LIBCONTAINER_GOSRC)/vendor/src/github.com/docker/docker \
			&& git checkout -q $(DOCKER_DOCKER_VERSION))

	# Build and install term package
	GOPATH=$(GOPATH):$(LIBCONTAINER_GOSRC)/vendor \
	GOROOT=$(GOROOT) \
	PATH=$(GOROOT)/bin:$(PATH) \
	go install -v github.com/docker/docker/pkg/term

	GOROOT=$(GOROOT) \
	PATH=$(GOROOT)/bin:$(PATH) \
	GOPATH=$(GOPATH):$(LIBCONTAINER_GOSRC)/vendor \
	make direct-build \
		-C $(LIBCONTAINER_GOSRC)

	GOROOT=$(GOROOT) \
	PATH=$(GOROOT)/bin:$(PATH) \
	GOPATH=$(GOPATH):$(LIBCONTAINER_GOSRC)/vendor \
	make direct-install \
		-C $(LIBCONTAINER_GOSRC)
endef

define LIBCONTAINER_INSTALL_STAGING_CMDS
	# when GOPATH moves to staging
endef

define LIBCONTAINER_INSTALL_TARGET_CMDS
	$(INSTALL) -m 755 -D $(GOPATH)/bin/nsinit \
		$(TARGET_DIR)/usr/bin/nsinit
endef

$(eval $(generic-package))
