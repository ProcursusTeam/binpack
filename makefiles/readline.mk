ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS      += readline
READLINE_VERSION := 8.2
READLINE_PATCH   := 0
DEB_READLINE_V   ?= $(READLINE_VERSION).$(READLINE_PATCH)

readline-setup: setup
	$(call DOWNLOAD_FILES,$(BUILD_SOURCE),https://ftp.gnu.org/gnu/readline/readline-$(READLINE_VERSION).tar.gz{$(comma).sig})
	$(call PGP_VERIFY,readline-$(READLINE_VERSION).tar.gz)
	$(call EXTRACT_TAR,readline-$(READLINE_VERSION).tar.gz,readline-$(READLINE_VERSION),readline)

ifneq ($(wildcard $(BUILD_WORK)/readline/.build_complete),)
readline:
	@echo "Using previously built readline."
else
readline: readline-setup ncurses
	cd $(BUILD_WORK)/readline && ./configure -C \
		$(DEFAULT_CONFIGURE_FLAGS) \
		--disable-shared \
		ac_cv_type_sig_atomic_t=no \
		LDFLAGS="$(CLFLAGS) $(LDFLAGS)"
	+$(MAKE) -C $(BUILD_WORK)/readline
	+$(MAKE) -C $(BUILD_WORK)/readline install \
		DESTDIR=$(BUILD_STAGE)/readline
	$(call AFTER_BUILD,copy)
endif

.PHONY: readline
