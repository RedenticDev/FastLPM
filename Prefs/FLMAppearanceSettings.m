#import "FLMRootListController.h"

@implementation FLMAppearanceSettings

-(UIColor *)tableViewCellSeparatorColor {
    return [UIColor colorWithWhite:0 alpha:0];
}

-(BOOL)translucentNavigationBar {
    return NO;
}

-(NSUInteger)largeTitleStyle {
    return 2;
}

@end
