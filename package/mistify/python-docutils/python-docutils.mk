################################################################################
#
# python-docutils
#
################################################################################

PYTHON_DOCUTILS_VERSION = 0.12
PYTHON_DOCUTILS_SOURCE = docutils-$(PYTHON_DOCUTILS_VERSION).tar.gz
PYTHON_DOCUTILS_SITE = http://downloads.sourceforge.net/project/docutils/docutils/$(PYTHON_DOCUTILS_VERSION)
PYTHON_DOCUTILS_SETUP_TYPE = distutils
PYTHON_DOCUTILS_LICENSE_FILES = COPYING.txt

$(eval $(python-package))
$(eval $(host-python-package))
