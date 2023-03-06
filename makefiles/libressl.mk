ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS       += libressl
LIBRESSL_VERSION  := 3.7.0

libressl-setup: setup
	$(call DOWNLOAD_FILES,$(BUILD_SOURCE),https://ftp.openbsd.org/pub/OpenBSD/LibreSSL/libressl-$(LIBRESSL_VERSION).tar.gz{$(comma).asc})
	$(call PGP_VERIFY,libressl-$(LIBRESSL_VERSION).tar.gz,asc)
	$(call EXTRACT_TAR,libressl-$(LIBRESSL_VERSION).tar.gz,libressl-$(LIBRESSL_VERSION),libressl)

ifneq ($(wildcard $(BUILD_WORK)/libressl/.build_complete),)
libressl:
	@echo "Using previously built libressl."
else
libressl: libressl-setup
	cd $(BUILD_WORK)/libressl && ./configure \
		$(DEFAULT_CONFIGURE_FLAGS) \
		--disable-shared
	+$(MAKE) -C $(BUILD_WORK)/libressl
	+$(MAKE) -C $(BUILD_WORK)/libressl install \
		DESTDIR="$(BUILD_STAGE)/libressl"
	$(call AFTER_BUILD,copy)
endif

.PHONY: libressl
