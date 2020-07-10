#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import <Preferences/PSSliderTableCell.h>
#import <CepheiPrefs/HBRootListController.h>
#import <CepheiPrefs/HBAppearanceSettings.h>
#import <Cephei/HBPreferences.h>
#import <Cephei/HBRespringController.h>

#define localize(a, b) NSLocalizedStringWithDefaultValue(a, b, [NSBundle bundleWithPath:@"/Library/PreferenceBundles/FLMPrefs.bundle"], nil, nil)

@interface RCLabeledSliderCell : PSSliderTableCell
@end

@interface FLMAppearanceSettings : HBAppearanceSettings
@end

@interface FLMRootListController : HBRootListController {
    UITableView * _table;
}

@property (nonatomic, retain) UIBarButtonItem *respringButton;
@property (nonatomic, retain) UIView *headerView;
@property (nonatomic, retain) UIImageView *headerImageView;
@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UIImageView *iconView;

-(void)resetPreferences;
-(void)respring;

@end
