ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS         += trustcache
TRUSTCACHE_VERSION  := 2.0

trustcache-setup: setup
	$(call GITHUB_ARCHIVE,CRKatri,trustcache,$(TRUSTCACHE_VERSION),v$(TRUSTCACHE_VERSION))
	$(call EXTRACT_TAR,trustcache-$(TRUSTCACHE_VERSION).tar.gz,trustcache-$(TRUSTCACHE_VERSION),trustcache)

ifneq ($(wildcard $(BUILD_WORK)/trustcache/.build_complete),)
trustcache:
	@echo "Using previously built trustcache."
else
trustcache: trustcache-setup libmd
	+$(MAKE) -C $(BUILD_WORK)/trustcache install \
		PREFIX="$(BUILD_STAGE)/trustcache/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)"
	$(call AFTER_BUILD)
	$(call BINPACK_SIGN,general.xml)
endif

.PHONY: trustcache
