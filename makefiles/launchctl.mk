ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

ifeq (,$(findstring darwin,$(MEMO_TARGET)))

STRAPPROJECTS     += launchctl
LAUNCHCTL_VERSION := 1.0.1

launchctl-setup: binpack-setup
	$(call GITHUB_ARCHIVE,ProcursusTeam,launchctl,$(LAUNCHCTL_VERSION),v$(LAUNCHCTL_VERSION))
	$(call EXTRACT_TAR,launchctl-$(LAUNCHCTL_VERSION).tar.gz,launchctl-$(LAUNCHCTL_VERSION),launchctl)

ifneq ($(wildcard $(BUILD_WORK)/launchctl/.build_complete),)
launchctl:
	@echo "Using previously built launchctl."
else
launchctl: launchctl-setup
	mkdir -p $(BUILD_STAGE)/launchctl/$(MEMO_PREFIX)/bin
	$(MAKE) -C $(BUILD_WORK)/launchctl install \
		PREFIX="$(MEMO_PREFIX)" \
		DESTDIR="$(BUILD_STAGE)/launchctl"
	$(call AFTER_BUILD)
	$(call BINPACK_SIGN,launchctl.xml)
endif

.PHONY: launchctl

endif
