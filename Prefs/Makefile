ARCHS = arm64 arm64e
TARGET = iphone:clang:13.5:11.2

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = FLMPrefs
$(BUNDLE_NAME)_FILES = $(wildcard *.m) $(wildcard *.x)
$(BUNDLE_NAME)_INSTALL_PATH = /Library/PreferenceBundles
$(BUNDLE_NAME)_PRIVATE_FRAMEWORKS = Preferences
$(BUNDLE_NAME)_EXTRA_FRAMEWORKS = Cephei CepheiPrefs

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/$(BUNDLE_NAME).plist$(ECHO_END)

after-install::
	install.exec "killall -9 backboardd"
