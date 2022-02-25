ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS    += toybox
TOYBOX_VERSION := 0.8.6

toybox-setup: setup
	$(call GITHUB_ARCHIVE,landley,toybox,$(TOYBOX_VERSION),$(TOYBOX_VERSION))
	$(call EXTRACT_TAR,toybox-$(TOYBOX_VERSION).tar.gz,toybox-$(TOYBOX_VERSION),toybox)
	sed -i s/utmp.h/utmpx.h/g $(BUILD_WORK)/toybox/toys/pending/last.c
	sed -i 's|struct utmp|struct utmpx|g' $(BUILD_WORK)/toybox/toys/pending/last.c
	sed -i 's|syscall(__NR_|syscall(|g' $(BUILD_WORK)/toybox/toys/other/ionice.c
	sed -i 's|UT_LINESIZE|_UTX_LINESIZE|g' $(BUILD_WORK)/toybox/toys/pending/last.c
	sed -i -e 's/-Wl,--gc-sections//g' -e 's/-Wl,--as-needed//g' $(BUILD_WORK)/toybox/configure
ifeq ($(BINPACK_THICK),1)
	cp -a $(BUILD_ROOT)/toybox-thick-config $(BUILD_WORK)/toybox/.config
else
	cp -a $(BUILD_ROOT)/toybox-config $(BUILD_WORK)/toybox/.config
endif
	mkdir -p $(BUILD_STAGE)/toybox/$(MEMO_PREFIX){$(MEMO_SUB_PREFIX),}/{s,}bin

ifneq ($(wildcard $(BUILD_WORK)/toybox/.build_complete),)
toybox:
	@echo "Using previously built toybox."
else
ifeq ($(BINPACK_THICK),1)
toybox: toybox-setup openssl
else
toybox: toybox-setup
endif
	$(MAKE) -C $(BUILD_WORK)/toybox \
		HOSTCC="$(CC_FOR_BUILD)"
	$(INSTALL) -m755 $(BUILD_WORK)/toybox/toybox $(BUILD_STAGE)/toybox/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin
	for tool in bash sh echo cat chmod cp date dd hostname kill ln ls mkdir mv pwd rm rmdir sleep; do \
		$(LN_S) ../$(MEMO_SUB_PREFIX)/bin/toybox $(BUILD_STAGE)/toybox/$(MEMO_PREFIX)/bin/$$tool; \
	done
	for tool in clear cut du false find grep fgrep egrep gzip gunzip head hexdump hexedit id killall nohup printf pwd renice sed seq split stat tail tar tee time true uname w wc which xargs; do \
		$(LN_S) toybox $(BUILD_STAGE)/toybox/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/$$tool; \
	done
	$(LN_S) ../bin/toybox $(BUILD_STAGE)/toybox/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/sbin/chown
ifeq ($(BINPACK_THICK),1)
	for tool in expr link unlink; do \
		$(LN_S) ../$(MEMO_SUB_PREFIX)/bin/toybox $(BUILD_STAGE)/toybox/$(MEMO_PREFIX)/bin/$$tool; \
	done
	for tool in basename cal chgrp cmp diff base64 cksum comm cpio crc32 env expand getconf groups install last logger logname mkfifo nice nl od paste patch printenv readlink rev sort strings tftp touch tr uniq who whoami yes realpath md5sum sha1sum sha224sum sha256sum sha384sum sha512sum pidof test telnet truncate watch; do \
		$(LN_S) toybox $(BUILD_STAGE)/toybox/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/$$tool; \
	done
endif
	$(call AFTER_BUILD)
	$(call BINPACK_SIGN,dd.xml)
endif

.PHONY: toybox
