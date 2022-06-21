ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

ifeq (,$(findstring darwin,$(MEMO_TARGET)))

STRAPPROJECTS     += file-cmds
# Don't upgrade file-cmds, as any future version includes APIs introduced in iOS 13+.
ifeq ($(shell [ "$(CFVER_WHOLE)" -le 1500 ] && echo 1),1)
FILE-CMDS_VERSION := 272.250.1
else
FILE-CMDS_VERSION := 353.100.22
endif

file-cmds-setup: setup
	$(call GITHUB_ARCHIVE,apple-oss-distributions,file_cmds,$(FILE-CMDS_VERSION),file_cmds-$(FILE-CMDS_VERSION))
	$(call EXTRACT_TAR,file_cmds-$(FILE-CMDS_VERSION).tar.gz,file_cmds-file_cmds-$(FILE-CMDS_VERSION),file-cmds)
	mkdir -p $(BUILD_STAGE)/file-cmds/$(MEMO_PREFIX){/sbin,$(MEMO_SUB_PREFIX)/bin}

ifneq ($(wildcard $(BUILD_WORK)/file-cmds/.build_complete),)
file-cmds:
	@echo "Using previously built file-cmds."
else
file-cmds: file-cmds-setup
	$(CC) $(CFLAGS) $(LDFLAGS) -o $(BUILD_STAGE)/file-cmds/$(MEMO_PREFIX)/sbin/mknod $(BUILD_WORK)/file-cmds/mknod/mknod.c
	$(CC) $(CFLAGS) $(LDFLAGS) -o $(BUILD_STAGE)/file-cmds/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/chflags $(BUILD_WORK)/file-cmds/chflags/chflags.c
ifeq ($(shell [ "$(CFVER_WHOLE)" -gt 1500 ] && echo 1),1) # xattr is only available in file-cmds 352.40.66 and up
	$(CC) $(CFLAGS) $(LDFLAGS) -o $(BUILD_STAGE)/file-cmds/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/xattr $(BUILD_WORK)/file-cmds/xattr/xattr.c
endif
	$(call AFTER_BUILD)
	$(call BINPACK_SIGN,general.xml)
endif

.PHONY: file-cmds

endif # ($(MEMO_TARGET),darwin-\*)
