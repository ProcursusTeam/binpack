ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS     += ncurses
NCURSES_VERSION := 61

ncurses-setup: setup binpack-setup
	$(call GITHUB_ARCHIVE,apple-oss-distributions,ncurses,$(NCURSES_VERSION),ncurses-$(NCURSES_VERSION))
	$(call EXTRACT_TAR,ncurses-$(NCURSES_VERSION).tar.gz,ncurses-ncurses-$(NCURSES_VERSION),ncurses)
	cp -a $(BUILD_MISC)/config.sub $(BUILD_WORK)/ncurses/ncurses
	mkdir -p $(BUILD_STAGE)/ncurses/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin

ifneq ($(wildcard $(BUILD_WORK)/ncurses/.build_complete),)
ncurses:
	@echo "Using previously built ncurses."
else
ncurses: ncurses-setup
	cd $(BUILD_WORK)/ncurses/ncurses; \
	sh include/MKncurses_def.sh include/ncurses_defs > include/ncurses_def.h; \
	sh include/MKparametrized.sh include/Caps > include/parametrized.h; \
	sh progs/MKtermsort.sh awk include/Caps > progs/termsort.c; \
	echo -e '#define PROG_CAPTOINFO "captoinfo"\n#define PROG_INFOTOCAP "infotocap"\n#define PROG_RESET "reset"\n#define PROG_INIT "init"\n' > progs/transform.h; \
	for tool in toe tput tset; do \
		$(CC) $(CFLAGS) $(LDFLAGS) -D_XOPEN_SOURCE_EXTENDED -Iinclude -Iprogs -lncurses progs/$${tool}.c -o $(BUILD_STAGE)/ncurses/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/$$tool; \
	done; \
	for tool in clear infocmp tic; do \
		$(CC) $(CFLAGS) $(LDFLAGS) -D_XOPEN_SOURCE_EXTENDED -Iinclude -Iprogs -lncurses progs/dump_entry.c progs/$${tool}.c -o $(BUILD_STAGE)/ncurses/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/$$tool; \
	done
	$(LN_S) tset $(BUILD_STAGE)/ncurses/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/reset
	$(LN_S) tic $(BUILD_STAGE)/ncurses/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/captoinfo
	$(LN_S) tic $(BUILD_STAGE)/ncurses/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/infotocap
ifeq ($(BINPACK_THICK),1) # Thick binpack has terminfo db
	cd $(BUILD_WORK)/ncurses/ncurses && sh ./configure -C \
		$(DEFAULT_CONFIGURE_FLAGS) \
		--disable-static \
		--with-build-cc="$(CC_FOR_BUILD)" \
		--with-build-cpp="$(CPP_FOR_BUILD)" \
		--with-build-cflags="$(CFLAGS_FOR_BUILD)" \
		--with-build-cppflags="$(CPPFLAGS_FOR_BUILD)" \
		--with-build-ldflags="$(LDFLAGS_FOR_BUILD)" \
		--disable-widec \
		--with-default-terminfo-dir=$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/share/terminfo
	+$(MAKE) -C $(BUILD_WORK)/ncurses/ncurses/misc install.data \
		DESTDIR="$(BUILD_STAGE)/ncurses"
endif
	$(call AFTER_BUILD)
	$(call BINPACK_SIGN,general.xml)
endif

.PHONY: ncurses
