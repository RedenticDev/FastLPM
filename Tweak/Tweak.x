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
NSString* typeOfGesture = @"taps";
NSInteger areaEnlargement = 0;
NSInteger tapsNumber = 1;
double holdDuration = 0.5;
UISwipeGestureRecognizerDirection swipeDirection = UISwipeGestureRecognizerDirectionLeft;
NSInteger swipeDirectionValue = 0;
BOOL vibrationEnabled = YES;
NSInteger hapticStyleValue = 1;
UIImpactFeedbackStyle hapticStyle = UIImpactFeedbackStyleMedium;
NSInteger legacyFeedbackValue = 1519;
BOOL repeatVibrations = NO;
NSInteger vibrationRepetitions = 1;
double vibrationRepetitionInterval = 0.5;

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
            batteryView = self;
            if (shouldBeInitialized) {
                saver = [_CDBatterySaver batterySaver];
                self.userInteractionEnabled = YES;
                if ([typeOfGesture isEqualToString:@"taps"]) {
                    gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fastlpm_batteryTapped)];
                    ((UITapGestureRecognizer*)gestureRecognizer).numberOfTapsRequired = tapsNumber;
                } else if ([typeOfGesture isEqualToString:@"hold"]) {
                    gestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(fastlpm_batteryTapped)];
                    ((UILongPressGestureRecognizer*)gestureRecognizer).minimumPressDuration = holdDuration;
                } else if ([typeOfGesture isEqualToString:@"swipe"]) {
                    gestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(fastlpm_batteryTapped)];
                    ((UISwipeGestureRecognizer*)gestureRecognizer).direction = swipeDirection;
                }
                if (gestureRecognizer) [self addGestureRecognizer:gestureRecognizer];
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

    -(UIView*)hitTest:(CGPoint)point withEvent:(UIEvent*)event {
        return CGRectContainsPoint(CGRectInset(self.bounds, -areaEnlargement, -areaEnlargement), point) ? self : nil;
    }

    %new
    -(void)fastlpm_batteryTapped {
        [saver setMode:([saver getPowerMode] == 1) ? 0 : 1];
        if (vibrationEnabled) {
            if ([[[UIDevice currentDevice] valueForKey:@"_feedbackSupportLevel"] integerValue] > 1) { // Check for Haptic/Taptic support
                haptic = [[UIImpactFeedbackGenerator alloc] initWithStyle:hapticStyle];
                [haptic prepare];
                [haptic impactOccurred];
                if (repeatVibrations) {
                    double tempInterval = vibrationRepetitionInterval;
                    for (int i = 0; i < vibrationRepetitions - 1; i++) {
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, tempInterval * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                            [haptic impactOccurred];
                        });
                        tempInterval += vibrationRepetitionInterval;
                    }
                }
                haptic = nil;
            } else {
                AudioServicesPlaySystemSoundWithCompletion(legacyFeedbackValue, ^{
                    AudioServicesDisposeSystemSoundID(legacyFeedbackValue);
                });
                if (repeatVibrations) {
                    double tempInterval = vibrationRepetitionInterval;
                    for (int i = 0; i < vibrationRepetitions - 1; i++) {
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, tempInterval * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                            AudioServicesPlaySystemSoundWithCompletion(legacyFeedbackValue, ^{
                                AudioServicesDisposeSystemSoundID(legacyFeedbackValue);
                            });
                        });
                        tempInterval += vibrationRepetitionInterval;
                    }
                }
            }
        }
    }

%end

static void fastlpm_reloadPrefs() {
    enabled = [prefs boolForKey:@"enabled"];
    typeOfGesture = [prefs objectForKey:@"typeOfGesture"];
    areaEnlargement = [prefs integerForKey:@"areaEnlargement"];
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
    swipeDirectionValue = [prefs integerForKey:@"swipeDirectionValue"];
    switch (swipeDirectionValue) {
        case 0: { swipeDirection = UISwipeGestureRecognizerDirectionLeft; } break;
        case 1: { swipeDirection = UISwipeGestureRecognizerDirectionRight; } break;
        case 2: { swipeDirection = UISwipeGestureRecognizerDirectionUp; } break;
        case 3: { swipeDirection = UISwipeGestureRecognizerDirectionDown; } break;
        default: {} break;
    }
    repeatVibrations = [prefs boolForKey:@"repeatVibrations"];
    vibrationRepetitions = [prefs integerForKey:@"vibrationRepetitions"];
    vibrationRepetitionInterval = [prefs doubleForKey:@"vibrationInterval"];
    (enabled) ? (shouldBeInitialized = YES) : (shouldBeRemoved = YES);
    [batteryView setNeedsLayout];
    [batteryView layoutIfNeeded];
}

%ctor {
    prefs = [[HBPreferences alloc] initWithIdentifier:@"com.redenticdev.fastlpm"];
    [prefs registerBool:&enabled default:YES forKey:@"enabled"];
    [prefs registerObject:&typeOfGesture default:@"taps" forKey:@"typeOfGesture"];
    [prefs registerInteger:&areaEnlargement default:0 forKey:@"areaEnlargement"];
    [prefs registerInteger:&tapsNumber default:1 forKey:@"numberOfTaps"];
    [prefs registerDouble:&holdDuration default:0.5 forKey:@"holdDuration"];
    [prefs registerInteger:&swipeDirectionValue default:0 forKey:@"swipeDirectionValue"];
    [prefs registerBool:&vibrationEnabled default:YES forKey:@"vibrationEnabled"];
    [prefs registerInteger:&legacyFeedbackValue default:1519 forKey:@"oldVibrationStrength"];
    [prefs registerInteger:&hapticStyleValue default:1 forKey:@"newVibrationStrength"];
    [prefs registerBool:&repeatVibrations default:NO forKey:@"repeatVibrations"];
    [prefs registerInteger:&vibrationRepetitions default:1 forKey:@"vibrationRepetitions"];
    [prefs registerDouble:&vibrationRepetitionInterval default:0.5 forKey:@"vibrationInterval"];

    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)fastlpm_reloadPrefs, CFSTR("com.redenticdev.fastlpm/ReloadPrefs"), NULL, CFNotificationSuspensionBehaviorCoalesce);
    
    %init;
} 
