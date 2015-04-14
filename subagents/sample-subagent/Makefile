###################################################
# Sample GO package make file.
# This is a sample subagent to be used with mistify-agent.
###################################################

#+
# Useful environment variables which are passed from the buildgopackage script.
#
# GOPACKAGEDIR	Where the subagent source code and makefile is located.
# GOPACKAGENAME	The name to associate with the subabent. This is used to name
#		the build directory among other things. This also allows
#		different agents to be built using this one package.
# DRYRUN	Most often used to echo commands rather than actually execute
#		them.
# DESTDIR	Is expected to point to the target root file system. This is
#		set by the GO package make file (package/mistify/gopackage).
#-

PREFIX := /opt/mistify
SBIN_DIR=$(PREFIX)/sbin

sample-subagent: main.go
	$(DRYRUN) go get && \
	$(DRYRUN) go build

clean:
	$(DRYRUN) go clean

install: sample-subagent
	$(DRYRUN) install -D sample-subagent $(DESTDIR)$(SBIN_DIR)/sample-subagent
	# WARNING: This overwrites the agent.json which was installed by mistify-agent.
	$(DRYRUN) install -m 644 -D agent.json $(DESTDIR)/etc/mistify/agent.json
