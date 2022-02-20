ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

ifeq (,$(findstring darwin,$(MEMO_TARGET)))

STRAPPROJECTS      += shell-cmds
SHELL-CMDS_VERSION := 207.40.1

shell-cmds-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://opensource.apple.com/tarballs/shell_cmds/shell_cmds-$(SHELL-CMDS_VERSION).tar.gz
	$(call EXTRACT_TAR,shell_cmds-$(SHELL-CMDS_VERSION).tar.gz,shell_cmds-$(SHELL-CMDS_VERSION),shell-cmds)

ifneq ($(wildcard $(BUILD_WORK)/shell-cmds/.build_complete),)
shell-cmds:
	@echo "Using previously built shell-cmds."
else
shell-cmds: shell-cmds-setup
	mkdir -p $(BUILD_STAGE)/shell-cmds/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin
	-cd $(BUILD_WORK)/shell-cmds; \
	for bin in script what; do \
		$(CC) $(CFLAGS) -o $(BUILD_STAGE)/shell-cmds/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/$$bin $$bin/*.c -D'__FBSDID(x)=' -save-temps; \
	done
	$(call AFTER_BUILD)
	$(call BINPACK_SIGN,general.xml)
endif

.PHONY: shell-cmds

endif # ($(MEMO_TARGET),darwin-\*)
