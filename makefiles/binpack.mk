ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

BINPACK_TARBALL  = binpack

BINPACK_PROJECTS =  apple-cmds
BINPACK_PROJECTS += dropbear ksh ldid less ncurses plutil snaputil trustcache uikittools vim xz zstd
ifeq ($(MEMO_TARGET),iphoneos-arm64)
BINPACK_PROJECTS += launchctl
endif
ifeq ($(BINPACK_THICK),1)
BINPACK_TARBALL  = binpack-thick
endif

binpack-setup: setup
	@cp -af $(MACOSX_SYSROOT)/usr/include/{curses,ncurses{,_dll},unctrl,termcap,term}.h $(BUILD_BASE)/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/include/
	@cp -af $(MACOSX_SYSROOT)/usr/include/get_compat.h $(BUILD_BASE)/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/include/
	@cp -af $(MACOSX_SYSROOT)/usr/include/timeconv.h $(BUILD_BASE)/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/include/
	@cp -af $(MACOSX_SYSROOT)/usr/include/sys/ioctl_compat.h $(BUILD_BASE)/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/include/sys
	@cp -af $(MACOSX_SYSROOT)/usr/include/protocols $(BUILD_BASE)/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/include/
	$(call DOWNLOAD_FILES,$(BUILD_BASE)/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/include,https://raw.githubusercontent.com/apple-oss-distributions/Libinfo/main/membership.subproj/membershipPriv.h)

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
	cd $(BUILD_STRAP)/binpack; mtree -c | sed -E -e '/passwd|login/ s/$$/ mode=4755/' -e 's/uid=[0-9]* /uid=0 /' -e 's/gid=[0-9]* /gid=0 /' > $(BUILD_STRAP)/$(BINPACK_TARBALL).mtree
	cd $(BUILD_STRAP)/binpack; bsdtar -cf $(BUILD_STRAP)/$(BINPACK_TARBALL).tar @$(BUILD_STRAP)/$(BINPACK_TARBALL).mtree
	-tc create $(BUILD_STRAP)/$(BINPACK_TARBALL).tc; \
	for file in $$(find $(BUILD_STRAP)/binpack -type f -exec sh -c "file -ib '{}' | grep -q 'x-mach-binary; charset=binary'" \; -print); do \
		tc append $(BUILD_STRAP)/$(BINPACK_TARBALL).tc $$file; \
	done
	rm -rf $(BUILD_STRAP)/binpack
	
BINPACK_SIGN = for file in $$(find $(BUILD_STAGE)/$@ -type f -exec sh -c "file -ib '{}' | grep -q 'x-mach-binary; charset=binary'" \; -print); do \
			if [ $${file\#\#*.} = "dylib" ] || [ $${file\#\#*.} = "bundle" ] || [ $${file\#\#*.} = "so" ]; then \
				$(LDID) -Hsha256 -S $$file; \
			else \
				$(LDID) -Hsha256 -S$(BUILD_MISC)/entitlements/$(1) $$file; \
			fi; \
		done; \

SETUP_STUBS = \
	tmp=$$(mktemp -d); \
	for file in $$(find $(BUILD_STAGE)/$@ -type f -name '*.lo' -print); do \
		n=$$(basename $$file .lo); \
		echo "extern int main(int argc, char **argv, char **envp, char **apple); int _crunched_$${n}_stub(int argc, char **argv, char **envp, char **apple);int _crunched_$${n}_stub(int argc, char **argv, char **envp, char **apple){return main(argc,argv,envp,apple);}" > $${tmp}/$${n}_stub.c; \
		$(CC) $(CFLAGS) -c $${tmp}/$${n}_stub.c -o $${tmp}/$${n}_stub.o; \
		$(LD) -Z -r -o $$file $$file $${tmp}/$${n}_stub.o; \
		nm -U $$file | cut -d" " -f3 | grep -v "^__crunched_$${n}_stub$$" | sed "s/.*/& _\$$$${n}\$$&/" > $${tmp}/$${n}.syms; \
		llvm-objcopy --redefine-syms $${tmp}/$${n}.syms $$file; \
	done

.PHONY: binpack
