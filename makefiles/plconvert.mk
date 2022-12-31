ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS       += plconvert
PLCONVERT_VERSION := 1153.18

plconvert-setup: setup
	$(call GITHUB_ARCHIVE,apple-oss-distributions,CF,$(PLCONVERT_VERSION),CF-$(PLCONVERT_VERSION),plconvert)
	$(call EXTRACT_TAR,plconvert-$(PLCONVERT_VERSION).tar.gz,CF-CF-$(PLCONVERT_VERSION),plconvert)
	mkdir -p $(BUILD_STAGE)/plconvert/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin

ifneq ($(wildcard $(BUILD_WORK)/plconvert/.build_complete),)
plconvert:
	@echo "Using previously built plconvert."
else
plconvert: plconvert-setup
	$(CC) $(CFLAGS) $(BUILD_WORK)/plconvert/plconvert.c -r -nostdlib -o $(BUILD_STAGE)/plconvert/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/plconvert.lo -framework CoreFoundation
	$(call SETUP_STUBS)
	$(call AFTER_BUILD)
	#$(call BINPACK_SIGN,general.xml)
endif

.PHONY: plconvert
