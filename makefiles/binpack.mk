ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

BINPACK_PROJECTS = adv-cmds bzip2 file-cmds kext-tools launchctl less network-cmds plutil shell-cmds snaputil system-cmds text-cmds toybox uikittools vim xz

binpack-setup: setup
	@cp -af $(MACOSX_SYSROOT)/usr/include/{curses,ncurses{,_dll},unctrl,termcap}.h $(BUILD_BASE)/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/include/
	@cp -af $(MACOSX_SYSROOT)/usr/include/get_compat.h $(BUILD_BASE)/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/include/
	@cp -af $(MACOSX_SYSROOT)/usr/include/sys/ioctl_compat.h $(BUILD_BASE)/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/include/sys

binpack: 
	+MEMO_NO_IOSEXEC=1 $(MAKE) binpack-setup $(BINPACK_PROJECTS)
	rm -rf $(BUILD_DIST)/binpack
	mkdir -p $(BUILD_DIST)/binpack
	rm -f $(BUILD_DIST)/binpack.tar*
	rm -f $(BUILD_DIST)/.fakeroot_binpack
	touch $(BUILD_DIST)/.fakeroot_binpack
	for proj in $(BINPACK_PROJECTS); do \
		cp -af $(BUILD_STAGE)/$$proj/* $(BUILD_DIST)/binpack; \
	done
	rm -rf $(BUILD_DIST)/binpack/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/{include,lib,share}
	export FAKEROOT='fakeroot -i $(BUILD_DIST)/.fakeroot_bootstrap -s $(BUILD_DIST)/.fakeroot_bootstrap --'; \
	$$FAKEROOT chown -R 0:0 $(BUILD_DIST)/binpack
	
BINPACK_SIGN = for file in $$(find $(BUILD_STAGE)/$@ -type f -exec sh -c "file -ib '{}' | grep -q 'x-mach-binary; charset=binary'" \; -print); do \
			if [ $${file\#\#*.} = "dylib" ] || [ $${file\#\#*.} = "bundle" ] || [ $${file\#\#*.} = "so" ]; then \
				$(LDID) -S $$file; \
			else \
				$(LDID) -S$(BUILD_MISC)/entitlements/$(1) $$file; \
			fi; \
		done; \

.PHONY: binpack
