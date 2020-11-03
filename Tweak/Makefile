ifeq ($(SIMULATOR), 1)
	ARCHS = x86_64
	TARGET = simulator:clang::7.0
else
	ARCHS = arm64 arm64e
	TARGET = iphone:clang:13.5:11.2
endif

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = FastLPM
$(TWEAK_NAME)_FILES = Tweak.x ForceTouchGestureRecognizer.m
$(TWEAK_NAME)_CFLAGS = -fobjc-arc -DSIMULATOR=1
$(TWEAK_NAME)_FRAMEWORKS = UIKit AudioToolbox
$(TWEAK_NAME)_PRIVATE_FRAMEWORKS = CoreDuet
ifneq ($(SIMULATOR), 1)
	$(TWEAK_NAME)_EXTRA_FRAMEWORKS += Cephei
	$(TWEAK_NAME)_CFLAGS := $(filter-out -DSIMULATOR=1, $($(TWEAK_NAME)_CFLAGS))
endif

include $(THEOS_MAKE_PATH)/tweak.mk
