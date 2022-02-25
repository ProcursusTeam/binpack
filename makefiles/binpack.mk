ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

BINPACK_PROJECTS = adv-cmds bzip2 dropbear file-cmds iokittools kext-tools ldid less ncurses network-cmds plconvert plutil shell-cmds snaputil system-cmds text-cmds toybox uikittools vim xz
ifeq ($(MEMO_TARGET),iphoneos-arm64)
BINPACK_PROJECTS += launchctl
endif
ifeq ($(BINPACK_THICK),1)
BINPACK_PROJECTS += defaults
endif

binpack-setup: setup
	@cp -af $(MACOSX_SYSROOT)/usr/include/{curses,ncurses{,_dll},unctrl,termcap,term}.h $(BUILD_BASE)/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/include/
	@cp -af $(MACOSX_SYSROOT)/usr/include/get_compat.h $(BUILD_BASE)/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/include/
	@cp -af $(MACOSX_SYSROOT)/usr/include/sys/ioctl_compat.h $(BUILD_BASE)/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/include/sys

binpack: 
	+MEMO_NO_IOSEXEC=1 $(MAKE) binpack-setup $(BINPACK_PROJECTS)
	rm -rf $(BUILD_STRAP)/binpack
	mkdir -p $(BUILD_STRAP)/binpack
ifneq ($(BINPACK_THICK),1)
	rm -f $(BUILD_STRAP)/binpack.tar
else
	rm -f $(BUILD_STRAP)/binpack-thick.tar
endif
	rm -f $(BUILD_STRAP)/.fakeroot_binpack
	touch $(BUILD_STRAP)/.fakeroot_binpack
	for proj in $(BINPACK_PROJECTS); do \
		cp -af $(BUILD_STAGE)/$$proj/* $(BUILD_STRAP)/binpack; \
	done
	rm -rf $(BUILD_STRAP)/binpack/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/{include,lib,share/{doc,man}}
ifneq ($(BINPACK_THICK),1)
	cd $(BUILD_STRAP)/binpack; fakeroot -i $(BUILD_DIST)/.fakeroot_bootstrap -s $(BUILD_DIST)/.fakeroot_bootstrap -- \
		tar -ckpf $(BUILD_STRAP)/binpack.tar .
else
	cd $(BUILD_STRAP)/binpack; fakeroot -i $(BUILD_DIST)/.fakeroot_bootstrap -s $(BUILD_DIST)/.fakeroot_bootstrap -- \
		tar -ckpf $(BUILD_STRAP)/binpack-thick.tar .
endif
	rm -rf $(BUILD_STRAP)/binpack
	
BINPACK_SIGN = for file in $$(find $(BUILD_STAGE)/$@ -type f -exec sh -c "file -ib '{}' | grep -q 'x-mach-binary; charset=binary'" \; -print); do \
			if [ $${file\#\#*.} = "dylib" ] || [ $${file\#\#*.} = "bundle" ] || [ $${file\#\#*.} = "so" ]; then \
				$(LDID) -S $$file; \
			else \
				$(LDID) -S$(BUILD_MISC)/entitlements/$(1) $$file; \
			fi; \
		done; \

.PHONY: binpack
