LOCAL_PATH := $(call my-dir)

RELINK := $(LOCAL_PATH)/relink.sh

#dummy file to trigger required modules
include $(CLEAR_VARS)
LOCAL_MODULE := factory_recovery
LOCAL_MODULE_TAGS := eng

ifeq ($(TARGET_ARCH),arm64)
BIN_ADD := 64
else
BIN_ADD :=
endif

#ifeq (0,1)
# recovery/sbin
RELINK_SOURCE_FILES += $(TARGET_RECOVERY_ROOT_OUT)/sbin/toolbox

# system/bin
RELINK_SOURCE_FILES += $(TARGET_OUT)/bin/linker$(BIN_ADD)
RELINK_SOURCE_FILES += $(TARGET_OUT)/bin/linker_asan$(BIN_ADD)
RELINK_SOURCE_FILES += $(TARGET_OUT)/bin/logwrapper
RELINK_SOURCE_FILES += $(TARGET_OUT)/bin/reboot
RELINK_SOURCE_FILES += $(TARGET_OUT)/bin/sh

# etc
RELINK_SOURCE_FILES += $(TARGET_OUT)/etc/init/logd.rc

# lib
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib$(BIN_ADD)/ld-android.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib$(BIN_ADD)/libbacktrace.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib$(BIN_ADD)/libbase.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib$(BIN_ADD)/libc.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib$(BIN_ADD)/libc++.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib$(BIN_ADD)/libcap.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib$(BIN_ADD)/libcrypto.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib$(BIN_ADD)/libcutils.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib$(BIN_ADD)/libdl.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib$(BIN_ADD)/libext2_blkid.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib$(BIN_ADD)/libext2_com_err.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib$(BIN_ADD)/libext2_e2p.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib$(BIN_ADD)/libext2fs.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib$(BIN_ADD)/libext2_misc.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib$(BIN_ADD)/libext2_profile.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib$(BIN_ADD)/libext2_quota.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib$(BIN_ADD)/libext2_uuid.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib$(BIN_ADD)/libext4_utils.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib$(BIN_ADD)/libkeyutils.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib$(BIN_ADD)/liblog.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib$(BIN_ADD)/liblogcat.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib$(BIN_ADD)/liblzma.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib$(BIN_ADD)/libm.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib$(BIN_ADD)/libminijail.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib$(BIN_ADD)/libnl.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib$(BIN_ADD)/libpackagelistparser.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib$(BIN_ADD)/libpcre2.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib$(BIN_ADD)/libpcrecpp.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib$(BIN_ADD)/libselinux.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib$(BIN_ADD)/libsparse.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib$(BIN_ADD)/libstdc++.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib$(BIN_ADD)/libsysutils.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib$(BIN_ADD)/libtinyalsa.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib$(BIN_ADD)/libunwind.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib$(BIN_ADD)/libunwindstack.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib$(BIN_ADD)/libutils.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib$(BIN_ADD)/libvndksupport.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib$(BIN_ADD)/libz.so

ifeq ($(MINI_RECOVERY),)
# system/bin
RELINK_SOURCE_FILES += $(TARGET_OUT)/bin/e2fsck
RELINK_SOURCE_FILES += $(TARGET_OUT)/bin/logcat
RELINK_SOURCE_FILES += $(TARGET_OUT)/bin/logd
RELINK_SOURCE_FILES += $(TARGET_OUT)/bin/make_ext4fs
RELINK_SOURCE_FILES += $(TARGET_OUT)/bin/mke2fs
RELINK_SOURCE_FILES += $(TARGET_OUT)/bin/resize2fs
RELINK_SOURCE_FILES += $(TARGET_OUT)/bin/strace
RELINK_SOURCE_FILES += $(TARGET_OUT)/bin/tinycap
RELINK_SOURCE_FILES += $(TARGET_OUT)/bin/tinymix
RELINK_SOURCE_FILES += $(TARGET_OUT)/bin/tinypcminfo
RELINK_SOURCE_FILES += $(TARGET_OUT)/bin/tinyplay
RELINK_SOURCE_FILES += $(TARGET_OUT)/bin/tune2fs

# lib
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib$(BIN_ADD)/libcrypto.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib$(BIN_ADD)/libext2_blkid.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib$(BIN_ADD)/libext2_com_err.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib$(BIN_ADD)/libext2_e2p.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib$(BIN_ADD)/libext2fs.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib$(BIN_ADD)/libext2_profile.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib$(BIN_ADD)/libext2_quota.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib$(BIN_ADD)/libext2_uuid.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib$(BIN_ADD)/libext4_utils.so
RELINK_SOURCE_FILES += $(TARGET_OUT)/lib$(BIN_ADD)/libtinyalsa.so
endif

#endif

ifneq ($(RECOVERY_ADDITIONAL_RELINK_FILES),)
    RELINK_SOURCE_FILES += $(RECOVERY_ADDITIONAL_RELINK_FILES)
endif

GEN := $(RELINK)
$(GEN): $(RELINK_SOURCE_FILES)
	$(RELINK) $(TARGET_RECOVERY_ROOT_OUT) $(RELINK_SOURCE_FILES)

LOCAL_ADDITIONAL_DEPENDENCIES := $(GEN)
include $(BUILD_PHONY_PACKAGE)
