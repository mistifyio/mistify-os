################################################################################
#
# python-paramiko
#
################################################################################

PYTHON_PARAMIKO_VERSION = 1.15.2
PYTHON_PARAMIKO_SOURCE = paramiko-$(PYTHON_PARAMIKO_VERSION).tar.gz
PYTHON_PARAMIKO_SITE = http://pypi.python.org/packages/source/p/paramiko
PYTHON_PARAMIKO_SETUP_TYPE = setuptools
PYTHON_PARAMIKO_LICENSE = GPLv2
PYTHON_PARAMIKO_LICENSE_FILES = LICENSE
PYTHON_PARAMIKO_DEPENDENCIES = python-pycrypto

$(eval $(python-package))
