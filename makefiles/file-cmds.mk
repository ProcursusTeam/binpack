ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

ifeq (,$(findstring darwin,$(MEMO_TARGET)))

STRAPPROJECTS     += file-cmds
# Don't upgrade file-cmds, as any future version includes APIs introduced in iOS 13+.
ifeq ($(shell [ "$(CFVER_WHOLE)" -lt 1600 ] && echo 1),1)
FILE-CMDS_VERSION := 272.250.1
else
FILE-CMDS_VERSION := 287.40.2
endif

file-cmds-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://opensource.apple.com/tarballs/file_cmds/file_cmds-$(FILE-CMDS_VERSION).tar.gz
	$(call EXTRACT_TAR,file_cmds-$(FILE-CMDS_VERSION).tar.gz,file_cmds-$(FILE-CMDS_VERSION),file-cmds)
	mkdir -p $(BUILD_STAGE)/file-cmds/$(MEMO_PREFIX){/sbin,$(MEMO_SUB_PREFIX)/bin}

ifneq ($(wildcard $(BUILD_WORK)/file-cmds/.build_complete),)
file-cmds:
	@echo "Using previously built file-cmds."
else
file-cmds: file-cmds-setup
	$(CC) $(CFLAGS) $(LDFLAGS) -o $(BUILD_STAGE)/file-cmds/$(MEMO_PREFIX)/sbin/mknod $(BUILD_WORK)/file-cmds/mknod/mknod.c
	$(CC) $(CFLAGS) $(LDFLAGS) -o $(BUILD_STAGE)/file-cmds/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/chflags $(BUILD_WORK)/file-cmds/chflags/chflags.c
	$(call AFTER_BUILD)
	$(call BINPACK_SIGN,general.xml)
endif

.PHONY: file-cmds

endif # ($(MEMO_TARGET),darwin-\*)
