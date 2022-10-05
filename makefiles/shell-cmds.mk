ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

ifeq (,$(findstring darwin,$(MEMO_TARGET)))

STRAPPROJECTS      += shell-cmds
SHELL-CMDS_VERSION := 207.40.1

shell-cmds-setup: setup binpack-setup
	$(call DOWNLOAD_FILES,$(BUILD_SOURCE),https://opensource.apple.com/tarballs/shell_cmds/shell_cmds-$(SHELL-CMDS_VERSION).tar.gz)
	$(call EXTRACT_TAR,shell_cmds-$(SHELL-CMDS_VERSION).tar.gz,shell_cmds-$(SHELL-CMDS_VERSION),shell-cmds)
	mkdir -p $(BUILD_STAGE)/shell-cmds/$(MEMO_PREFIX){,$(MEMO_SUB_PREFIX)}/bin

ifneq ($(wildcard $(BUILD_WORK)/shell-cmds/.build_complete),)
shell-cmds:
	@echo "Using previously built shell-cmds."
else
shell-cmds: shell-cmds-setup
	-cd $(BUILD_WORK)/shell-cmds; \
	for bin in date echo hostname kill sleep; do \
		$(CC) $(CFLAGS) $(LDFLAGS) -o $(BUILD_STAGE)/shell-cmds/$(MEMO_PREFIX)/bin/$$bin $$bin/*.c -D'__FBSDID(x)='; \
	done; \
	$(CC) $(CFLAGS) $(LDFLAGS) -o $(BUILD_STAGE)/shell-cmds/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/id id/id.c -D'__FBSDID(x)='; \
	yacc -o $(BUILD_WORK)/shell-cmds/find/getdate.c $(BUILD_WORK)/shell-cmds/find/getdate.y; \
	for bin in false find hexdump killall nohup printf pwd renice script seq tee time true uname w what which xargs; do \
		$(CC) $(CFLAGS) $(LDFLAGS) -o $(BUILD_STAGE)/shell-cmds/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/$$bin $$bin/*.c -D'__FBSDID(x)=' -DHAVE_UTMPX; \
	done
	$(LN_S) ..$(MEMO_SUB_PREFIX)/bin/pwd $(BUILD_STAGE)/shell-cmds/$(MEMO_PREFIX)/bin/pwd
	$(call AFTER_BUILD)
	$(call BINPACK_SIGN,general.xml)
endif

.PHONY: shell-cmds

endif # ($(MEMO_TARGET),darwin-\*)
