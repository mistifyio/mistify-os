include $(sort $(wildcard $(BR2_EXTERNAL)/package/*/*/*.mk))

define VARIANT_DEV_COPY_HEADERS
	(cd $(STAGING_DIR)/usr && \
		tar cf - include | (cd $(TARGET_DIR)/usr && tar xf -))
endef

ifeq ($(BR2_VARIANT_DEV),y)
	TARGET_FINALIZE_HOOKS += VARIANT_DEV_COPY_HEADERS
endif
