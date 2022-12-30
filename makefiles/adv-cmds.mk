ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

ifeq (,$(findstring darwin,$(MEMO_TARGET)))

SUBPROJECTS      += adv-cmds
ADV-CMDS_VERSION := 199.0.1

adv-cmds-setup: setup binpack-setup
	$(call GITHUB_ARCHIVE,apple-oss-distributions,adv_cmds,$(ADV-CMDS_VERSION),adv_cmds-$(ADV-CMDS_VERSION))
	$(call EXTRACT_TAR,adv_cmds-$(ADV-CMDS_VERSION).tar.gz,adv_cmds-adv_cmds-$(ADV-CMDS_VERSION),adv-cmds)
	mkdir -p $(BUILD_STAGE)/adv-cmds/$(MEMO_PREFIX)/bin

ifneq ($(wildcard $(BUILD_WORK)/adv-cmds/.build_complete),)
adv-cmds:
	@echo "Using previously built adv-cmds."
else
adv-cmds: adv-cmds-setup
	mkdir -p $(BUILD_STAGE)/adv-cmds/$(MEMO_PREFIX)/bin
	$(CC) $(CFLAGS) $(LDFLAGS) -r -nostdlib -o $(BUILD_STAGE)/adv-cmds/$(MEMO_PREFIX)/bin/stty.lo $(BUILD_WORK)/adv-cmds/stty/*.c
	$(call SETUP_STUBS)
	$(call AFTER_BUILD)
endif

.PHONY: adv-cmds

endif # ($(MEMO_TARGET),darwin-\*)
