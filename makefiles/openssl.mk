ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

STRAPPROJECTS   += openssl
OPENSSL_VERSION := 3.0.3

openssl-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://www.openssl.org/source/openssl-$(OPENSSL_VERSION).tar.gz{,.asc}
	$(call PGP_VERIFY,openssl-$(OPENSSL_VERSION).tar.gz,asc)
	$(call EXTRACT_TAR,openssl-$(OPENSSL_VERSION).tar.gz,openssl-$(OPENSSL_VERSION),openssl)

ifneq ($(wildcard $(BUILD_WORK)/openssl/.build_complete),)
openssl:
	@echo "Using previously built openssl."
else
openssl: openssl-setup
	touch $(BUILD_WORK)/openssl/Configurations/15-openssl.conf
	@echo -e "my %targets = (\n\
		\"darwin64-armv7k\" => {\n\
			inherit_from     => [ \"darwin-common\" ],\n\
			CC               => add(\"-Wall\"),\n\
			cflags           => add(\"-arch armv7k\"),\n\
			lib_cppflags     => add(\"-DL_ENDIAN\"),\n\
			perlasm_scheme   => \"ios32\",\n\
			disable          => [ \"async\" ],\n\
		},\n\
		\"darwin64-arm64_32\" => {\n\
			inherit_from     => [ \"darwin-common\" ],\n\
			CC               => add(\"-Wall\"),\n\
			cflags           => add(\"-arch arm64_32\"),\n\
			lib_cppflags     => add(\"-DL_ENDIAN\"),\n\
			perlasm_scheme   => \"ios64\",\n\
		},\n\
		\"darwin64-arm64e\" => {\n\
			inherit_from     => [ \"darwin64-arm64\" ],\n\
			CC               => add(\"-Wall\"),\n\
			cflags           => add(\"-arch arm64e\"),\n\
			perlasm_scheme   => \"ios64\",\n\
		},\n\
	);" > $(BUILD_WORK)/openssl/Configurations/15-openssl.conf
	cd $(BUILD_WORK)/openssl && ./Configure \
		--prefix=$(MEMO_PREFIX)$(MEMO_SUB_PREFIX) \
		--openssldir=$(MEMO_PREFIX)/etc/ssl \
		no-shared \
		no-tests \
		no-module \
		darwin64-$$(echo $(LLVM_TARGET) | cut -f1 -d-)
	+$(MAKE) -C $(BUILD_WORK)/openssl
	+$(MAKE) -C $(BUILD_WORK)/openssl install_sw \
		DESTDIR=$(BUILD_STAGE)/openssl
	$(call AFTER_BUILD,copy)
endif

.PHONY: openssl
