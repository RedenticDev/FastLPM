#import "FLMRootListController.h"

@implementation FLMAppearanceSettings

- (UIColor *)tableViewCellSeparatorColor {
    return [UIColor colorWithWhite:0 alpha:0];
}

- (BOOL)translucentNavigationBar {
    return NO;
}

- (HBAppearanceSettingsLargeTitleStyle)largeTitleStyle {
    return HBAppearanceSettingsLargeTitleStyleNever;
}

@end
