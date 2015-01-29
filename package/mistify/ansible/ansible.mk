################################################################################
#
# ansible
#
################################################################################

ANSIBLE_VERSION = 1.8.2
ANSIBLE_SOURCE = ansible-$(ANSIBLE_VERSION).tar.gz
ANSIBLE_SITE = http://releases.ansible.com/ansible/
ANSIBLE_SETUP_TYPE = setuptools
ANSIBLE_LICENSE = GPLv3
ANSIBLE_LICENSE_FILES = COPYING
ANSIBLE_DEPENDENCIES += python-pyyaml
ANSIBLE_DEPENDENCIES += python-jinja2
ANSIBLE_DEPENDENCIES += python-httplib2
ANSIBLE_DEPENDENCIES += python-paramiko

$(eval $(python-package))

