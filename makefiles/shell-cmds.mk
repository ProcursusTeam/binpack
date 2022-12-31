ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

ifeq (,$(findstring darwin,$(MEMO_TARGET)))

STRAPPROJECTS      += shell-cmds
SHELL-CMDS_VERSION := 278

shell-cmds-setup: setup binpack-setup
	$(call GITHUB_ARCHIVE,apple-oss-distributions,shell_cmds,$(SHELL-CMDS_VERSION),shell_cmds-$(SHELL-CMDS_VERSION))
	$(call EXTRACT_TAR,shell_cmds-$(SHELL-CMDS_VERSION).tar.gz,shell_cmds-shell_cmds-$(SHELL-CMDS_VERSION),shell-cmds)
	mkdir -p $(BUILD_STAGE)/shell-cmds/$(MEMO_PREFIX){,$(MEMO_SUB_PREFIX)}/bin

ifneq ($(wildcard $(BUILD_WORK)/shell-cmds/.build_complete),)
shell-cmds:
	@echo "Using previously built shell-cmds."
else
shell-cmds: shell-cmds-setup
	-cd $(BUILD_WORK)/shell-cmds; \
	for bin in date hostname; do \
		$(CC) $(CFLAGS) -r -nostdlib -o $(BUILD_STAGE)/shell-cmds/$(MEMO_PREFIX)/bin/$$bin.lo $$bin/*.c -D'__FBSDID(x)='; \
	done; \
	$(CC) $(CFLAGS) -r -nostdlib -o $(BUILD_STAGE)/shell-cmds/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/id.lo id/id.c -D'__FBSDID(x)='; \
	$(LN_S) id $(BUILD_STAGE)/shell-cmds/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/whoami; \
	yacc -o $(BUILD_WORK)/shell-cmds/find/getdate.c $(BUILD_WORK)/shell-cmds/find/getdate.y; \
	for bin in env find hexdump killall nohup printf realpath renice script seq tee time uname w what which xargs; do \
		$(CC) $(CFLAGS) -r -nostdlib -o $(BUILD_STAGE)/shell-cmds/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/$$bin.lo $$bin/*.c -D'__FBSDID(x)=' -DHAVE_UTMPX; \
	done
	$(call SETUP_STUBS)
	$(call AFTER_BUILD)
	#$(call BINPACK_SIGN,general.xml)
endif

.PHONY: shell-cmds

endif # ($(MEMO_TARGET),darwin-\*)
