#import <Preferences/PSListController.h>
#import <Preferences/PSListItemsController.h>
#import <Preferences/PSSpecifier.h>
#import <CepheiPrefs/HBListController.h>
#import <CepheiPrefs/HBAppearanceSettings.h>
#import <Cephei/HBRespringController.h>

#define localize(a, b) NSLocalizedStringWithDefaultValue(a, b, [NSBundle bundleWithPath:@"/Library/PreferenceBundles/FLMPrefs.bundle"], nil, nil)

@interface FLMAppearanceSettings : HBAppearanceSettings
@end

@interface FLMSubPrefsListController : HBListController
@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UIBarButtonItem *respringButton;

-(void)respring;
@end
