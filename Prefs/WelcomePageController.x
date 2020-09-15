#import "WelcomePageController.h"

%subclass WelcomePageController : OBWelcomeController

%new
- (instancetype)initWelcomeControllerWithLocalizableTitle:(NSString *)title subtitle:(NSString *)subtitle itemsList:(OBBulletedList *)list {
    if (@available(iOS 13.0, *)) {
        void *handle = dlopen("/System/Library/PrivateFrameworks/OnBoardingKit.framework/OnBoardingKit", RTLD_LAZY);
        if (handle) {
            Class _OBWelcomeController = NSClassFromString(@"OBWelcomeController");
            Class _OBBoldTrayButton = NSClassFromString(@"OBBoldTrayButton");

            if ((self = [[_OBWelcomeController alloc] initWithTitle:localize(title, @"Root") detailText:[NSString stringWithFormat:localize(@"WHATS_NEW", @"Root"), subtitle] icon:[UIImage systemImageNamed:@"gear"]])) {
                for (OBBulletedListItem *item in list.items) {
                    [self addBulletedListItemWithTitle:item.titleLabel.text description:item.descriptionLabel.text image:item.imageView.image];
                }

                id continueButton = [_OBBoldTrayButton buttonWithType:UIButtonTypeSystem];
                [continueButton addTarget:[^{
                        [self dismissViewControllerAnimated:YES completion:nil];
                    } copy] action:@selector(invoke) forControlEvents:UIControlEventTouchUpInside];
                [continueButton setTitle:localize(@"CONTINUE", @"Root") forState:UIControlStateNormal];
                [continueButton setClipsToBounds:YES];
                [continueButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [((UIView *)continueButton).layer setCornerRadius:15];

                [self.buttonTray addButton:continueButton];
                [self.buttonTray addCaptionText:[NSString stringWithFormat:localize(@"THX_FOR_USING", @"Root"), localize(title, @"Root")]];

                self.modalPresentationStyle = UIModalPresentationAutomatic;
            }
            dlclose(handle);
            return self;
        }
        return nil;
    }
    return nil;
}

%end

%ctor {
    %config(generator=internal)
    %init;
}
