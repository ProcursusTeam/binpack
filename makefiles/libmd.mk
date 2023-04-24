ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS   += libmd
LIBMD_VERSION := 1.0.4
DEB_LIBMD_V   ?= $(LIBMD_VERSION)

libmd-setup: setup
	$(call DOWNLOAD_FILES,$(BUILD_SOURCE),https://archive.hadrons.org/software/libmd/libmd-$(LIBMD_VERSION).tar.xz)
	$(call EXTRACT_TAR,libmd-$(LIBMD_VERSION).tar.xz,libmd-$(LIBMD_VERSION),libmd)
	sed -i 's|_MSC_VER|__APPLE__|' $(BUILD_WORK)/libmd/src/local-link.h

ifneq ($(wildcard $(BUILD_WORK)/libmd/.build_complete),)
libmd:
	@echo "Using previously built libmd."
else
libmd: libmd-setup
	cd $(BUILD_WORK)/libmd && ./configure -C \
		$(DEFAULT_CONFIGURE_FLAGS) \
		--disable-shared
	+$(MAKE) -C $(BUILD_WORK)/libmd
	+$(MAKE) -C $(BUILD_WORK)/libmd install \
		DESTDIR=$(BUILD_STAGE)/libmd
	$(call AFTER_BUILD,copy)
endif

.PHONY: libmd
