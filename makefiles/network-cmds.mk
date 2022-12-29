ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

ifeq (,$(findstring darwin,$(MEMO_TARGET)))

SUBPROJECTS          += network-cmds
NETWORK-CMDS_VERSION := 641

network-cmds-setup: binpack-setup
	$(call GITHUB_ARCHIVE,apple-oss-distributions,network_cmds,$(NETWORK-CMDS_VERSION),network_cmds-$(NETWORK-CMDS_VERSION))
	$(call EXTRACT_TAR,network_cmds-$(NETWORK-CMDS_VERSION).tar.gz,network_cmds-network_cmds-$(NETWORK-CMDS_VERSION),network-cmds)
	mkdir -p $(BUILD_STAGE)/network-cmds/$(MEMO_PREFIX)/sbin

	# Mess of copying over headers because some build_base headers interfere with the build of Apple cmds.
	mkdir -p $(BUILD_WORK)/network-cmds/include/{os,sys,firehose,arm,machine}
	cp -af $(MACOSX_SYSROOT)/usr/include/nlist.h $(BUILD_WORK)/network-cmds/include
	mkdir -p $(BUILD_WORK)/network-cmds/include/{net/{classq,},corecrypto}
	cp -a $(BUILD_BASE)$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/include/{libiosexec,stdlib,unistd,libutil}.h $(BUILD_WORK)/network-cmds/include
	cp -a $(BUILD_BASE)$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/include/os/{internal,{base,log}_private.h,log.h} $(BUILD_WORK)/network-cmds/include/os
	cp -a $(BUILD_BASE)$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/include/firehose/{firehose_types,tracepoint}_private.h $(BUILD_WORK)/network-cmds/include/firehose
	cp -a $(BUILD_BASE)$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/include/arm/cpu_capabilities.h $(BUILD_WORK)/network-cmds/include/arm
	cp -a $(BUILD_BASE)$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/include/machine/cpu_capabilities.h $(BUILD_WORK)/network-cmds/include/machine
	$(LN_S) $(BUILD_WORK)/network-cmds/include/{,System}

	@$(call DOWNLOAD_FILES,$(BUILD_WORK)/network-cmds/include/net, \
		https://raw.githubusercontent.com/apple-oss-distributions/xnu/xnu-8792.41.9/bsd/net/{content_filter$(comma)packet_mangler$(comma)pktap$(comma)net_api_stats$(comma)if_ports_used$(comma)if_bridgevar$(comma)ntstat$(comma)if_llreach$(comma)route$(comma)route_private$(comma)if$(comma)if_private$(comma)if_var$(comma)if_var_private$(comma)if_mib$(comma)if_arp$(comma)if_media$(comma)radix$(comma)net_perf$(comma)if_6lowpan_var$(comma)if_bond_var$(comma)network_agent$(comma)if_fake_var$(comma)if_vlan_var$(comma)if_fake_var$(comma)bpf$(comma)lacp$(comma)if_bond_internal}.h)
	@$(call DOWNLOAD_FILES,$(BUILD_WORK)/network-cmds/include/net/pktsched, \
		https://raw.githubusercontent.com/apple-oss-distributions/xnu/xnu-8792.41.9/bsd/net/pktsched/pktsched{$(comma)_{cbq$(comma)fairq$(comma)fq_codel$(comma)hfsc$(comma)netem$(comma)priq$(comma)rmclass$(comma)fq_codel}}.h)
	@$(call DOWNLOAD_FILES,$(BUILD_WORK)/network-cmds/include/net/classq, \
		https://raw.githubusercontent.com/apple-oss-distributions/xnu/xnu-8792.41.9/bsd/net/classq/{classq$(comma)if_classq$(comma)classq_red$(comma)classq_blue$(comma)classq_rio$(comma)classq_sfb}.h)
	@$(call DOWNLOAD_FILES,$(BUILD_WORK)/network-cmds/include/netinet, \
		https://raw.githubusercontent.com/apple-oss-distributions/xnu/xnu-8792.41.9/bsd/netinet/{ip_dummynet$(comma)ip_flowid$(comma)mptcp_var$(comma)in_stat$(comma)in$(comma)in_private$(comma)tcp$(comma)tcp_private$(comma)tcp_var$(comma)ip_var$(comma)udp_var$(comma)if_ether$(comma)tcpip$(comma)icmp6$(comma)icmp_var$(comma)igmp_var$(comma)tcp_seq$(comma)tcp_fsm$(comma)in_var$(comma)in_pcb}.h)
	@$(call DOWNLOAD_FILES,$(BUILD_WORK)/network-cmds/include/netinet6, \
		https://raw.githubusercontent.com/apple-oss-distributions/xnu/xnu-8792.41.9/bsd/netinet6/{ip6_var$(comma)in6_var$(comma)in6$(comma)in6_private$(comma)nd6$(comma)mld6_var$(comma)in6_pcb$(comma)raw_ip6}.h)
	@$(call DOWNLOAD_FILES,$(BUILD_WORK)/network-cmds/include/sys, \
		https://raw.githubusercontent.com/apple-oss-distributions/xnu/xnu-8792.41.9/bsd/sys/{proc_info$(comma)socket$(comma)unpcb$(comma)kern_event$(comma)kern_control$(comma)socketvar$(comma)sys_domain$(comma)mbuf$(comma)sockio}.h)
	@$(call DOWNLOAD_FILES,$(BUILD_WORK)/network-cmds/include/mach, \
		https://raw.githubusercontent.com/apple-oss-distributions/xnu/xnu-8792.41.9/osfmk/mach/coalition.h)
	@$(call DOWNLOAD_FILES,$(BUILD_WORK)/network-cmds/include/corecrypto, \
		https://github.com/apple-oss-distributions/xnu/raw/xnu-8792.41.9/EXTERNAL_HEADERS/corecrypto/cc{$(comma)n$(comma)sha2$(comma)digest$(comma)_{config$(comma)error$(comma)impl}}.h)

	sed -i 's/#if INET6/#ifdef INET6/g' $(BUILD_WORK)/network-cmds/include/sys/sockio.h
	sed -i '/struct kevent_qos_s kqext_kev/d' $(BUILD_WORK)/network-cmds/include/sys/proc_info.h
	sed -i '1s|^|#include <TargetConditionals.h>\n|' $(BUILD_WORK)/network-cmds/{dnctl,frame_delay,ecnprobe,pktapctl,pktmnglr,mptcp_client}/*.c
	sed -i '/__CCT_DECLARE_CONSTRAINED_PTR_TYPES/d' $(BUILD_WORK)/network-cmds/include/sys/socket.h
	sed -i 's/	IF_NETEM_MODEL_NLC = 1/	IF_NETEM_MODEL_IOD = 2,IF_NETEM_MODEL_FPD = 3,IF_NETEM_MODEL_NLC = 1/g' $(BUILD_WORK)/network-cmds/include/net/if_var_private.h

ifneq ($(wildcard $(BUILD_WORK)/network-cmds/.build_complete),)
network-cmds:
	@echo "Using previously built network-cmds."
else
network-cmds: .SHELLFLAGS=-O extglob -c
network-cmds: network-cmds-setup
	set -e; \
	cd $(BUILD_WORK)/network-cmds; \
	for tproj in {ping,ifconfig}.tproj; do \
		tproj=$$(basename $$tproj .tproj); \
		echo $$tproj; \
		$(CC) -arch $(MEMO_ARCH) $(OPTIMIZATION_FLAGS) $(PLATFORM_VERSION_MIN) -isysroot $(TARGET_SYSROOT) -isystem include -o $$tproj $$tproj.tproj/!(ns).c ecnprobe/gmt2local.c -DPRIVATE=1 -DINET6 -DPLATFORM_$(BARE_PLATFORM) -D__APPLE_USE_RFC_3542=1 -DUSE_RFC2292BIS=1 -D__APPLE_API_OBSOLETE=1 -DTARGET_OS_EMBEDDED=1 -Dether_ntohost=_old_ether_ntohost -D_VA_LIST -D__OS_EXPOSE_INTERNALS__; \
	done
	cp -a $(BUILD_WORK)/network-cmds/{ifconfig,ping} $(BUILD_STAGE)/network-cmds/$(MEMO_PREFIX)/sbin
	$(call AFTER_BUILD)
	$(call BINPACK_SIGN,general.xml)
endif

.PHONY: network-cmds

endif # ($(MEMO_TARGET),darwin-\*)
