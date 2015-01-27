#+
# LochNess make file for Mistify-OS.
# This is executed from the buildroot compliant lochness.mk in the package
# directory.
#-
PREFIX := /usr
SBIN_DIR=$(PREFIX)/sbin

cmd/heartbeat/heartbeat: cmd/heartbeat/main.go
	cd $(dir $<) && \
	go get && \
	go build -v

$(SBIN_DIR)/lochness-heartbeat: cmd/heartbeat/heartbeat
	install -D $< $(DESTDIR)$@

cmd/ipxe/ipxe: cmd/ipxe/main.go
	cd $(dir $<) && \
	go get && \
	go build -v

$(SBIN_DIR)/lochness-ipxe: cmd/ipxe/ipxe
	install -D $< $(DESTDIR)$@

cmd/lock/lock: cmd/lock/lock.go
	cd $(dir $<) && \
	go get && \
	go build -v

$(SBIN_DIR)/lochness-lock: cmd/lock/lock
	install -D $< $(DESTDIR)$@

cmd/locker/locker: cmd/locker/locker.go
	cd $(dir $<) && \
	go get && \
	go build -v

$(SBIN_DIR)/lochness-locker: cmd/locker/locker
	install -D $< $(DESTDIR)$@

cmd/test/test: cmd/test/main.go
	cd $(dir $<) && \
	go get && \
	go build -v

$(SBIN_DIR)/lochness-test: cmd/test/test
	install -D $< $(DESTDIR)$@

cmd/testagent/testagent: cmd/testagent/main.go
	cd $(dir $<) && \
	go get && \
	go build

$(SBIN_DIR)/lochness-testagent: cmd/testagent/testagent
	install -D $< $(DESTDIR)$@


clean:
	cd cmd/heartbeat && \
	go clean && \
	cd cmd/ipxe && \
	go clean && \
	cd cmd/lock && \
	go clean && \
	cd cmd/locker && \
	go clean && \
	cd cmd/test && \
	go clean && \
	cd cmd/testagent && \
	go clean

install: \
  $(SBIN_DIR)/lochness-heartbeat \
  $(SBIN_DIR)/lochness-ipxe \
  $(SBIN_DIR)/lochness-lock \
  $(SBIN_DIR)/lochness-locker \
  $(SBIN_DIR)/lochness-test \
  $(SBIN_DIR)/lochness-testagent

