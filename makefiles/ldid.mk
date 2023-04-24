ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS  += ldid
LDID_VERSION := 2.1.5-procursus7

ldid-setup: setup
	$(call GITHUB_ARCHIVE,ProcursusTeam,ldid,$(LDID_VERSION),v$(LDID_VERSION))
	$(call EXTRACT_TAR,ldid-$(LDID_VERSION).tar.gz,ldid-$(LDID_VERSION),ldid)
	mkdir -p $(BUILD_STAGE)/ldid/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin

ifneq ($(wildcard $(BUILD_WORK)/ldid/.build_complete),)
ldid:
	@echo "Using previously built ldid."
else
ldid: ldid-setup libplist libressl
	+$(MAKE) -C $(BUILD_WORK)/ldid install \
		PREFIX="$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)" \
		VERSION="$(LDID_VERSION)" \
		DESTDIR="$(BUILD_STAGE)/ldid" \
		LIBPLIST_INCLUDES="-I$(BUILD_BASE)/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/include" \
		LIBPLIST_LIBS="-L$(BUILD_BASE)/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib -lplist-2.0" \
		LIBCRYPTO_INCLUDES="-I$(BUILD_BASE)/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/include" \
		LIBCRYPTO_LIBS="-L$(BUILD_BASE)/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib -lcrypto"
	$(call AFTER_BUILD)
	$(call BINPACK_SIGN,general.xml)
endif

.PHONY: ldid
