################################################################################
#
# mistify-gopackage
#
# NOTE: This package is intended to be built using only a target on the
# buildmistify script command line. Therefore there is no Config.in for this
# package. As a result there is no menuconfig option either.
################################################################################

#+
# Expected environment variables.
#
# GOPACKAGEDIR	Where the subagent source code and makefile is located.
# GOPACKAGENAME	The name to associate with the subabent. This is used to name
#		the build directory among other things. This also allows
#		different agents to be built using this one package.
# DRYRUN	Most often used to echo commands rather than actually execute
#		them.
#-
GOPACKAGE_VERSION	= $(GOPACKAGENAME)
GOPACKAGE_SITE		= $(GOPACKAGEDIR)
GOPACKAGE_SITE_METHOD	= local

GOPATH=$(O)/tmp/GOPATH

define GOPACKAGE_BUILD_CMDS
	# GO apparently wants the install path to be independent of the
	# build path. Use a temporary directory to do the build.
	mkdir -p $(GOPATH)/src/github.com/mistifyio/$(GOPACKAGENAME)
	rsync -av --exclude .git $(@D)/* $(GOPATH)/src/github.com/mistifyio/$(GOPACKAGENAME)/
	GOROOT=$(GOROOT) \
		PATH=$(GOROOT)/bin:$(PATH) \
		GOPATH=$(GOPATH) make install DESTDIR=$(TARGET_DIR) \
		-C $(GOPATH)/src/github.com/mistifyio/$(GOPACKAGENAME)
endef

define GOPACKAGENAME_INSTALL_CMDS
	# The install was done as part of the build.
endef

$(eval $(generic-package))

