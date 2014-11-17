################################################################################
#
# start_stop_daemon
#
################################################################################

START_STOP_DAEMON_VERSION     = c195722ccb13c5f669a001fc2aee0c84d11d39f3
START_STOP_DAEMON_SITE_METHOD = git
START_STOP_DAEMON_SITE        = https://anonscm.debian.org/git/dpkg/dpkg.git
START_STOP_DAEMON_LICENSE     = GPL

define START_STOP_DAEMON_BUILD_CMDS
	    cd $(@D) && \
	    autoupdate && \
	    autoreconf -v -i && \
	    ./configure && \
        make
endef

define START_STOP_DAEMON_INSTALL_TARGET_CMDS
        $(INSTALL) -m 755 -D $(@D)/utils/start-stop-daemon \
        $(TARGET_DIR)/usr/sbin/start-stop-daemon
endef

$(eval $(generic-package))
