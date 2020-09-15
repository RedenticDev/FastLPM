#import <UIKit/UIKit.h>
#include <dlfcn.h>

#define localize(a, b) NSLocalizedStringWithDefaultValue(a, b, [NSBundle bundleWithPath:@"/Library/PreferenceBundles/FLMPrefs.bundle"], nil, nil)

@interface UIImage (Tweak)
+(id)systemImageNamed:(id)arg1;
@end

@interface OBButtonTray : UIView
-(void)addButton:(id)arg1;
-(void)addCaptionText:(id)arg1;
@end

@interface OBBoldTrayButton : UIButton
-(void)setTitle:(id)arg1 forState:(unsigned long long)arg2;
+(id)buttonWithType:(long long)arg1;
@end

@interface OBBulletedList : UIView
@property (nonatomic, retain) NSMutableArray *items;
-(void)addItemWithTitle:(id)arg1 description:(id)arg2 image:(id)arg3;
@end

@interface OBBulletedListItem : UIView
@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UILabel *descriptionLabel;
@property (nonatomic, retain) UIImageView *imageView;
@end

@interface OBWelcomeController : UIViewController
-(OBButtonTray *)buttonTray;
-(id)initWithTitle:(id)arg1 detailText:(id)arg2 icon:(id)arg3;
-(void)addBulletedListItemWithTitle:(id)arg1 description:(id)arg2 image:(id)arg3;
@end

@interface WelcomePageController : OBWelcomeController
-(instancetype)initWelcomeControllerWithLocalizableTitle:(NSString *)title subtitle:(NSString *)subtitle itemsList:(OBBulletedList *)list API_AVAILABLE(ios(13.0));
@end
