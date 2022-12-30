ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

STRAPPROJECTS += bzip2
BZIP2_VERSION := 1.0.8

bzip2-setup: binpack-setup
	$(call DOWNLOAD_FILES,$(BUILD_SOURCE),https://sourceware.org/pub/bzip2/bzip2-$(BZIP2_VERSION).tar.gz{$(comma).sig})
	$(call PGP_VERIFY,bzip2-$(BZIP2_VERSION).tar.gz)
	$(call EXTRACT_TAR,bzip2-$(BZIP2_VERSION).tar.gz,bzip2-$(BZIP2_VERSION),bzip2)
	mkdir -p $(BUILD_STAGE)/bzip2/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin

ifneq ($(wildcard $(BUILD_WORK)/bzip2/.build_complete),)
bzip2:
	@echo "Using previously built bzip2."
else
bzip2: bzip2-setup
	+$(MAKE) -C $(BUILD_WORK)/bzip2 bzip2{,recover} \
		PREFIX=$(BUILD_STAGE)/bzip2/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX) \
		CC=$(CC) \
		AR=$(AR) \
		RANLIB=$(RANLIB) \
		CFLAGS="$(CFLAGS)"
	install -m755 $(BUILD_WORK)/bzip2/bzip2{,recover} $(BUILD_STAGE)/bzip2/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin
	$(LN_S) bzip2 $(BUILD_STAGE)/bzip2/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/bzcat
	$(LN_S) bzip2 $(BUILD_STAGE)/bzip2/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/bunzip2
	$(call AFTER_BUILD)
	$(call BINPACK_SIGN,general.xml)
endif

.PHONY: bzip2
