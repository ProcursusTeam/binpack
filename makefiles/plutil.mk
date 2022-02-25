ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS     += plutil
PLUTIL_VERSION  := 0.2.2

plutil-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://github.com/Diatrus/plutil/releases/download/v$(PLUTIL_VERSION)/plutil-$(PLUTIL_VERSION).tar.xz
	$(call EXTRACT_TAR,plutil-$(PLUTIL_VERSION).tar.xz,plutil-$(PLUTIL_VERSION),plutil)
	sed -i '/ldid/d' $(BUILD_WORK)/plutil/Makefile

ifneq ($(wildcard $(BUILD_WORK)/plutil/.build_complete),)
plutil:
	@echo "Using previously built plutil."
else
plutil: plutil-setup
	+$(MAKE) -C $(BUILD_WORK)/plutil install \
		CC="$(CC)" \
		DESTDIR="$(BUILD_STAGE)/plutil/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)"
	$(call AFTER_BUILD)
	$(call BINPACK_SIGN,general.xml)
endif

.PHONY: plutil
