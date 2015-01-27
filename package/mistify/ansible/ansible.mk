################################################################################
#
# ansible
#
################################################################################

ANSIBLE_VERSION = v1.8.2
ANSIBLE_SITE    = https://github.com/ansible/ansible.git
ANSIBLE_SITE_METHOD = git
ANSIBLE_LICENSE_FILES = COPYING
ANSIBLE_SETUP_TYPE = setuptools
ANSIBLE_DEPENDENCIES += python-pyyaml
ANSIBLE_DEPENDENCIES += python-jinja2
ANSIBLE_DEPENDENCIES += python-httplib2
ANSIBLE_DEPENDENCIES += python-paramiko

$(eval $(python-package))

