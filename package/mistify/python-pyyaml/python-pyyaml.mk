################################################################################
#
# python-pyyaml
#
################################################################################

PYTHON_PYYAML_VERSION = 3.11
PYTHON_PYYAML_SOURCE = PyYAML-$(PYTHON_PYYAML_VERSION).tar.gz
PYTHON_PYYAML_SITE = http://pypi.python.org/packages/source/P/PyYAML
PYTHON_PYYAML_SETUP_TYPE = distutils
PYTHON_PYYAML_LICENSE = MIT
PYTHON_PYYAML_LICENSE_FILES = LICENSE
PYTHON_PYYAML_DEPENDENCIES = libyaml

define PYTHON_PYYAML_CONFIGURE_CMDS
	(cd $(@D); \
		$(HOST_DIR)/usr/bin/python setup.py \
		--with-libyaml config)
endef

$(eval $(python-package))
