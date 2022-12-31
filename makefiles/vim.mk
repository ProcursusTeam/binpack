ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS += vim
# Per homebrew, vim should only be updated every 50 releases on multiples of 50
VIM_VERSION := 8.2.1800

vim-setup: setup binpack-setup
	$(call GITHUB_ARCHIVE,vim,vim,$(VIM_VERSION),v$(VIM_VERSION))
	$(call EXTRACT_TAR,vim-$(VIM_VERSION).tar.gz,vim-$(VIM_VERSION),vim)

ifneq ($(wildcard $(BUILD_WORK)/vim/.build_complete),)
vim:
	@echo "Using previously built vim."
else
vim: .SHELLFLAGS=-O extglob -c
vim: vim-setup
	mkdir -p $(BUILD_STAGE)/vim/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin
	sed -i 's/AC_TRY_LINK(\[]/AC_TRY_LINK(\[#include <termcap.h>]/g' $(BUILD_WORK)/vim/src/configure.ac # This is so stupid, I cannot believe this is necessary.
	cd $(BUILD_WORK)/vim/src && autoconf -f
	cd $(BUILD_WORK)/vim && ./configure -C \
		$(DEFAULT_CONFIGURE_FLAGS) \
		--enable-gui=no \
		--without-x \
		--with-tlib=ncurses \
		--disable-darwin \
		--with-features=tiny \
		--disable-xsmp \
		--disable-xsmp-interact \
		--disable-netbeans \
		--disable-gpm \
		--disable-nls \
		--disable-terminal \
		--disable-canberra \
		--disable-libsodium \
		vim_cv_toupper_broken=no \
		vim_cv_terminfo=yes \
		vim_cv_tgetent=zero \
		vim_cv_tty_group=4 \
		vim_cv_tty_mode=0620 \
		vim_cv_getcwd_broken=no \
		vim_cv_stat_ignores_slash=no \
		vim_cv_memmove_handles_overlap=yes
	+$(MAKE) -C $(BUILD_WORK)/vim
	+$(MAKE) -C $(BUILD_WORK)/vim install \
		DESTDIR="$(BUILD_STAGE)/vim"
	rm -rf $(BUILD_STAGE)/vim/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/vimtutor $(BUILD_STAGE)/vim/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/share
	$(LN_S) vim $(BUILD_STAGE)/vim/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/vi
	$(call AFTER_BUILD)
	$(call BINPACK_SIGN,general.xml)
endif

.PHONY: vim vim-package
