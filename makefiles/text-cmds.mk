ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

ifeq (,$(findstring darwin,$(MEMO_TARGET)))

SUBPROJECTS       += text-cmds
TEXT-CMDS_VERSION := 106

text-cmds-setup: setup binpack-setup
	wget -q -nc -P $(BUILD_SOURCE) https://opensource.apple.com/tarballs/text_cmds/text_cmds-$(TEXT-CMDS_VERSION).tar.gz
	$(call EXTRACT_TAR,text_cmds-$(TEXT-CMDS_VERSION).tar.gz,text_cmds-$(TEXT-CMDS_VERSION),text-cmds)
	sed -i 's|/usr|$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)|' $(BUILD_WORK)/text-cmds/ee/ee.c
	mkdir -p $(BUILD_STAGE)/text-cmds/$(MEMO_PREFIX){/sbin,$(MEMO_SUB_PREFIX)/bin}

ifneq ($(wildcard $(BUILD_WORK)/text-cmds/.build_complete),)
text-cmds:
	@echo "Using previously built text-cmds."
else
text-cmds: text-cmds-setup
	-cd $(BUILD_WORK)/text-cmds; \
	for bin in ee md5; do \
		case $$bin in \
			ee) EXTRAFLAGS="-lncurses";; \
			md5) EXTRAFLAGS="$(BUILD_WORK)/text-cmds/md5/commoncrypto.c";; \
		esac; \
		$(CC) $(CFLAGS) $(LDFLAGS) -o $(BUILD_STAGE)/text-cmds/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/$$bin $$bin/$$bin.c $$EXTRAFLAGS -DHAS_NCURSES -DHAS_UNISTD -DHAS_STDARG -DHAS_STDLIB -DHAS_SYS_WAIT; \
	done
	mv $(BUILD_STAGE)/text-cmds/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/md5 $(BUILD_STAGE)/text-cmds/$(MEMO_PREFIX)/sbin/md5
	for cmd in rmd160 sha1 sha256; do \
		$(LN_S) md5 $(BUILD_STAGE)/text-cmds/$(MEMO_PREFIX)/sbin/$$cmd; \
	done
	$(call AFTER_BUILD)
	$(call BINPACK_SIGN,general.xml)
endif

.PHONY: text-cmds

endif # ($(MEMO_TARGET),darwin-\*)
