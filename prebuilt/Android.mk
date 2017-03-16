LOCAL_PATH := $(call my-dir)

RELINK := $(LOCAL_PATH)/relink.sh

#dummy file to trigger required modules
include $(CLEAR_VARS)
LOCAL_MODULE := factory_recovery
LOCAL_MODULE_TAGS := eng
LOCAL_MODULE_CLASS := RECOVERY_EXECUTABLES
LOCAL_MODULE_PATH := $(TARGET_RECOVERY_ROOT_OUT)/sbin

#ifeq (0,1)
# recovery/sbin
RELINK_SOURCE_FILES += $(TARGET_RECOVERY_ROOT_OUT)/sbin/toolbox
RELINK_SOURCE_FILES += $(TARGET_RECOVERY_ROOT_OUT)/sbin/toybox

# system/bin
RELINK_SOURCE_FILES += $(TARGET_OUT)/bin/linker
RELINK_SOURCE_FILES += $(TARGET_OUT)/bin/logwrapper
RELINK_SOURCE_FILES += $(TARGET_OUT)/bin/reboot
RELINK_SOURCE_FILES += $(TARGET_OUT)/bin/sh
ifneq ($(filter arm64, $(TARGET_ARCH)),)
RELINK_SOURCE_FILES += $(TARGET_OUT)/bin/linker64
endif

# lib
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib/libbacktrace.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib/libbase.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib/libc.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib/libc++.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib/libcap.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib/libcrypto.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib/libcutils.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib/libdl.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib/libext2_blkid.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib/libext2_com_err.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib/libext2_e2p.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib/libext2fs.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib/libext2_profile.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib/libext2_quota.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib/libext2_uuid.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib/libext4_utils.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib/liblog.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib/liblzma.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib/libm.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib/libminijail.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib/libnl.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib/libpackagelistparser.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib/libpcre2.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib/libpcrecpp.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib/libselinux.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib/libsparse.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib/libstdc++.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib/libsysutils.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib/libtinyalsa.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib/libunwind.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib/libutils.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib/libz.so

# lib64
ifneq ($(filter arm64, $(TARGET_ARCH)),)
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib64/libbacktrace.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib64/libbase.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib64/libc.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib64/libc++.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib64/libcap.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib64/libcrypto.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib64/libcutils.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib64/libdl.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib64/libext2_blkid.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib64/libext2_com_err.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib64/libext2_e2p.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib64/libext2fs.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib64/libext2_profile.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib64/libext2_quota.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib64/libext2_uuid.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib64/libext4_utils.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib64/liblog.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib64/liblzma.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib64/libm.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib64/libminijail.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib64/libnl.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib64/libpackagelistparser.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib64/libpcre2.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib64/libpcrecpp.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib64/libselinux.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib64/libsparse.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib64/libstdc++.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib64/libsysutils.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib64/libtinyalsa.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib64/libunwind.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib64/libutils.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib64/libz.so
endif

ifeq ($(MINI_RECOVERY),)
# system/bin
RELINK_SOURCE_FILES += $(TARGET_OUT)/bin/e2fsck
RELINK_SOURCE_FILES += $(TARGET_OUT)/bin/logcat
RELINK_SOURCE_FILES += $(TARGET_OUT)/bin/logd
RELINK_SOURCE_FILES += $(TARGET_OUT)/bin/make_ext4fs
RELINK_SOURCE_FILES += $(TARGET_OUT)/bin/mke2fs
RELINK_SOURCE_FILES += $(TARGET_OUT)/bin/resize2fs
RELINK_SOURCE_FILES += $(TARGET_OUT)/bin/tinycap
RELINK_SOURCE_FILES += $(TARGET_OUT)/bin/tinymix
RELINK_SOURCE_FILES += $(TARGET_OUT)/bin/tinypcminfo
RELINK_SOURCE_FILES += $(TARGET_OUT)/bin/tinyplay
RELINK_SOURCE_FILES += $(TARGET_OUT)/bin/tune2fs

# system/xbin
RELINK_SOURCE_FILES += $(TARGET_OUT)/xbin/strace

# lib
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib/libcrypto.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib/libext2_blkid.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib/libext2_com_err.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib/libext2_e2p.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib/libext2fs.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib/libext2_profile.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib/libext2_quota.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib/libext2_uuid.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib/libext4_utils.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib/libtinyalsa.so

# lib64
ifneq ($(filter arm64, $(TARGET_ARCH)),)
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib64/libcrypto.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib64/libext2_blkid.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib64/libext2_com_err.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib64/libext2_e2p.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib64/libext2fs.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib64/libext2_profile.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib64/libext2_quota.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib64/libext2_uuid.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib64/libext4_utils.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib64/libtinyalsa.so
endif
endif

#endif

ifneq ($(RECOVERY_ADDITIONAL_RELINK_FILES),)
    RELINK_SOURCE_FILES += $(RECOVERY_ADDITIONAL_RELINK_FILES)
endif

RELINK_GEN := factory_recovery
$(RELINK_GEN): $(RELINK)
$(RELINK_GEN): $(RELINK_SOURCE_FILES)
	$(RELINK) $(TARGET_RECOVERY_ROOT_OUT) $(RELINK_SOURCE_FILES)

LOCAL_GENERATED_SOURCES := $(RELINK_GEN)
LOCAL_SRC_FILES := $(RELINK_GEN)
include $(BUILD_PREBUILT)
