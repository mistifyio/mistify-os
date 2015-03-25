################################################################################
#
# docker
#
################################################################################

DOCKER_DOCKER_VERSION = ac2521b87cfb9670bd3bfbf1a1ef8d8075e63737
DOCKER_DOCKER_SITE    = git@github.com:docker/docker.git
DOCKER_DOCKER_SITE_METHOD = git
DOCKER_DOCKER_LICENSE = Apache
DOCKER_DOCKER_LICENSE_FILES = LICENSE
DOCKER_DOCKER_DEPENDENCIES = libcontainer sqlite zfs

GOPATH = $(O)/tmp/GOPATH

# Fixed cset IDs (TODO: extract from Dockerfile)
REGISTRY_COMMIT  = c448e0416925a9876d5576e412703c9b8b865e19
DOCKER_PY_COMMIT = d39da1167975aaeb6c423b99621ecda1223477b8
TOMLV_COMMIT     = 9baf8a8a9f2ed20a8e54160840c492f937eeaf9a

# See values in project/PACKAGERS.md
DOCKER_BUILDTAGS =
#DOCKER_BUILDTAGS += apparmor
#DOCKER_BUILDTAGS += selinux
DOCKER_BUILDTAGS += btrfs_noversion
DOCKER_BUILDTAGS += exclude_graphdriver_btrfs
DOCKER_BUILDTAGS += exclude_graphdriver_devicemapper
#DOCKER_BUILDTAGS += exclude_graphdriver_aufs


define DOCKER_DOCKER_BUILD_CMDS
	rm -rf $(GOPATH)/src/github.com/docker/docker

	# Grab go-zfs
	GOPATH=$(@D)/vendor \
	GOROOT=$(GOROOT) \
	PATH=$(GOROOT)/bin:$(PATH) \
		go get gopkg.in/mistifyio/go-zfs.v2

	# Grab Go's cover tool for dead-simple code coverage testing
	GOPATH=$(@D)/vendor \
	GOROOT=$(GOROOT) \
	PATH=$(GOROOT)/bin:$(PATH) \
	go get golang.org/x/tools/cmd/cover

	# Install registry
	rm -rf $(GOPATH)/src/github.com/docker/distribution \
		&& git clone https://github.com/docker/distribution.git \
			$(GOPATH)/src/github.com/docker/distribution \
		&& (cd $(GOPATH)/src/github.com/docker/distribution \
			&& git checkout -q $(REGISTRY_COMMIT)) \
		&& GOPATH=$(GOPATH)/src/github.com/docker/distribution/Godeps/_workspace:$(GOPATH) \
		GOROOT=$(GOROOT) \
		PATH=$(GOROOT)/bin:$(PATH) \
		go build -o $(GOPATH)/bin/registry-v2 \
			github.com/docker/distribution/cmd/registry

	# Get the "docker-py" source so we can run their integration tests
	rm -rf $(@D)/docker-py \
		&& git clone https://github.com/docker/docker-py.git $(@D)/docker-py \
		&& (cd $(@D)/docker-py \
			&& git checkout -q $(DOCKER_PY_COMMIT))

	# Install man page generator
	$(INSTALL) -m 755 -d $(GOPATH)/src/github.com/docker/docker/vendor && \
		rsync -av --exclude .git $(@D)/vendor/* \
			 $(GOPATH)/src/github.com/docker/docker/vendor/
	# go-md2man needs golang.org/x/net
	rm -rf $(GOPATH)/src/github.com/cpuguy83/go-md2man \
			$(GOPATH)/src/github.com/russross/blackfriday \
    	&& git clone -b v1.0.1 https://github.com/cpuguy83/go-md2man.git \
			$(GOPATH)/src/github.com/cpuguy83/go-md2man \
		&& git clone -b v1.2 https://github.com/russross/blackfriday.git \
		 	$(GOPATH)/src/github.com/russross/blackfriday \
		&& GOPATH=$(GOPATH)/src/github.com/docker/docker/vendor:$(GOPATH) \
		GOROOT=$(GOROOT) \
		PATH=$(GOROOT)/bin:$(PATH) \
		go install -v github.com/cpuguy83/go-md2man

	# install toml validator
	rm -rf $(GOPATH)/src/github.com/BurntSushi/toml \
		&& git clone https://github.com/BurntSushi/toml.git \
			 $(GOPATH)/src/github.com/BurntSushi/toml \
		&& (cd $(GOPATH)/src/github.com/BurntSushi/toml \
			&& git checkout -q $(TOMLV_COMMIT)) \
		&& GOPATH=$(GOPATH) \
		GOROOT=$(GOROOT) \
		PATH=$(GOROOT)/bin:$(PATH) \
		go install -v github.com/BurntSushi/toml/cmd/tomlv

	# Copy ourselves to $(GOPATH)
	$(INSTALL) -m 755 -d $(GOPATH)/src/github.com/docker/docker \
		&& rsync -av --exclude .git $(@D)/* $(GOPATH)/src/github.com/docker/docker/

	# Do the rest of the build
	cd $(GOPATH)/src/github.com/docker/docker \
		&& GOPATH=$(GOPATH)/src/github.com/docker/docker/vendor:$(GOPATH) \
		GOROOT=$(GOROOT) \
		PATH=$(GOROOT)/bin:$(PATH) \
		CGO_ENABLED=1 \
		CGO_CPPFLAGS="-I$(STAGING_DIR)/usr/include" \
		CGO_LDFLAGS="-L$(TARGET_DIR)/lib -L$(TARGET_DIR)/usr/lib -Wl,-rpath-link,$(TARGET_DIR)/lib -Wl,-rpath-link,$(TARGET_DIR)/usr/lib" \
		DOCKER_GITCOMMIT="$(DOCKER_DOCKER_VERSION)" \
		DOCKER_BUILDTAGS="$(DOCKER_BUILDTAGS)" \
		./hack/make.sh dynbinary
endef

define DOCKER_DOCKER_INSTALL_STAGING_CMDS
	# when GOPATH moves to staging
endef

define DOCKER_DOCKER_INSTALL_TARGET_CMDS
	read DOCKER_VERSION < $(@D)/VERSION \
		&& $(INSTALL) -m 755 -D \
			$(GOPATH)/src/github.com/docker/docker/bundles/$$DOCKER_VERSION/dynbinary/docker-$$DOCKER_VERSION \
			$(TARGET_DIR)/usr/bin/docker
	# Include our udev rules
	$(INSTALL) -m 644 $(@D)/contrib/udev/80-docker.rules \
		$(TARGET_DIR)/etc/udev/rules.d/
	# Include our systemd service files
	$(INSTALL) -m 644 $(@D)/contrib/init/systemd/docker.{service,socket} \
		$(TARGET_DIR)/lib/systemd/system/
endef

$(eval $(generic-package))
