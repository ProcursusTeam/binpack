ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS  += less
LESS_VERSION := 590

less-setup: setup
	$(call DOWNLOAD_FILES,$(BUILD_SOURCE),http://www.greenwoodsoftware.com/less/less-$(LESS_VERSION).tar.gz)
	$(call EXTRACT_TAR,less-$(LESS_VERSION).tar.gz,less-$(LESS_VERSION),less)

ifneq ($(wildcard $(BUILD_WORK)/less/.build_complete),)
less:
	@echo "Using previously built less."
else
less: less-setup
	cd $(BUILD_WORK)/less && ./configure -C \
		$(DEFAULT_CONFIGURE_FLAGS) \
		CFLAGS="$(CFLAGS) -Wno-implicit-function-declaration" \
		LDFLAGS="$(CFLAGS) $(LDFLAGS)"
	+$(MAKE) -C $(BUILD_WORK)/less
	+$(MAKE) -C $(BUILD_WORK)/less install \
		DESTDIR="$(BUILD_STAGE)/less"
	$(LN_S) less $(BUILD_STAGE)/less/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/more
	rm -f $(BUILD_STAGE)/less/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/less{key,echo}
	$(call AFTER_BUILD)
	$(call BINPACK_SIGN,general.xml)
endif

.PHONY: less
