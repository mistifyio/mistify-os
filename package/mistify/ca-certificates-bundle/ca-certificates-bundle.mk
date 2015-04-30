################################################################################
#
# ca-certificates-bundle
#
################################################################################

CA_CERTIFICATES_BUNDLE_VERSION = $(CA_CERTIFICATES_VERSION)
CA_CERTIFICATES_BUNDLE_SITE = $(BR2_EXTERNAL)/package/mistify/ca-certificates-bundle
CA_CERTIFICATES_BUNDLE_SITE_METHOD = local
CA_CERTIFICATES_BUNDLE_DEPENDENCIES = ca-certificates
CA_CERTIFICATES_BUNDLE_LICENSE = MPLv2.0

define CA_CERTIFICATES_BUNDLE_INSTALL_TARGET_CMDS
	# Remove existing bundle file if needed
	rm -f $(TARGET_DIR)/etc/ssl/certs/ca-certificates.crt
	touch -m 644 $(TARGET_DIR)/etc/ssl/certs/ca-certificates.crt

	# Concatenate existing files (adding newlines if needed)
	cd $(TARGET_DIR); \
	for i in `find usr/share/ca-certificates -type f -name "*.crt"`; do \
		sed -e '$$a\' "$$i" >> etc/ssl/certs/ca-certificates.crt; \
	done
endef

$(eval $(generic-package))
