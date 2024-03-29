ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

ifeq (,$(findstring darwin,$(MEMO_TARGET)))

STRAPPROJECTS       += system-cmds
ifeq ($(shell [ "$(CFVER_WHOLE)" -lt 1700 ] && echo 1),1)
SYSTEM-CMDS_VERSION := 854.40.2
else ifeq ($(shell [ "$(CFVER_WHOLE)" -lt 1800 ] && echo 1),1)
SYSTEM-CMDS_VERSION := 880.60.2
else
SYSTEM-CMDS_VERSION := 950
endif

system-cmds-setup: setup libxcrypt
	$(call GITHUB_ARCHIVE,apple-oss-distributions,system_cmds,$(SYSTEM-CMDS_VERSION),system_cmds-$(SYSTEM-CMDS_VERSION))
	$(call EXTRACT_TAR,system_cmds-$(SYSTEM-CMDS_VERSION).tar.gz,system_cmds-system_cmds-$(SYSTEM-CMDS_VERSION),system-cmds)
ifeq ($(shell [ "$(CFVER_WHOLE)" -lt 1800 ] && echo 1),1)
	$(call DO_PATCH,system-cmds,system-cmds,-p1)
else
	$(call DO_PATCH,system-cmds-ios15,system-cmds,-p1)
endif
	sed -i '/#include <stdio.h>/a #include <crypt.h>' $(BUILD_WORK)/system-cmds/login.tproj/login.c
	sed -i -E -e 's|"/usr|"$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)|g' -e 's|"/sbin|"$(MEMO_PREFIX)/sbin|g' \
		$(BUILD_WORK)/system-cmds/shutdown.tproj/pathnames.h
	wget -q -nc -P $(BUILD_WORK)/system-cmds/include \
		https://opensource.apple.com/source/launchd/launchd-328/launchd/src/reboot2.h

ifneq ($(wildcard $(BUILD_WORK)/system-cmds/.build_complete),)
system-cmds:
	@echo "Using previously built system-cmds."
else
system-cmds: system-cmds-setup libxcrypt
	TOOLS="arch dmesg hostinfo ltop pwd_mkdb reboot shutdown sync sysctl taskpolicy sc_usage fs_usage "; \
	if [ "$(shell echo $(MEMO_TARGET) | cut -d- -f1)" != "watchos" ]; then \
		TOOLS+="lsmp"; \
	fi; \
	cd $(BUILD_WORK)/system-cmds; \
	for tool in $$TOOLS; do \
		EXTRA=; \
		case $${tool} in \
			arch) EXTRA="-framework CoreFoundation";; \
			shutdown) EXTRA="-lbsm -framework IOKit";; \
			sc_usage) EXTRA="-lncurses";; \
			pwd_mkdb) EXTRA="-D_PW_NAME_LEN=MAXLOGNAME -D_PW_YPTOKEN=\"__YP!\"";; \
			fs_usage) EXTRA="$(BUILD_MISC)/PrivateFrameworks/ktrace.framework/ktrace.tbd";; \
		esac; \
		echo "$${tool}"; \
		$(CC) $(CFLAGS) $$EXTRA -Iinclude -I$${tool}.tproj $${tool}.tproj/*.c -r -nostdlib -o $${tool}.lo -DPRIVATE; \
	done; \
	$(CC) $(CFLAGS) $(LDFLAGS) -Iinclude -Ilogin.tproj login.tproj/*.c -o login -DPRIVATE; \
	$(CC) $(CFLAGS) $(LDFLAGS) -lcrypt -Iinclude -Ipasswd.tproj passwd.tproj/*.c -o passwd -DPRIVATE
	mkdir -p $(BUILD_STAGE)/system-cmds/$(MEMO_PREFIX){/{s,}bin,$(MEMO_SUB_PREFIX)/{s,}bin}
	[ -e $(BUILD_WORK)/system-cmds/lsmp.lo ] && install $(BUILD_WORK)/system-cmds/lsmp.lo $(BUILD_STAGE)/system-cmds/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/ || true
	[ -e $(BUILD_WORK)/system-cmds/sc_usage.lo ] && install $(BUILD_WORK)/system-cmds/sc_usage.lo $(BUILD_STAGE)/system-cmds/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/ || true
	[ -e $(BUILD_WORK)/system-cmds/fs_usage.lo ] && install $(BUILD_WORK)/system-cmds/fs_usage.lo $(BUILD_STAGE)/system-cmds/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/ || true
	install $(BUILD_WORK)/system-cmds/{arch,hostinfo}.lo $(BUILD_STAGE)/system-cmds/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/
	install -m 755 $(BUILD_WORK)/system-cmds/{login,passwd} $(BUILD_STAGE)/system-cmds/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/
	install $(BUILD_WORK)/system-cmds/sync.lo $(BUILD_STAGE)/system-cmds/$(MEMO_PREFIX)/bin/
	install $(BUILD_WORK)/system-cmds/{pwd_mkdb,sysctl,ltop,taskpolicy}.lo $(BUILD_STAGE)/system-cmds/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/sbin/
	install $(BUILD_WORK)/system-cmds/{dmesg,reboot,shutdown}.lo $(BUILD_STAGE)/system-cmds/$(MEMO_PREFIX)/sbin/
	$(call SETUP_STUBS)
	$(call AFTER_BUILD)
	#$(call BINPACK_SIGN,general.xml)
	#-$(LDID) -S$(BUILD_MISC)/entitlements/lsmp.xml $(BUILD_STAGE)/system-cmds/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/lsmp
	#-$(LDID) -S$(BUILD_MISC)/entitlements/fs_usage.plist $(BUILD_STAGE)/system-cmds/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/fs_usage
	-$(LDID) -S$(BUILD_MISC)/entitlements/passwd.plist $(BUILD_STAGE)/system-cmds/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/passwd
	-$(LDID) -S$(BUILD_MISC)/entitlements/general.xml $(BUILD_STAGE)/system-cmds/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/login
	#$(LDID) -S$(BUILD_MISC)/entitlements/taskpolicy.xml $(BUILD_STAGE)/system-cmds/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/sbin/taskpolicy
	#find $(BUILD_STAGE)/system-cmds -name '.ldid*' -type f -delete
	chmod u+s $(BUILD_STAGE)/system-cmds/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/{login,passwd}
endif

.PHONY: system-cmds

endif # ($(MEMO_TARGET),darwin-\*)
