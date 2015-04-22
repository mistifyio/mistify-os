################################################################################
#
# beanstalkd
#
################################################################################

BEANSTALKD_VERSION = 1.10
BEANSTALKD_SOURCE  = v$(BEANSTALKD_VERSION).tar.gz
BEANSTALKD_SITE    = https://github.com/kr/beanstalkd/archive/
BEANSTALKD_LICENSE_FILES = LICENSE

define BEANSTALKD_BUILD_CMDS
	(cd $(BEANSTALKD_DIR) && make)
endef

define BEANSTALKD_INSTALL_TARGET_CMDS
	$(INSTALL) -m 755 -D $(BEANSTALKD_DIR)/beanstalkd \
		$(TARGET_DIR)/usr/sbin/beanstalkd
	$(INSTALL) -m 644 -D $(BEANSTALKD_DIR)/adm/systemd/beanstalkd.service \
		$(TARGET_DIR)/lib/systemd/system
	$(INSTALL) -m 644 -D $(BEANSTALKD_DIR)/adm/systemd/beanstalkd.socket \
		$(TARGET_DIR)/lib/systemd/system
endef

$(eval $(generic-package))

