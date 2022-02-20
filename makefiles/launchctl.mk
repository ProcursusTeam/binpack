ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

ifeq (,$(findstring darwin,$(MEMO_TARGET)))

STRAPPROJECTS     += launchctl
LAUNCHCTL_VERSION := $(shell $(STRINGS) $(BUILD_MISC)/launchctl/launchctl.$(MEMO_CFVER) | grep '@(#)PROGRAM:launchctl  PROJECT:libxpc-'| cut -d- -f2)

ifneq ($(wildcard $(BUILD_WORK)/launchctl/.build_complete),)
launchctl:
	@echo "Using previously built launchctl."
else
launchctl:
	mkdir -p $(BUILD_STAGE)/launchctl/$(MEMO_PREFIX)/bin
	$(INSTALL) -m755 $(BUILD_MISC)/launchctl/launchctl.$(MEMO_CFVER) $(BUILD_STAGE)/launchctl/$(MEMO_PREFIX)/bin/launchctl
	$(call AFTER_BUILD)
	$(call BINPACK_SIGN,launchctl.xml)
endif

.PHONY: launchctl

endif
