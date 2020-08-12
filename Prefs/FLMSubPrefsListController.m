#import "FLMSubPrefsListController.h"

@implementation FLMSubPrefsListController

- (instancetype)init {
    self = [super init];

    if (self) {
        FLMAppearanceSettings *appearanceSettings = [[FLMAppearanceSettings alloc] init];
        self.hb_appearanceSettings = appearanceSettings;
        self.respringButton = [[UIBarButtonItem alloc] initWithTitle:localize(@"RESPRING", @"Root") style:UIBarButtonItemStylePlain target:self action:@selector(respring)];
        self.navigationItem.rightBarButtonItem = self.respringButton;
    }

    return self;
}

- (id)specifiers {
    return _specifiers;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.navigationController.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
}

- (void)loadFromSpecifier:(PSSpecifier *)specifier {
    NSString *title = [specifier name];

    _specifiers = [[self loadSpecifiersFromPlistName:[specifier propertyForKey:@"FLMSub"] target:self] retain];

    [self setTitle:title];
    [self.navigationItem setTitle:title];
}

- (void)setSpecifier:(PSSpecifier *)specifier {
    [self loadFromSpecifier:specifier];
    [super setSpecifier:specifier];
}

- (BOOL)shouldReloadSpecifiersOnResume {
    return NO;
}

- (void)respring {
	UIAlertController *respring = [UIAlertController alertControllerWithTitle:localize(@"FASTLPM", @"Root") message:localize(@"RESPRING_PROMPT", @"Root") preferredStyle:UIAlertControllerStyleAlert];
	UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:localize(@"YES_PROMPT", @"Root") style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
		[HBRespringController respring];
	}];
	UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:localize(@"NO_PROMPT", @"Root") style:UIAlertActionStyleCancel handler:nil];

	[respring addAction:confirmAction];
	[respring addAction:cancelAction];
	[self presentViewController:respring animated:YES completion:nil];
}
@end
