ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS     += ncurses
NCURSES_VERSION := 57

ncurses-setup: setup binpack-setup
	$(call GITHUB_ARCHIVE,apple-oss-distributions,ncurses,$(NCURSES_VERSION),ncurses-$(NCURSES_VERSION))
	$(call EXTRACT_TAR,ncurses-$(NCURSES_VERSION).tar.gz,ncurses-ncurses-$(NCURSES_VERSION),ncurses)
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
	for tool in infocmp tic; do \
		$(CC) $(CFLAGS) $(LDFLAGS) -D_XOPEN_SOURCE_EXTENDED -Iinclude -Iprogs -lncurses progs/dump_entry.c progs/$${tool}.c -o $(BUILD_STAGE)/ncurses/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/$$tool; \
	done
	#$(CC) $(CFLAGS) $(LDFLAGS) -D_XOPEN_SOURCE_EXTENDED -DMAIN -Iinclude -Incurses -lncurses ncurses/tinfo/captoinfo.c -o $(BUILD_STAGE)/ncurses/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/captoinfo
	$(LN_S) tset $(BUILD_STAGE)/ncurses/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/reset
	$(LN_S) tic $(BUILD_STAGE)/ncurses/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/captoinfo
	$(LN_S) tic $(BUILD_STAGE)/ncurses/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/infotocap
	$(call AFTER_BUILD)
	$(call BINPACK_SIGN,general.xml)
endif

.PHONY: ncurses
