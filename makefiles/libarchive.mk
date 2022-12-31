ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS        += libarchive
LIBARCHIVE_VERSION := 101

libarchive-setup: setup binpack-setup
	$(call GITHUB_ARCHIVE,apple-oss-distributions,libarchive,$(LIBARCHIVE_VERSION),libarchive-$(LIBARCHIVE_VERSION))
	$(call EXTRACT_TAR,libarchive-$(LIBARCHIVE_VERSION).tar.gz,libarchive-libarchive-$(LIBARCHIVE_VERSION),libarchive)
	cp -a $(BUILD_MISC)/config.sub $(BUILD_WORK)/libarchive/libarchive
	mkdir -p $(BUILD_STAGE)/libarchive/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin

ifneq ($(wildcard $(BUILD_WORK)/libarchive/.build_complete),)
libarchive:
	@echo "Using previously built libarchive."
else
libarchive: libarchive-setup
	cd $(BUILD_WORK)/libarchive/libarchive/tar && \
		$(CC) $(CFLAGS) -I../.. -I../libarchive -I../libarchive_fe \
		bsdtar.c cmdline.c creation_set.c read.c subst.c util.c write.c \
		../libarchive_fe/err.c ../libarchive_fe/line_reader.c ../libarchive_fe/passphrase.c \
		-r -nostdlib \
		-o $(BUILD_STAGE)/libarchive/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/tar.lo
	$(LN_S) tar $(BUILD_STAGE)/libarchive/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/bsdtar
	$(call SETUP_STUBS)
	$(call AFTER_BUILD)
	#$(call BINPACK_SIGN,general.xml)
endif

.PHONY: libarchive
