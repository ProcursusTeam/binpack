ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS        += iokittools
IOKITTOOLS_VERSION := 91

iokittools-setup: setup
	$(call DOWNLOAD_FILES,$(BUILD_SOURCE),https://opensource.apple.com/tarballs/IOKitTools/IOKitTools-$(IOKITTOOLS_VERSION).tar.gz)
	$(call EXTRACT_TAR,IOKitTools-$(IOKITTOOLS_VERSION).tar.gz,IOKitTools-$(IOKITTOOLS_VERSION),iokittools)
	mkdir -p $(BUILD_STAGE)/iokittools/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/sbin
	mkdir -p $(BUILD_WORK)/iokittools/include/IOKit
	wget -q -nc -P $(BUILD_WORK)/iokittools/include/IOKit \
		https://opensource.apple.com/source/IOKitUser/IOKitUser-1726.11.1/IOKitLibPrivate.h

ifneq ($(wildcard $(BUILD_WORK)/iokittools/.build_complete),)
iokittools:
	@echo "Using previously built iokittools."
else
iokittools: iokittools-setup
	$(CC) $(CFLAGS) -isystem $(BUILD_WORK)/iokittools/include -o $(BUILD_STAGE)/iokittools/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/sbin/ioreg $(BUILD_WORK)/iokittools/ioreg.tproj/ioreg.c -framework IOKit -framework CoreFoundation -lncurses
	$(call AFTER_BUILD)
	$(call BINPACK_SIGN,general.xml)
endif

.PHONY: iokittools
