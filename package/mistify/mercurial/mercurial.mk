################################################################################
#
# mercurial
#
################################################################################

MERCURIAL_VERSION = 3.6-rc
MERCURIAL_SOURCE = mercurial-$(MERCURIAL_VERSION).tar.gz
MERCURIAL_SITE = http://mercurial.selenic.com/release/
MERCURIAL_DEPENDENCIES += python
MERCURIAL_DEPENDENCIES += host-python
MERCURIAL_DEPENDENCIES += host-python-docutils
MERCURIAL_DEPENDENCIES += python-docutils
MERCURIAL_DEPENDENCIES += zlib
MERCURIAL_LICENSE = GPLv2
MERCURIAL_SETUP_TYPE = distutils

$(eval $(python-package))
