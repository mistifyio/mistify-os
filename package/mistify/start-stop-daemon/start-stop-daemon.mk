################################################################################
#
# start-stop-daemon
#
################################################################################

START_STOP_DAEMON_VERSION = 1.17.21
START_STOP_DAEMON_SITE = git://anonscm.debian.org/dpkg/dpkg.git
START_STOP_DAEMON_LICENSE = GPLv2
START_STOP_DAEMON_LICENSE_FILES = COPYING

START_STOP_DAEMON_AUTORECONF = YES
START_STOP_DAEMON_AUTORECONF_OPT = -fiv

START_STOP_DAEMON_CONF_OPT += --disable-dselect --disable-update-alternatives --disable-shared

define START_STOP_DAEMON_GENVERSION
	echo $(START_STOP_DAEMON_VERSION) > $(START_STOP_DAEMON_DIR)/.dist-version
	mkdir $(START_STOP_DAEMON_DIR)/build-aux && touch $(START_STOP_DAEMON_DIR)/build-aux/config.rpath
endef

define START_STOP_DAEMON_INSTALL_TARGET_CMDS
	$(MAKE) -C $(START_STOP_DAEMON_DIR)/utils install
endef

START_STOP_DAEMON_POST_EXTRACT_HOOKS += START_STOP_DAEMON_GENVERSION

$(eval $(autotools-package))
