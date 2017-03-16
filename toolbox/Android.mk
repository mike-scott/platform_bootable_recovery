LOCAL_PATH:= system/core/toolbox


common_cflags := \
    -Werror -Wno-unused-parameter -Wno-unused-const-variable \
    -include bsd-compatibility.h \


include $(CLEAR_VARS)
LOCAL_SRC_FILES := \
    upstream-netbsd/bin/dd/args.c \
    upstream-netbsd/bin/dd/conv.c \
    upstream-netbsd/bin/dd/dd.c \
    upstream-netbsd/bin/dd/dd_hostops.c \
    upstream-netbsd/bin/dd/misc.c \
    upstream-netbsd/bin/dd/position.c \
    upstream-netbsd/lib/libc/gen/getbsize.c \
    upstream-netbsd/lib/libc/gen/humanize_number.c \
    upstream-netbsd/lib/libc/stdlib/strsuftoll.c \
    upstream-netbsd/lib/libc/string/swab.c \
    upstream-netbsd/lib/libutil/raise_default_signal.c
LOCAL_CFLAGS += $(common_cflags) -Dmain=dd_main -DNO_CONV
LOCAL_C_INCLUDES += $(LOCAL_PATH)/upstream-netbsd/include/
LOCAL_MODULE := libtoolbox_dd_recovery
include $(BUILD_STATIC_LIBRARY)


include $(CLEAR_VARS)

BSD_TOOLS := \
    dd \

OUR_TOOLS := \
    getevent \
    newfs_msdos \

ALL_TOOLS = $(BSD_TOOLS) $(OUR_TOOLS)

LOCAL_SRC_FILES := \
    toolbox.c \
    $(patsubst %,%.c,$(OUR_TOOLS)) \

LOCAL_CFLAGS += $(common_cflags)
LOCAL_C_INCLUDES += $(LOCAL_PATH)/upstream-netbsd/include/

LOCAL_SHARED_LIBRARIES := \
    libcutils \

LOCAL_WHOLE_STATIC_LIBRARIES := $(patsubst %,libtoolbox_%_recovery,$(BSD_TOOLS))

LOCAL_MODULE := toolbox_recovery
LOCAL_MODULE_STEM := toolbox
LOCAL_MODULE_PATH := $(TARGET_RECOVERY_ROOT_OUT)/sbin

# Install the symlinks.
LOCAL_POST_INSTALL_CMD := $(hide) $(foreach t,$(ALL_TOOLS),ln -sf toolbox $(TARGET_RECOVERY_ROOT_OUT)/sbin/$(t);)

# Including this will define $(intermediates).
#
include $(BUILD_EXECUTABLE)

$(LOCAL_PATH)/toolbox.c: $(intermediates)/tools.h

TOOLS_H_RECOVERY := $(intermediates)/tools.h
$(TOOLS_H_RECOVERY): PRIVATE_TOOLS := $(ALL_TOOLS)
$(TOOLS_H_RECOVERY): PRIVATE_CUSTOM_TOOL = echo "/* file generated automatically */" > $@ ; for t in $(PRIVATE_TOOLS) ; do echo "TOOL($$t)" >> $@ ; done
$(TOOLS_H_RECOVERY): $(LOCAL_PATH)/Android.mk
$(TOOLS_H_RECOVERY):
	$(transform-generated-source)

$(LOCAL_PATH)/getevent.c: $(intermediates)/input.h-labels.h

UAPI_INPUT_EVENT_CODES_H_RECOVERY := bionic/libc/kernel/uapi/linux/input.h bionic/libc/kernel/uapi/linux/input-event-codes.h
INPUT_H_LABELS_H_RECOVERY := $(intermediates)/input.h-labels.h
$(INPUT_H_LABELS_H_RECOVERY): PRIVATE_LOCAL_PATH := $(LOCAL_PATH)
# The PRIVATE_CUSTOM_TOOL line uses = to evaluate the output path late.
# We copy the input path so it can't be accidentally modified later.
$(INPUT_H_LABELS_H_RECOVERY): PRIVATE_UAPI_INPUT_EVENT_CODES_H_RECOVERY := $(UAPI_INPUT_EVENT_CODES_H_RECOVERY)
$(INPUT_H_LABELS_H_RECOVERY): PRIVATE_CUSTOM_TOOL = $(PRIVATE_LOCAL_PATH)/generate-input.h-labels.py $(PRIVATE_UAPI_INPUT_EVENT_CODES_H_RECOVERY) > $@
# The dependency line though gets evaluated now, so the PRIVATE_ copy doesn't exist yet,
# and the original can't yet have been modified, so this is both sufficient and necessary.
$(INPUT_H_LABELS_H_RECOVERY): $(LOCAL_PATH)/Android.mk $(LOCAL_PATH)/generate-input.h-labels.py $(UAPI_INPUT_EVENT_CODES_H_RECOVERY)
$(INPUT_H_LABELS_H_RECOVERY):
	$(transform-generated-source)
