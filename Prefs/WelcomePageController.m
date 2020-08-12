#import "WelcomePageController.h"

@implementation WelcomePageController

- (instancetype)initWelcomeControllerWithLocalizableTitle:(NSString *)title subtitle:(NSString *)subtitle itemsList:(OBBulletedList *)list {
    if (self = [super initWithTitle:localize(title, @"Root") detailText:[NSString stringWithFormat:localize(@"WHATS_NEW", @"Root"), subtitle] icon:[UIImage systemImageNamed:@"gear"]]) {
        for (OBBulletedListItem *item in list.items) {
            [self addBulletedListItemWithTitle:item.titleLabel.text description:item.descriptionLabel.text image:item.imageView.image];
        }

        OBBoldTrayButton *continueButton = [OBBoldTrayButton buttonWithType:UIButtonTypeSystem];
        [continueButton addTarget:[^{
                [self dismissViewControllerAnimated:YES completion:nil];
            } copy] action:@selector(invoke) forControlEvents:UIControlEventTouchUpInside];
        [continueButton setTitle:localize(@"CONTINUE", @"Root") forState:UIControlStateNormal];
        [continueButton setClipsToBounds:YES];
        [continueButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [continueButton.layer setCornerRadius:15];

        [self.buttonTray addButton:continueButton];
        [self.buttonTray addCaptionText:[NSString stringWithFormat:localize(@"THX_FOR_USING", @"Root"), localize(title, @"Root")]];

        self.modalPresentationStyle = UIModalPresentationAutomatic;
    }
    return self;
}

@end