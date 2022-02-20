ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

ifeq (,$(findstring darwin,$(MEMO_TARGET)))

STRAPPROJECTS     += libxcrypt
LIBXCRYPT_VERSION := 4.4.27

libxcrypt-setup: setup
	$(call GITHUB_ARCHIVE,besser82,libxcrypt,$(LIBXCRYPT_VERSION),v$(LIBXCRYPT_VERSION))
	$(call EXTRACT_TAR,libxcrypt-$(LIBXCRYPT_VERSION).tar.gz,libxcrypt-$(LIBXCRYPT_VERSION),libxcrypt)

ifneq ($(wildcard $(BUILD_WORK)/libxcrypt/.build_complete),)
libxcrypt:
	@echo "Using previously built libxcrypt."
else
libxcrypt: libxcrypt-setup
	cd $(BUILD_WORK)/libxcrypt && autoreconf -iv
	cd $(BUILD_WORK)/libxcrypt && ./configure -C \
		$(DEFAULT_CONFIGURE_FLAGS) \
		--disable-shared \
		CFLAGS="$(patsubst -flto=thin,,$(CFLAGS))" \
		LDFLAGS="$(patsubst -flto=thin,,$(LDFLAGS))"
	# LTO is disabled here because it will build but not work if compiled with LTO.
	+$(MAKE) -C $(BUILD_WORK)/libxcrypt
	+$(MAKE) -C $(BUILD_WORK)/libxcrypt install \
		DESTDIR=$(BUILD_STAGE)/libxcrypt
	$(call AFTER_BUILD,copy)
endif

.PHONY: libxcrypt

endif # ($(MEMO_TARGET),darwin-\*)
