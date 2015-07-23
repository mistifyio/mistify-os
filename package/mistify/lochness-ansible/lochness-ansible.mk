################################################################################
#
# lochness-ansible
#
################################################################################

LOCHNESS_ANSIBLE_VERSION = 94fcab0ffb73756ec248f20240e4a006137d5f35
LOCHNESS_ANSIBLE_SITE    = git@github.com:mistifyio/lochness-ansible.git
LOCHNESS_ANSIBLE_SITE_METHOD = git
LOCHNESS_ANSIBLE_LICENSE = Apache
LOCHNESS_ANSIBLE_LICENSE_FILES = LICENSE

define LOCHNESS_ANSIBLE_BUILD_CMDS

	test -d ${TARGET_DIR}/var/lib/ansible || \
		mkdir -p ${TARGET_DIR}/var/lib/ansible

	cp -r ${LOCHNESS_ANSIBLE_DIR}/* \
		${TARGET_DIR}/var/lib/ansible/

endef

define LOCHNESS_ANSIBLE_INSTALL_TARGET_CMDS
	# The install was done as part of the build.
endef


$(eval $(generic-package))

