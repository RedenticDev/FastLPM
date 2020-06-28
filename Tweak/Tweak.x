#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioServices.h>
#import <Cephei/HBPreferences.h>

@interface _UIBatteryView : UIView
@end

@interface _CDBatterySaver : NSObject
+(id)batterySaver;
-(long long)getPowerMode;
-(long long)setMode:(long long)arg1;
@end

HBPreferences* prefs;
BOOL shouldBeInitialized = NO;
BOOL shouldBeRemoved = NO;
BOOL enabled = YES;
BOOL vibrationEnabled = YES;
UIImpactFeedbackStyle hapticStyle = UIImpactFeedbackStyleMedium;
NSInteger legacyFeedbackValue = 1519;
NSInteger hapticStyleValue = 1;

_CDBatterySaver* saver;
UIImpactFeedbackGenerator* haptic;
UIGestureRecognizer* gestureRecognizer;

%hook _UIBatteryView

    -(id)initWithFrame:(CGRect)arg1 {
        id _view = %orig;
        if (_view && enabled && !shouldBeRemoved) {
            shouldBeInitialized = YES;
        }
        return _view;
    }

    -(void)layoutSubviews {
        %orig;
        if ([self.superview isKindOfClass:%c(_UIStatusBarForegroundView)]) {
            if (shouldBeInitialized) {
                saver = [_CDBatterySaver batterySaver];
                self.userInteractionEnabled = YES;
                gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fastlpm_batteryTapped)];
                [self addGestureRecognizer:gestureRecognizer];
                shouldBeInitialized = NO;
            } else if (shouldBeRemoved) {
                self.userInteractionEnabled = NO;
                if ([self gestureRecognizers]) {
                    [self removeGestureRecognizer:gestureRecognizer];
                }
                shouldBeRemoved = NO;
            }
        }
    }

    %new
    -(void)fastlpm_batteryTapped {
        [saver setMode:([saver getPowerMode] == 1) ? 0 : 1];
        if (vibrationEnabled) {
            if ([[[UIDevice currentDevice] valueForKey:@"_feedbackSupportLevel"] integerValue] == 2) { // Check for Haptic/Taptic support
                haptic = [[UIImpactFeedbackGenerator alloc] initWithStyle:hapticStyle];
                [haptic prepare];
                [haptic impactOccurred];
            } else {
                AudioServicesPlaySystemSound(legacyFeedbackValue);
            }
        }
    }

%end

static void fastlpm_reloadPrefs() {
    enabled = [prefs boolForKey:@"enabled"];
    vibrationEnabled = [prefs boolForKey:@"vibrationEnabled"];
    legacyFeedbackValue = [prefs integerForKey:@"oldVibrationStrength"];
    hapticStyleValue = [prefs integerForKey:@"newVibrationStrength"];
    switch (hapticStyleValue) {
        case 0: { hapticStyle = UIImpactFeedbackStyleLight; } break;
        case 1: { hapticStyle = UIImpactFeedbackStyleMedium; } break;
        case 2: { hapticStyle = UIImpactFeedbackStyleHeavy; } break;
        case 3: { hapticStyle = UIImpactFeedbackStyleSoft; } break;
        case 4: { hapticStyle = UIImpactFeedbackStyleRigid; } break;
        default: {} break;
    }
    (enabled) ? (shouldBeInitialized = YES) : (shouldBeRemoved = YES);
}

%ctor {
    prefs = [[HBPreferences alloc] initWithIdentifier:@"com.redenticdev.fastlpm"];
    [prefs registerBool:&enabled default:YES forKey:@"enabled"];
    [prefs registerBool:&vibrationEnabled default:YES forKey:@"vibrationEnabled"];
    [prefs registerInteger:&legacyFeedbackValue default:1519 forKey:@"oldVibrationStrength"];
    [prefs registerInteger:&hapticStyleValue default:1 forKey:@"newVibrationStrength"];

    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)fastlpm_reloadPrefs, CFSTR("com.redenticdev.fastlpm/ReloadPrefs"), NULL, CFNotificationSuspensionBehaviorCoalesce);
    
    %init;
} 
