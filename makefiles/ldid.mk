ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS  += ldid
LDID_VERSION := 2.1.5-procursus2

ldid-setup: setup
	$(call GITHUB_ARCHIVE,ProcursusTeam,ldid,$(LDID_VERSION),v$(LDID_VERSION))
	$(call EXTRACT_TAR,ldid-$(LDID_VERSION).tar.gz,ldid-$(LDID_VERSION),ldid)
	mkdir -p $(BUILD_STAGE)/ldid/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin
	[ ! -e $(BUILD_WORK)/ldid/ldid-arm64_32.patch.done ] && patch -p1 -d $(BUILD_WORK)/ldid < $(BUILD_ROOT)/patches/ldid-arm64_32.patch && touch $(BUILD_WORK)/ldid/ldid-arm64_32.patch.done

ifneq ($(wildcard $(BUILD_WORK)/ldid/.build_complete),)
ldid:
	@echo "Using previously built ldid."
else
ldid: ldid-setup openssl libplist
	$(CC) -c $(CFLAGS) -I$(BUILD_WORK)/ldid -o $(BUILD_WORK)/ldid/lookup2.o $(BUILD_WORK)/ldid/lookup2.c
	$(CXX) -std=c++11 $(CXXFLAGS) -I$(BUILD_WORK)/ldid -DLDID_VERSION=\"$(LDID_VERSION)\" \
		-o $(BUILD_STAGE)/ldid/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/ldid \
		$(BUILD_WORK)/ldid/lookup2.o $(BUILD_WORK)/ldid/ldid.cpp \
		$(LDFLAGS) -lcrypto -lplist-2.0
	$(call AFTER_BUILD)
	$(call BINPACK_SIGN,general.xml)
endif

.PHONY: ldid
