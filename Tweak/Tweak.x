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
NSString* tapsOrHold = @"taps";
NSInteger tapsNumber = 1;
double holdDuration = 0.5;
NSInteger legacyFeedbackValue = 1519;
NSInteger hapticStyleValue = 1;

_UIBatteryView* batteryView;
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
            if (!batteryView) batteryView = self;
            if (shouldBeInitialized) {
                saver = [_CDBatterySaver batterySaver];
                self.userInteractionEnabled = YES;
                if ([tapsOrHold isEqualToString:@"taps"]) {
                    gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fastlpm_batteryTapped)];
                    gestureRecognizer.numberOfTouches = tapsNumber;
                } else {
                    gestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(fastlpm_batteryTapped)];
                    gestureRecognizer.minimumPressDuration = holdDuration;
                }
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
            if ([[[UIDevice currentDevice] valueForKey:@"_feedbackSupportLevel"] integerValue] > 1) { // Check for Haptic/Taptic support
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
    tapsOrHold = [prefs objectForKey:@"tapsOrHold"];
    tapsNumber = [prefs integerForKey:@"numberOfTaps"];
    holdDuration = [prefs doubleForKey:@"holdDuration"];
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
    if (batteryView) [batteryView setNeedsLayout];
}

%ctor {
    prefs = [[HBPreferences alloc] initWithIdentifier:@"com.redenticdev.fastlpm"];
    [prefs registerBool:&enabled default:YES forKey:@"enabled"];
    [prefs registerObject:&tapsOrHold default:@"taps" forKey:@"tapsOrHold"];
    [prefs registerInteger:&tapsNumber default:1 forKey:@"numberOfTaps"];
    [prefs registerDouble:&holdDuration default:0.5 forKey:@"holdDuration"];
    [prefs registerBool:&vibrationEnabled default:YES forKey:@"vibrationEnabled"];
    [prefs registerInteger:&legacyFeedbackValue default:1519 forKey:@"oldVibrationStrength"];
    [prefs registerInteger:&hapticStyleValue default:1 forKey:@"newVibrationStrength"];

    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)fastlpm_reloadPrefs, CFSTR("com.redenticdev.fastlpm/ReloadPrefs"), NULL, CFNotificationSuspensionBehaviorCoalesce);
    
    %init;
} 
