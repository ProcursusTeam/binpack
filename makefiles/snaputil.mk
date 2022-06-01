ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

STRAPPROJECTS    += snaputil
SNAPUTIL_VERSION := 12.3

snaputil-setup: setup
	$(call GITHUB_ARCHIVE,ahl,apfs,$(SNAPUTIL_VERSION),v$(SNAPUTIL_VERSION),snaputil)
	$(call EXTRACT_TAR,snaputil-$(SNAPUTIL_VERSION).tar.gz,apfs-$(SNAPUTIL_VERSION),snaputil)
	mkdir -p $(BUILD_STAGE)/snaputil/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin

ifneq ($(wildcard $(BUILD_WORK)/snaputil/.build_complete),)
snaputil:
	@echo "Using previously built snaputil."
else
snaputil: snaputil-setup
	$(CC) $(CFLAGS) $(LDFLAGS) -o $(BUILD_STAGE)/snaputil/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/snaputil $(BUILD_WORK)/snaputil/snapUtil.c -framework CoreFoundation -framework IOKit
	$(call AFTER_BUILD)
	$(call BINPACK_SIGN,snaputil.xml)
endif

.PHONY: snaputil
