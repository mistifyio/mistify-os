#############################################################
#
# sdk-overrides
#
#############################################################

#+
# These are variable and macro replacements needed to build the
# SDK version of Mistify-OS. This approach is used instead of
# creating a series of conditional patch files for the core
# of buildroot.
#-

ifeq ($(BR2_PACKAGE_SDK_OVERRIDES),y)

#+
# The buildroot cmake package so helpfully removes the cmake executables from
# the target file system in the interest of space. For the SDK these are needed
# in order to build cmake based packages.
#-
define CMAKE_REMOVE_EXTRA_DATA
	rm -fr $(TARGET_DIR)/usr/share/cmake-$(CMAKE_VERSION_MAJOR)/{Help}
endef

#+
# A big deal here. The perl built by buildroot doesn't support threads.
# automake on the other hand requires thread. Soo.....
# Add the config option here.
#-
PERL_CONF_OPTS += -Dusethreads
PERL_CONF_OPTS += -Duseithreads
PERL_CONF_OPTS += -Dmultiplicity

#+
# Part of the SDK is GCC which in turn requires GMP. GMP has a known bug which
# has caused problems when running in a container.
# This is documented here:
#   https://gmplib.org/list-archives/gmp-bugs/2008-August/001114.html
# This is fixed here in the post install of the host side m4.
#-
define M4_GMP_BUG_WORKAROUND
	if [ ! -e $(HOST_DIR)/usr/bin/m4-not-needed ]; then \
	  ln -s m4 $(HOST_DIR)/usr/bin/m4-not-needed; \
	fi
endef

HOST_M4_POST_INSTALL_HOOKS += M4_GMP_BUG_WORKAROUND

endif
