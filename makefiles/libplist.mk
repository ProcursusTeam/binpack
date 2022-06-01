ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS       += libplist
LIBPLIST_VERSION  := 2.2.0

libplist-setup: setup
	$(call GITHUB_ARCHIVE,libimobiledevice,libplist,$(LIBPLIST_VERSION),$(LIBPLIST_VERSION))
	$(call EXTRACT_TAR,libplist-$(LIBPLIST_VERSION).tar.gz,libplist-$(LIBPLIST_VERSION),libplist)

ifneq ($(wildcard $(BUILD_WORK)/libplist/.build_complete),)
libplist:
	@echo "Using previously built libplist."
else
libplist: libplist-setup
	cd $(BUILD_WORK)/libplist && ./autogen.sh \
		$(DEFAULT_CONFIGURE_FLAGS) \
		--disable-shared \
		--without-cython
	+$(MAKE) -C $(BUILD_WORK)/libplist
	+$(MAKE) -C $(BUILD_WORK)/libplist install \
		DESTDIR="$(BUILD_STAGE)/libplist"
	$(call AFTER_BUILD,copy)
endif

.PHONY: libplist
