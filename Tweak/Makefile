ARCHS = arm64 arm64e
TARGET = iphone:clang:13.3:13.3

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = FastLPM
$(TWEAK_NAME)_FILES = Tweak.x ForceTouchGestureRecognizer.m
$(TWEAK_NAME)_CFLAGS = -fobjc-arc
$(TWEAK_NAME)_FRAMEWORKS = UIKit AudioToolbox
$(TWEAK_NAME)_PRIVATE_FRAMEWORKS = CoreDuet
$(TWEAK_NAME)_EXTRA_FRAMEWORKS += Cephei

include $(THEOS_MAKE_PATH)/tweak.mk
