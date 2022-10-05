ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS     += bash
BASH_VERSION    := 5.2
BASH_PATCHLEVEL := 0
DEB_BASH_V      ?= $(BASH_VERSION).$(BASH_PATCHLEVEL)

bash-setup: setup
	$(call DOWNLOAD_FILES,$(BUILD_SOURCE),https://ftpmirror.gnu.org/bash/bash-$(BASH_VERSION).tar.gz{$(comma).sig})
	$(call PGP_VERIFY,bash-$(BASH_VERSION).tar.gz)
	$(call EXTRACT_TAR,bash-$(BASH_VERSION).tar.gz,bash-$(BASH_VERSION),bash)
	mkdir -p $(BUILD_STAGE)/bash/$(MEMO_PREFIX)/bin
BASH_CONFIGURE_ARGS := ac_cv_c_stack_direction=-1 \
	ac_cv_func_mmap_fixed_mapped=yes \
	ac_cv_func_setvbuf_reversed=no \
	ac_cv_func_strcoll_works=yes \
	ac_cv_func_working_mktime=yes \
	ac_cv_prog_cc_g=no \
	ac_cv_rl_version=8.0 \
	ac_cv_type_getgroups=gid_t \
	bash_cv_dev_fd=absent \
	bash_cv_dup2_broken=no \
	bash_cv_func_ctype_nonascii=no \
	bash_cv_func_sigsetjmp=present \
	bash_cv_func_strcoll_broken=yes \
	bash_cv_job_control_missing=present \
	bash_cv_must_reinstall_sighandlers=no \
	bash_cv_sys_named_pipes=present \
	bash_cv_sys_siglist=yes \
	gt_cv_int_divbyzero_sigfpe=no

ifneq ($(wildcard $(BUILD_WORK)/bash/.build_complete),)
bash:
	@echo "Using previously built bash."
else
bash: bash-setup readline
	cd $(BUILD_WORK)/bash && ./configure -C \
		$(DEFAULT_CONFIGURE_FLAGS) \
		--disable-shared \
		--disable-nls \
		--with-installed-readline=$(BUILD_BASE)$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/ \
		CFLAGS="$(CFLAGS) -DSSH_SOURCE_BASHRC" \
		$(BASH_CONFIGURE_ARGS) \
		bash_cv_getcwd_malloc=yes
	+$(MAKE) -C $(BUILD_WORK)/bash
	install -d $(BUILD_STAGE)/bash/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/
	install -m755 $(BUILD_WORK)/bash/bash $(BUILD_STAGE)/bash/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/
	$(LN_S) ../usr/bin/bash $(BUILD_STAGE)/bash/$(MEMO_PREFIX)/bin/bash
	$(call AFTER_BUILD)
	$(call BINPACK_SIGN,general.xml)
endif

.PHONY: bash
