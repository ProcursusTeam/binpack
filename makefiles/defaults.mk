ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS      += defaults
DEFAULTS_VERSION := 1.0.1

defaults-setup: setup
	$(call GITHUB_ARCHIVE,ProcursusTeam,defaults,$(DEFAULTS_VERSION),v$(DEFAULTS_VERSION))
	$(call EXTRACT_TAR,defaults-$(DEFAULTS_VERSION).tar.gz,defaults-$(DEFAULTS_VERSION),defaults)

ifneq ($(wildcard $(BUILD_WORK)/defaults/.build_complete),)
defaults:
	@echo "Using previously built defaults."
else
defaults: defaults-setup
	+$(MAKE) -C $(BUILD_WORK)/defaults
	$(INSTALL) -d $(BUILD_STAGE)/defaults/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin
	$(INSTALL) -m755 $(BUILD_WORK)/defaults/defaults $(BUILD_STAGE)/defaults/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/defaults
	$(call AFTER_BUILD)
	$(LDID) -Hsha256 -S$(BUILD_WORK)/defaults/ent.plist $(BUILD_STAGE)/defaults/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/defaults
endif

.PHONY: defaults
