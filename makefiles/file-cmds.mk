ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

ifeq (,$(findstring darwin,$(MEMO_TARGET)))

STRAPPROJECTS     += file-cmds
FILE-CMDS_VERSION := 400

file-cmds-setup: setup binpack-setup
	$(call GITHUB_ARCHIVE,apple-oss-distributions,file_cmds,$(FILE-CMDS_VERSION),file_cmds-$(FILE-CMDS_VERSION))
	$(call EXTRACT_TAR,file_cmds-$(FILE-CMDS_VERSION).tar.gz,file_cmds-file_cmds-$(FILE-CMDS_VERSION),file-cmds)
	sed -i '/libutil.h/ s/$$/\nint expand_number(const char *buf, uint64_t *num);/' $(BUILD_WORK)/file-cmds/du/du.c
	rm $(BUILD_WORK)/file-cmds/dd/gen.c
	mkdir -p $(BUILD_STAGE)/file-cmds/$(MEMO_PREFIX){,$(MEMO_SUB_PREFIX)}/{,s}bin

ifneq ($(wildcard $(BUILD_WORK)/file-cmds/.build_complete),)
file-cmds:
	@echo "Using previously built file-cmds."
else
file-cmds: file-cmds-setup bzip2 xz
	$(CC) $(CFLAGS) $(LDFLAGS) -o $(BUILD_STAGE)/file-cmds/$(MEMO_PREFIX)/sbin/mknod $(BUILD_WORK)/file-cmds/mknod/{mknod,pack_dev}.c
	$(CC) $(CFLAGS) $(LDFLAGS) -o $(BUILD_STAGE)/file-cmds/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/chflags $(BUILD_WORK)/file-cmds/chflags/chflags.c
	$(CC) $(CFLAGS) $(LDFLAGS) -o $(BUILD_STAGE)/file-cmds/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/sbin/chown $(BUILD_WORK)/file-cmds/chown/chown.c
	for tool in chmod cp dd ln ls mkdir mv rm rmdir; do \
		EXTRA_CFLAGS=""; \
		if [ "$$tool" = "dd" ]; then \
			EXTRA_CFLAGS="-lutil"; \
		elif [ "$$tool" = "ls" ]; then \
			EXTRA_CFLAGS="-DCOLORLS -lutil -lncurses"; \
		fi; \
		$(CC) $(CFLAGS) $(LDFLAGS) $$EXTRA_CFLAGS -o $(BUILD_STAGE)/file-cmds/$(MEMO_PREFIX)/bin/$$tool $(BUILD_WORK)/file-cmds/$$tool/*.c -D'__FBSDID(x)=' -D__POSIX_C_SOURCE; \
	done
	for tool in du gzip stat; do \
		EXTRA_CFLAGS=""; \
		if [ "$$tool" = "du" ]; then \
			EXTRA_CFLAGS="-lutil"; \
		elif [ "$$tool" = "gzip" ]; then \
			EXTRA_CFLAGS='-DGZIP_APPLE_VERSION="321.40.3" -llzma -lz -lbz2'; \
		fi; \
		$(CC) $(CFLAGS) $(LDFLAGS) $$EXTRA_CFLAGS -o $(BUILD_STAGE)/file-cmds/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/$$tool $(BUILD_WORK)/file-cmds/$$tool/$$tool.c -D'__FBSDID(x)=' -D__POSIX_C_SOURCE; \
	done
	$(LN_S) gzip $(BUILD_STAGE)/file-cmds/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/gunzip
	$(CC) $(CFLAGS) $(LDFLAGS) -o $(BUILD_STAGE)/file-cmds/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/xattr $(BUILD_WORK)/file-cmds/xattr/xattr.c
	$(call AFTER_BUILD)
	$(call BINPACK_SIGN,general.xml)
	$(LDID) -Hsha256 -S$(BUILD_MISC)/entitlements/dd.xml $(BUILD_STAGE)/file-cmds/$(MEMO_PREFIX)/bin/dd
endif

.PHONY: file-cmds

endif # ($(MEMO_TARGET),darwin-\*)
