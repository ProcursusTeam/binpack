ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS        += uikittools
UIKITTOOLS_VERSION := 2.1.1

uikittools-setup: setup
	$(call GITHUB_ARCHIVE,ProcursusTeam,uikittools-ng,$(UIKITTOOLS_VERSION),v$(UIKITTOOLS_VERSION))
	$(call EXTRACT_TAR,uikittools-ng-$(UIKITTOOLS_VERSION).tar.gz,uikittools-ng-$(UIKITTOOLS_VERSION),uikittools)

ifneq ($(wildcard $(BUILD_WORK)/uikittools/.build_complete),)
uikittools:
	@echo "Using previously built uikittools."
else
uikittools: uikittools-setup
	mkdir -p $(BUILD_STAGE)/uikittools/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin
	+$(MAKE) -C $(BUILD_WORK)/uikittools uicache \
		PREFIX="$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)" \
		APP_PATH="/Applications" \
		NLS=0
	install -m755 $(BUILD_WORK)/uikittools/uicache $(BUILD_STAGE)/uikittools/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin
	$(call AFTER_BUILD)
	$(LDID) -S$(BUILD_WORK)/uikittools/uicache.plist $(BUILD_STAGE)/uikittools/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/uicache
	find $(BUILD_STAGE)/uikittools -name '.ldid*' -type f -delete
endif

.PHONY: uikittools
