ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS += ksh
KSH_VERSION := 59c

ksh-setup: binpack-setup
	$(call DOWNLOAD_FILES,$(BUILD_SOURCE),http://www.mirbsd.org/MirOS/dist/mir/mksh/mksh-R$(KSH_VERSION).tgz)
	$(call EXTRACT_TAR,mksh-R$(KSH_VERSION).tgz,mksh,ksh)

ifneq ($(wildcard $(BUILD_WORK)/ksh/.build_complete),)
ksh:
	@echo "Using previously built ksh."
else
ksh: ksh-setup
	cd $(BUILD_WORK)/ksh; \
	TARGET_OS="Darwin" \
	CPPFLAGS="$(CPPFLAGS) -DMKSH_BINSHREDUCED -DMKSH_SMALL -DMKSH_BINSHPOSIX" \
		sh ./Build.sh
	install -d $(BUILD_STAGE)/ksh/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin
	install -d $(BUILD_STAGE)/ksh/$(MEMO_PREFIX)/bin
	install -m755 $(BUILD_WORK)/ksh/mksh $(BUILD_STAGE)/ksh/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/mksh
	$(LN_S) mksh $(BUILD_STAGE)/ksh/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/ksh
	$(LN_S) ../usr/bin/mksh $(BUILD_STAGE)/ksh/$(MEMO_PREFIX)/bin/ksh
	$(LN_S) ../usr/bin/mksh $(BUILD_STAGE)/ksh/$(MEMO_PREFIX)/bin/sh
	$(call AFTER_BUILD)
	$(call BINPACK_SIGN,general.xml)
endif

.PHONY: ksh
