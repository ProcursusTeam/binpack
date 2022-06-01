ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS += tc
TC_VERSION  := 1.0

tc-setup: setup
	$(call GITHUB_ARCHIVE,CRKatri,tc,$(TC_VERSION),v$(TC_VERSION))
	$(call EXTRACT_TAR,tc-$(TC_VERSION).tar.gz,tc-$(TC_VERSION),tc)

ifneq ($(wildcard $(BUILD_WORK)/tc/.build_complete),)
tc:
	@echo "Using previously built tc."
else
tc: tc-setup
	+$(MAKE) -C $(BUILD_WORK)/tc install \
		PREFIX="$(BUILD_STAGE)/tc/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)"
	$(call AFTER_BUILD)
	$(call BINPACK_SIGN,general.xml)
endif

.PHONY: tc
