ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

ifeq (,$(findstring darwin,$(MEMO_TARGET)))

STRAPPROJECTS       += system-cmds
SYSTEM-CMDS_VERSION := 854.40.2

system-cmds-setup: setup libxcrypt
	wget -q -nc -P $(BUILD_SOURCE) https://opensource.apple.com/tarballs/system_cmds/system_cmds-$(SYSTEM-CMDS_VERSION).tar.gz
	$(call EXTRACT_TAR,system_cmds-$(SYSTEM-CMDS_VERSION).tar.gz,system_cmds-$(SYSTEM-CMDS_VERSION),system-cmds)
	$(call DO_PATCH,system-cmds,system-cmds,-p1)
	sed -i '/#include <stdio.h>/a #include <crypt.h>' $(BUILD_WORK)/system-cmds/login.tproj/login.c
	sed -i '1 i\#include\ <libiosexec.h>' $(BUILD_WORK)/system-cmds/login.tproj/login.c
	sed -i -E -e 's|"/usr|"$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)|g' -e 's|"/sbin|"$(MEMO_PREFIX)/sbin|g' \
		$(BUILD_WORK)/system-cmds/shutdown.tproj/pathnames.h
	wget -q -nc -P $(BUILD_WORK)/system-cmds/include \
		https://opensource.apple.com/source/launchd/launchd-328/launchd/src/reboot2.h

ifneq ($(wildcard $(BUILD_WORK)/system-cmds/.build_complete),)
system-cmds:
	@echo "Using previously built system-cmds."
else
system-cmds: system-cmds-setup libxcrypt
	TOOLS="arch dmesg hostinfo login ltop passwd shutdown sync sysctl taskpolicy "; \
	if [ "$(shell echo $(MEMO_TARGET) | cut -d- -f1)" != "watchos" ]; then \
		TOOLS+="lsmp "; \
	fi; \
	if [ "$(MEMO_TARGET)" != "watchos-armv7k" ]; then \
		TOOLS+="sc_usage "; \
	fi; \
	cd $(BUILD_WORK)/system-cmds; \
	for tool in $$TOOLS; do \
		EXTRA=; \
		case $${tool} in \
			arch) EXTRA="-framework CoreFoundation";; \
			passwd) EXTRA="-lcrypt";; \
			shutdown) EXTRA="-lbsm -framework IOKit";; \
			sc_usage) EXTRA="-lncurses";; \
		esac; \
		echo "$${tool}"; \
		$(CC) $(CFLAGS) $(LDFLAGS) $$EXTRA -Iinclude -I$${tool}.tproj $${tool}.tproj/*.c -o $${tool} -DPRIVATE; \
	done
	mkdir -p $(BUILD_STAGE)/system-cmds/$(MEMO_PREFIX){/{s,}bin,$(MEMO_SUB_PREFIX)/{s,}bin}
	[ -e $(BUILD_WORK)/system-cmds/lsmp ] && install -m 755 $(BUILD_WORK)/system-cmds/lsmp $(BUILD_STAGE)/system-cmds/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/ || true
	[ -e $(BUILD_WORK)/system-cmds/sc_usage ] && install -m 755 $(BUILD_WORK)/system-cmds/sc_usage $(BUILD_STAGE)/system-cmds/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/ || true
	install -m 755 $(BUILD_WORK)/system-cmds/{arch,hostinfo,login,passwd} $(BUILD_STAGE)/system-cmds/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/
	install -m 755 $(BUILD_WORK)/system-cmds/sync $(BUILD_STAGE)/system-cmds/$(MEMO_PREFIX)/bin/
	install -m 755 $(BUILD_WORK)/system-cmds/{sysctl,ltop,taskpolicy} $(BUILD_STAGE)/system-cmds/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/sbin/
	install -m 755 $(BUILD_WORK)/system-cmds/{dmesg,shutdown} $(BUILD_STAGE)/system-cmds/$(MEMO_PREFIX)/sbin/
	$(call AFTER_BUILD)
	$(call BINPACK_SIGN,general.xml)
	-$(LDID) -S$(BUILD_MISC)/entitlements/lsmp.xml $(BUILD_STAGE)/system-cmds/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/lsmp
	$(LDID) -S$(BUILD_MISC)/entitlements/taskpolicy.xml $(BUILD_STAGE)/system-cmds/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/sbin/taskpolicy
	find $(BUILD_STAGE)/system-cmds -name '.ldid*' -type f -delete
	chmod u+s $(BUILD_STAGE)/system-cmds/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/{login,passwd}
endif

.PHONY: system-cmds

endif # ($(MEMO_TARGET),darwin-\*)
