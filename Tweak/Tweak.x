#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioServices.h>
#ifndef SIMULATOR
    #import <Cephei/HBPreferences.h>
#endif

@interface _CDBatterySaver : NSObject
+(id)batterySaver;
-(long long)getPowerMode;
-(long long)setMode:(long long)arg1;
@end

// Prefs
#ifndef SIMULATOR
    HBPreferences *prefs;
#endif
BOOL enabled = YES;
BOOL shouldbeInjected = YES;
BOOL shouldBeInitialized;
BOOL shouldBeRemoved;
BOOL isLegacyDevice;
BOOL isForceTouchCap;
NSString *typeOfGesture = @"taps";
NSInteger areaEnlargement = 0;
NSInteger tapsNumber = 1;
double holdDuration = 0.5;
UISwipeGestureRecognizerDirection swipeDirection = UISwipeGestureRecognizerDirectionLeft;
NSInteger swipeDirectionValue = 0;
BOOL vibrationEnabled = YES;
NSInteger hapticStyleValue = 1;
UIImpactFeedbackStyle hapticStyle = UIImpactFeedbackStyleMedium;
NSInteger legacyFeedbackValue = 1519;
BOOL repeatVibrations;
NSInteger vibrationRepetitions = 2;
double vibrationRepetitionInterval = 0.5;
BOOL growingDuration;

// Global variables
Class foregroundViewClass;
UIView *batteryView;
_CDBatterySaver *saver;
UIGestureRecognizer *gestureRecognizer;

%hook batteryViewClass

    -(id)initWithFrame:(CGRect)arg1 {
        id _view = %orig;
        if (_view && enabled && !shouldBeRemoved) {
            shouldBeInitialized = YES;
        }
        return _view;
    }

    -(void)layoutSubviews {
        %orig;
        shouldbeInjected = ((UIView *)self).frame.origin.x > [UIScreen mainScreen].bounds.size.width / 2;
        if (shouldbeInjected && [((UIView *)self).superview isKindOfClass:foregroundViewClass]) {
            if (!batteryView) {
                batteryView = self;
                // Initial checks
                isLegacyDevice = [[[UIDevice currentDevice] valueForKey:@"_feedbackSupportLevel"] integerValue] < 2; // Check for Haptic/Taptic support
                isForceTouchCap = [UITraitCollection new].forceTouchCapability == UIForceTouchCapabilityAvailable;
                saver = [_CDBatterySaver batterySaver];
            }
            if (shouldBeRemoved) {
                ((UIView *)self).userInteractionEnabled = NO;
                if (((UIView *)self).gestureRecognizers) {
                    for (UIGestureRecognizer *gesture in ((UIView *)self).gestureRecognizers) {
                        [((UIView *)self) removeGestureRecognizer:gesture];
                    }
                }
                shouldBeRemoved = NO;
            }
            if (shouldBeInitialized) {
                ((UIView *)self).userInteractionEnabled = YES;
                if ([typeOfGesture isEqualToString:@"taps"]) {
                    gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:((UIView *)self) action:@selector(fastlpm_batteryTapped:)];
                    ((UITapGestureRecognizer *)gestureRecognizer).numberOfTapsRequired = tapsNumber;
                } else if ([typeOfGesture isEqualToString:@"hold"] || ([typeOfGesture isEqualToString:@"3d"] && !isForceTouchCap)) {
                    gestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:((UIView *)self) action:@selector(fastlpm_batteryTapped:)];
                    ((UILongPressGestureRecognizer *)gestureRecognizer).minimumPressDuration = holdDuration;
                } else if ([typeOfGesture isEqualToString:@"swipe"]) {
                    gestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:((UIView *)self) action:@selector(fastlpm_batteryTapped:)];
                    ((UISwipeGestureRecognizer *)gestureRecognizer).direction = swipeDirection;
                } else if ([typeOfGesture isEqualToString:@"3d"] && isForceTouchCap) {
                    gestureRecognizer = [[%c(ForceTouchGestureRecognizer) alloc] initWithTarget:((UIView *)self) action:@selector(fastlpm_batteryTapped:)];
                }
                if (gestureRecognizer) [((UIView *)self) addGestureRecognizer:gestureRecognizer];
                shouldBeInitialized = NO;
            }
        }
    }

    -(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
        return CGRectContainsPoint(CGRectInset(((UIView *)self).bounds, -areaEnlargement, -areaEnlargement), point) && shouldbeInjected ? self : nil;
    }

    %new
    -(void)fastlpm_batteryTapped:(id)sender {
        if (shouldbeInjected) {
            [saver setMode:([saver getPowerMode] == 1) ? 0 : 1];
            if (vibrationEnabled) {
                if (!isLegacyDevice) {
                    [[[UIImpactFeedbackGenerator alloc] initWithStyle:hapticStyle] impactOccurred];
                    if (repeatVibrations) {
                        double tempInterval = vibrationRepetitionInterval;
                        for (int i = 0; i < vibrationRepetitions - 1; i++) {
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, tempInterval * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                                [[[UIImpactFeedbackGenerator alloc] initWithStyle:hapticStyle] impactOccurred];
                            });
                            growingDuration ? (tempInterval *= 2) : (tempInterval += vibrationRepetitionInterval);
                        }
                    }
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
                            growingDuration ? (tempInterval *= 2) : (tempInterval += vibrationRepetitionInterval);
                        }
                    }
                }
            }
        }
    }

%end

static void fastlpm_reloadPrefs() {
    #ifndef SIMULATOR
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
            case 3: { if (@available(iOS 13.0, *)) hapticStyle = UIImpactFeedbackStyleSoft; } break;
            case 4: { if (@available(iOS 13.0, *)) hapticStyle = UIImpactFeedbackStyleRigid; } break;
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
        growingDuration = [prefs boolForKey:@"growingDuration"];
    #endif

    shouldBeRemoved = YES;
    if (enabled) shouldBeInitialized = YES;
    [batteryView setNeedsLayout];
    [batteryView layoutIfNeeded];
}

%ctor {
    #ifndef SIMULATOR
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
        [prefs registerInteger:&vibrationRepetitions default:2 forKey:@"vibrationRepetitions"];
        [prefs registerDouble:&vibrationRepetitionInterval default:0.5 forKey:@"vibrationInterval"];
        [prefs registerBool:&growingDuration default:NO forKey:@"growingDuration"];
    #endif

    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)fastlpm_reloadPrefs, CFSTR("com.redenticdev.fastlpm/ReloadPrefs"), NULL, CFNotificationSuspensionBehaviorCoalesce);
    
    
    foregroundViewClass = kCFCoreFoundationVersionNumber > 1600 ? %c(_UIStatusBarForegroundView) : %c(UIStatusBarForegroundView);

    %init(batteryViewClass = kCFCoreFoundationVersionNumber > 1600 ? objc_getClass("_UIBatteryView") : objc_getClass("UIStatusBarBatteryItemView"));
} 
