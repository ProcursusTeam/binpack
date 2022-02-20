ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

STRAPPROJECTS += bzip2
BZIP2_VERSION := 1.0.8

bzip2-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://sourceware.org/pub/bzip2/bzip2-$(BZIP2_VERSION).tar.gz{,.sig}
	$(call PGP_VERIFY,bzip2-$(BZIP2_VERSION).tar.gz)
	$(call EXTRACT_TAR,bzip2-$(BZIP2_VERSION).tar.gz,bzip2-$(BZIP2_VERSION),bzip2)
	mkdir -p $(BUILD_STAGE)/bzip2/$(MEMO_PREFIX)/{bin,$(MEMO_SUB_PREFIX)/share}

ifneq ($(wildcard $(BUILD_WORK)/bzip2/.build_complete),)
bzip2:
	@echo "Using previously built bzip2."
else
bzip2: bzip2-setup
	+$(MAKE) -C $(BUILD_WORK)/bzip2 install \
		PREFIX=$(BUILD_STAGE)/bzip2/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX) \
		CC=$(CC) \
		AR=$(AR) \
		RANLIB=$(RANLIB) \
		CFLAGS="$(CFLAGS)"
	mv $(BUILD_STAGE)/bzip2/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/man $(BUILD_STAGE)/bzip2/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/share
	rm -rf $(BUILD_STAGE)/bzip2/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/{lib,include}
	rm -f $(BUILD_STAGE)/bzip2/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/bz{cmp,egrep,fgrep,less}
	$(call AFTER_BUILD)
	$(call BINPACK_SIGN,general.xml)
endif

.PHONY: bzip2
