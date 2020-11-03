include $(THEOS)/makefiles/common.mk

ifeq ($(SIMULATOR), 1)
	SUBPROJECTS = Tweak
else
	SUBPROJECTS += Tweak Prefs
endif

include $(THEOS_MAKE_PATH)/aggregate.mk
