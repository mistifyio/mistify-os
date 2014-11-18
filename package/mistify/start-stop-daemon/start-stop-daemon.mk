################################################################################
#
# start-stop-daemon
#
################################################################################

START_STOP_DAEMON_VERSION = 1.17.21
START_STOP_DAEMON_SITE = git://anonscm.debian.org/dpkg/dpkg.git
START_STOP_DAEMON_LICENSE = GPLv2
START_STOP_DAEMON_LICENSE_FILES = COPYING
START_STOP_DAEMON_DEPENDENCIES += host-gettext
START_STOP_DAEMON_DEPENDENCIES += host-flex
START_STOP_DAEMON_DEPENDENCIES += host-m4
START_STOP_DAEMON_DEPENDENCIES += host-autoconf
START_STOP_DAEMON_DEPENDENCIES += host-automake

START_STOP_DAEMON_AUTORECONF = YES
START_STOP_DAEMON_AUTORECONF_OPT = -fiv

START_STOP_DAEMON_CONF_OPT += --disable-dselect --disable-update-alternatives --disable-shared

define START_STOP_DAEMON_GENVERSION
	echo $(START_STOP_DAEMON_VERSION) > $(START_STOP_DAEMON_DIR)/.dist-version
	mkdir $(START_STOP_DAEMON_DIR)/build-aux && touch $(START_STOP_DAEMON_DIR)/build-aux/config.rpath
endef

define START_STOP_DAEMON_GETTEXTIZE
	ln -s $(HOST_DIR)/usr/share/gettext/po/Makefile.in.in $(START_STOP_DAEMON_DIR)/po/Makefile.in.in
	ln -s $(HOST_DIR)/usr/share/gettext/po/Makefile.in.in $(START_STOP_DAEMON_DIR)/dselect/po/Makefile.in.in
	ln -s $(HOST_DIR)/usr/share/gettext/po/Makefile.in.in $(START_STOP_DAEMON_DIR)/scripts/po/Makefile.in.in
	ln -s $(HOST_DIR)/usr/share/gettext/po/Makefile.in.in $(START_STOP_DAEMON_DIR)/man/po/Makefile.in.in
endef

define START_STOP_DAEMON_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/utils/start-stop-daemon $(TARGET_DIR)/sbin
endef

START_STOP_DAEMON_POST_EXTRACT_HOOKS += START_STOP_DAEMON_GENVERSION
START_STOP_DAEMON_PRE_CONFIGURE_HOOKS += START_STOP_DAEMON_GETTEXTIZE

$(eval $(autotools-package))
