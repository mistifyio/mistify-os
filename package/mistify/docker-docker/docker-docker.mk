################################################################################
#
# docker-docker
#
################################################################################

DOCKER_DOCKER_VERSION = aac645ae047601fed1550c9d59d7c8ea978203b0
DOCKER_DOCKER_SITE    = git@github.com:docker/docker.git
DOCKER_DOCKER_SITE_METHOD = git
DOCKER_DOCKER_LICENSE = Apache
DOCKER_DOCKER_LICENSE_FILES = LICENSE
DOCKER_DOCKER_DEPENDENCIES = libcontainer sqlite zfs

GOPATH = $(O)/tmp/GOPATH
DOCKER_DOCKER_GOSRC = $(GOPATH)/src/github.com/docker/docker

# These are evaluated at runtime
REGISTRY_IMPORT  = github.com/docker/distribution
REGISTRY_COMMIT  = `awk '/^ENV REGISTRY_COMMIT / { print $$3; }' $(@D)/Dockerfile`
DOCKER_PY_IMPORT = github.com/docker/docker-py
DOCKER_PY_COMMIT = `awk '/^ENV DOCKER_PY_COMMIT / { print $$3; }' $(@D)/Dockerfile`
TOMLV_IMPORT     = github.com/BurntSushi/toml
TOMLV_COMMIT     = `awk '/^ENV TOMLV_COMMIT / { print $$3; }' $(@D)/Dockerfile`

# Versions handpicked by us
MD2MAN_IMPORT      = github.com/cpuguy83/go-md2man
MD2MAN_COMMIT      = v1.0.2
BLACKFRIDAY_IMPORT = github.com/russross/blackfriday
BLACKFRIDAY_COMMIT = 4bed88b4fd00fbb66b49b0f38ed3dd0b902ab515
SANITIZED_IMPORT   = github.com/shurcooL/sanitized_anchor_name
SANITIZED_COMMIT   = 11a20b799bf22a02808c862eb6ca09f7fb38f84a

# See values in project/PACKAGERS.md
DOCKER_BUILDTAGS =
#DOCKER_BUILDTAGS += apparmor
#DOCKER_BUILDTAGS += selinux
DOCKER_BUILDTAGS += btrfs_noversion
DOCKER_BUILDTAGS += exclude_graphdriver_btrfs
DOCKER_BUILDTAGS += exclude_graphdriver_devicemapper
#DOCKER_BUILDTAGS += exclude_graphdriver_aufs


define DOCKER_DOCKER_BUILD_CMDS
	mkdir -p $(DOCKER_DOCKER_GOSRC)
	rsync -av --delete-after --exclude=.git --exclude-from=$(@D)/.gitignore \
		$(@D)/ $(DOCKER_DOCKER_GOSRC)/

	# Install registry
	rm -rf $(GOPATH)/src/$(REGISTRY_IMPORT) \
		&& git clone git://$(REGISTRY_IMPORT) $(GOPATH)/src/$(REGISTRY_IMPORT) \
		&& (cd $(GOPATH)/src/$(REGISTRY_IMPORT) \
			&& git checkout -q $(REGISTRY_COMMIT)) \
		&& GOPATH=$(GOPATH)/src/$(REGISTRY_IMPORT)/Godeps/_workspace:$(GOPATH) \
		GOROOT=$(GOROOT) \
		PATH=$(GOROOT)/bin:$(PATH) \
		go build -o $(GOPATH)/bin/registry-v2 \
			$(REGISTRY_IMPORT)/cmd/registry

	# Get the "docker-py" source so we can run their integration tests
	rm -rf $(DOCKER_DOCKER_GOSRC)/docker-py \
		&& git clone git://$(DOCKER_PY_IMPORT) $(DOCKER_DOCKER_GOSRC)/docker-py \
		&& (cd $(DOCKER_DOCKER_GOSRC)/docker-py \
			&& git checkout -q $(DOCKER_PY_COMMIT))

	# Download man page generator and toml validator
	for import in $(MD2MAN_IMPORT) $(BLACKFRIDAY_IMPORT) \
		$(SANITIZED_IMPORT) $(TOMLV_IMPORT); do \
		rm -rf $(GOPATH)/src/$$import \
			&& mkdir -p $(GOPATH)/src/$$import \
			&& git clone git://$$import $(GOPATH)/src/$$import; \
	done

	(cd $(GOPATH)/src/$(MD2MAN_IMPORT) && \
		git checkout -q $(MD2MAN_COMMIT))
	(cd $(GOPATH)/src/$(BLACKFRIDAY_IMPORT) && \
		git checkout -q $(BLACKFRIDAY_COMMIT))
	(cd $(GOPATH)/src/$(SANITIZED_IMPORT) && \
		git checkout -q $(SANITIZED_COMMIT))
	(cd $(GOPATH)/src/$(TOMLV_IMPORT) && \
		git checkout -q $(TOMLV_COMMIT))

	# Build dependencies
	GOPATH=$(GOPATH) \
	GOROOT=$(GOROOT) \
	PATH=$(GOROOT)/bin:$(PATH) \
	go install -v $(MD2MAN_IMPORT) $(TOMLV_IMPORT)

	# Do the rest of the build
	cd $(DOCKER_DOCKER_GOSRC) \
		&& GOPATH=$(DOCKER_DOCKER_GOSRC)/vendor:$(GOPATH) \
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

define DOCKER_DOCKER_USERS
	- - docker -1 * - - - Docker Application Container Framework
	dockroot 502 dockroot 502 * - - - Unprivileged container root
endef

define DOCKER_DOCKER_INSTALL_TARGET_CMDS
	$(INSTALL) -m 755 -d $(TARGET_DIR)/usr/lib/docker
	$(INSTALL) -m 755 -d $(TARGET_DIR)/var/lib/docker
	read DOCKER_VERSION < $(@D)/VERSION \
		&& $(INSTALL) -m 755 -D \
			$(DOCKER_DOCKER_GOSRC)/bundles/$$DOCKER_VERSION/dynbinary/docker-$$DOCKER_VERSION \
			$(TARGET_DIR)/usr/bin/docker \
		&& $(INSTALL) -m 755 -D \
			$(DOCKER_DOCKER_GOSRC)/bundles/$$DOCKER_VERSION/dynbinary/dockerinit-$$DOCKER_VERSION \
			$(TARGET_DIR)/usr/lib/docker/dockerinit
	# Include our udev rules
	$(INSTALL) -m 644 $(@D)/contrib/udev/80-docker.rules \
		$(TARGET_DIR)/etc/udev/rules.d/
endef

define DOCKER_DOCKER_INSTALL_INIT_SYSTEMD
	$(INSTALL) -m 644 -D $(@D)/contrib/init/systemd/docker.{service,socket} \
		$(TARGET_DIR)/lib/systemd/system/
	$(INSTALL) -m 644 -D $(BR2_EXTERNAL)/package/mistify/docker-docker/docker.sysconfig \
		$(TARGET_DIR)/etc/sysconfig/docker
	$(INSTALL) -m 644 -D $(BR2_EXTERNAL)/package/mistify/docker-docker/docker-storage.sysconfig \
		$(TARGET_DIR)/etc/sysconfig/docker-storage
	$(INSTALL) -m 644 -D $(BR2_EXTERNAL)/package/mistify/docker-docker/docker-network.sysconfig \
		$(TARGET_DIR)/etc/sysconfig/docker-network
endef

$(eval $(generic-package))
