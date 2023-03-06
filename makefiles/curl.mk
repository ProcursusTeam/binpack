ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS  += curl
CURL_VERSION := 136.80.2

curl-setup: setup
	$(call GITHUB_ARCHIVE,apple-oss-distributions,curl,$(CURL_VERSION),curl-$(CURL_VERSION))
	$(call EXTRACT_TAR,curl-$(CURL_VERSION).tar.gz,curl-curl-$(CURL_VERSION),curl)

ifneq ($(wildcard $(BUILD_WORK)/curl/.build_complete),)
curl:
	@echo "Using previously built curl."
else
curl: curl-setup
	cd $(BUILD_WORK)/curl/curl && autoreconf -vi
	cd $(BUILD_WORK)/curl/curl && ./configure -C \
		$(DEFAULT_CONFIGURE_FLAGS) \
		--disable-shared \
		--with-secure-transport \
		--disable-alt-svc \
		--disable-ares \
		--disable-cookies \
		--disable-crypto-auth \
		--disable-dateparse \
		--disable-dnsshuffle \
		--disable-doh \
		--disable-get-easy-options \
		--disable-hsts \
		--disable-http-auth \
		--disable-libcurl-option \
		--disable-manual \
		--disable-netrc \
		--disable-ntlm-wb \
		--disable-progress-meter \
		--disable-proxy \
		--disable-pthreads \
		--disable-socketpair \
		--disable-threaded-resolver \
		--disable-tls-srp \
		--disable-versioned-symbols \
		--disable-verbose \
		--disable-rtsp \
		--disable-dict \
		--disable-file \
		--disable-ftp \
		--disable-gopher \
		--disable-imap \
		--disable-mqtt \
		--disable-pop3 \
		--disable-smtp \
		--disable-telnet \
		--disable-tftp \
		--disable-headers-api \
		--enable-symbol-hiding \
		--without-brotli \
		--without-libpsl \
		--without-nghttp2 \
		--without-ngtcp2 \
		--without-zstd \
		--without-libidn2 \
		--without-librtmp
	+$(MAKE) -C $(BUILD_WORK)/curl/curl
	+$(MAKE) -C $(BUILD_WORK)/curl/curl install \
		DESTDIR="$(BUILD_STAGE)/curl"
	rm -f $(BUILD_STAGE)/curl/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/curl-config
	$(call AFTER_BUILD)
	$(call BINPACK_SIGN,general.xml)
endif

.PHONY: curl
