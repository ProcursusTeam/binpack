ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

ifeq (,$(findstring darwin,$(MEMO_TARGET)))

SUBPROJECTS        += kext-tools
KEXT_TOOLS_VERSION := 721

KEXT_TOOLS_CFLAGS := kext_tools_util.o Shims.o -framework IOKit -framework CoreFoundation -DPRIVATE -D__OS_EXPOSE_INTERNALS__ -DEMBEDDED_HOST

kext-tools-setup: setup
	$(call GITHUB_ARCHIVE,apple-oss-distributions,kext_tools,$(KEXT_TOOLS_VERSION),kext_tools-$(KEXT_TOOLS_VERSION))
	$(call EXTRACT_TAR,kext_tools-$(KEXT_TOOLS_VERSION).tar.gz,kext_tools-kext_tools-$(KEXT_TOOLS_VERSION),kext-tools)
	$(call DO_PATCH,kext-tools,kext-tools,-p1)
	mkdir -p $(BUILD_STAGE)/kext-tools/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/sbin

ifneq ($(wildcard $(BUILD_WORK)/kext-tools/.build_complete),)
kext-tools:
	@echo "Using previously built kext-tools."
else
kext-tools: kext-tools-setup
	cd $(BUILD_WORK)/kext-tools && \
	$(CC) $(CFLAGS) -c kext_tools_util.c KernelManagementShims/Shims.m -DPRIVATE -D__OS_EXPOSE_INTERNALS__ -DEMBEDDED_HOST && echo kext_tools_util.o; \
	$(CC) $(CFLAGS) -c KernelManagementShims/Shims.m -DPRIVATE -D__OS_EXPOSE_INTERNALS__ -DEMBEDDED_HOST && echo Shims.o; \
	$(CC) $(CFLAGS) $(KEXT_TOOLS_CFLAGS) kextstat_main.c -r -nostdlib -o $(BUILD_STAGE)/kext-tools/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/sbin/kextstat.lo && echo kextstat
	$(call SETUP_STUBS)
	$(call AFTER_BUILD)
	#$(LDID) -S$(BUILD_MISC)/entitlements/kextstat.plist $(BUILD_STAGE)/kext-tools/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/sbin/kextstat
	#find $(BUILD_STAGE)/kext-tools -name '.ldid*' -type f -delete
endif

.PHONY: kext-tools

endif
