ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

STRAPPROJECTS += zstd
ZSTD_VERSION  := 1.5.2

zstd-setup: binpack-setup
	$(call DOWNLOAD_FILES,$(BUILD_SOURCE),https://github.com/facebook/zstd/releases/download/v$(ZSTD_VERSION)/zstd-$(ZSTD_VERSION).tar.gz{$(comma).sig$(comma).sha256})
	$(call CHECKSUM_VERIFY,sha256,zstd-$(ZSTD_VERSION).tar.gz)
	$(call PGP_VERIFY,zstd-$(ZSTD_VERSION).tar.gz)
	$(call EXTRACT_TAR,zstd-$(ZSTD_VERSION).tar.gz,zstd-$(ZSTD_VERSION),zstd)

ifneq ($(wildcard $(BUILD_WORK)/zstd/.build_complete),)
zstd:
	@echo "Using previously built zstd."
else
zstd: zstd-setup
	+$(MAKE) -C $(BUILD_WORK)/zstd/programs zstd-small
	install -d $(BUILD_STAGE)/zstd/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin
	install -m755 $(BUILD_WORK)/zstd/programs/zstd-small $(BUILD_STAGE)/zstd/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/zstd
	$(call AFTER_BUILD,copy)
	$(call BINPACK_SIGN,general.xml)
endif

.PHONY: zstd
