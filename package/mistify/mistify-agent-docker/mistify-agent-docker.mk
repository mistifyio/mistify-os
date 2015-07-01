################################################################################
#
# mistify-agent-docker
#
################################################################################

MISTIFY_AGENT_DOCKER_VERSION = d29fdb275b175a597198ab42f8441f82407bb7ef
MISTIFY_AGENT_DOCKER_SITE    = git@github.com:mistifyio/mistify-agent-docker.git
MISTIFY_AGENT_DOCKER_SITE_METHOD = git
MISTIFY_AGENT_DOCKER_LICENSE = Apache
MISTIFY_AGENT_DOCKER_LICENSE_FILES = LICENSE
MISTIFY_AGENT_DOCKER_DEPENDENCIES = docker-docker mistify-agent

GOPATH=$(O)/tmp/GOPATH

define MISTIFY_AGENT_DOCKER_BUILD_CMDS
	# GO apparently wants the install path to be independent of the
	# build path. Use a temporary directory to do the build.
	mkdir -p $(GOPATH)/src/github.com/mistifyio/mistify-agent-docker
	rsync -av --delete-after --exclude=.git --exclude-from=$(@D)/.gitignore \
		$(@D)/ $(GOPATH)/src/github.com/mistifyio/mistify-agent-docker/
	GOROOT=$(GOROOT) \
	PATH=$(GOROOT)/bin:$(PATH) \
	GOPATH=$(GOPATH) make install DESTDIR=$(TARGET_DIR) \
		-C $(GOPATH)/src/github.com/mistifyio/mistify-agent-docker
endef

define MISTIFY_AGENT_DOCKER_INSTALL_TARGET_CMDS
	# The install was done as part of the build.
endef

define MISTIFY_AGENT_DOCKER_INSTALL_INIT_SYSTEMD
	$(INSTALL) -m 644 -D $(BR2_EXTERNAL)/package/mistify/mistify-agent-docker/mistify-agent-docker.service \
		$(TARGET_DIR)/lib/systemd/system/mistify-agent-docker.service

	$(INSTALL) -m 644 -D $(BR2_EXTERNAL)/package/mistify/mistify-agent-docker/mistify-agent-docker.sysconfig \
		$(TARGET_DIR)/etc/sysconfig/mistify-agent-docker
endef

$(eval $(generic-package))
