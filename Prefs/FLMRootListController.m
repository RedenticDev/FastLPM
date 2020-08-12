#include "FLMRootListController.h"
#include "WelcomePageController.h"

@implementation FLMRootListController

- (instancetype)init {
    if (self = [super init]) {
        HBAppearanceSettings *appearanceSettings = [[FLMAppearanceSettings alloc] init];
        self.hb_appearanceSettings = appearanceSettings;
        self.respringButton = [[UIBarButtonItem alloc] initWithTitle:localize(@"RESPRING", @"Root") style:UIBarButtonItemStylePlain target:self action:@selector(respring)];
        self.navigationItem.rightBarButtonItem = self.respringButton;

        self.navigationItem.titleView = [UIView new];
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:17];
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.titleLabel.text = localize(@"FASTLPM", @"Root");
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.navigationItem.titleView addSubview:self.titleLabel];

        self.iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        self.iconView.contentMode = UIViewContentModeScaleAspectFit;
        self.iconView.image = [UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/FLMPrefs.bundle/icon@2x.png"];
        self.iconView.translatesAutoresizingMaskIntoConstraints = NO;
        self.iconView.alpha = 0.0;
        [self.navigationItem.titleView addSubview:self.iconView];

        [NSLayoutConstraint activateConstraints:@[
            [self.titleLabel.topAnchor constraintEqualToAnchor:self.navigationItem.titleView.topAnchor],
            [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.navigationItem.titleView.leadingAnchor],
            [self.titleLabel.trailingAnchor constraintEqualToAnchor:self.navigationItem.titleView.trailingAnchor],
            [self.titleLabel.bottomAnchor constraintEqualToAnchor:self.navigationItem.titleView.bottomAnchor],
            [self.iconView.topAnchor constraintEqualToAnchor:self.navigationItem.titleView.topAnchor],
            [self.iconView.leadingAnchor constraintEqualToAnchor:self.navigationItem.titleView.leadingAnchor],
            [self.iconView.trailingAnchor constraintEqualToAnchor:self.navigationItem.titleView.trailingAnchor],
            [self.iconView.bottomAnchor constraintEqualToAnchor:self.navigationItem.titleView.bottomAnchor],
        ]];
    }

    return self;
}

-(NSArray *)specifiers {
	if (_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"Root" target:self] retain];
	}

	return _specifiers;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    self.headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    self.headerImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.headerImageView.image = [UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/FLMPrefs.bundle/Banner.png"];
    self.headerImageView.translatesAutoresizingMaskIntoConstraints = NO;

    UILabel *versionTitle = [[UILabel alloc] initWithFrame:CGRectMake(140, 105, 200, 30)];
    versionTitle.text = [self packageVersion];
    versionTitle.textColor = [UIColor whiteColor];
    [versionTitle setFont:[UIFont systemFontOfSize:24.0f]];
    versionTitle.numberOfLines = 0;
    versionTitle.lineBreakMode = NSLineBreakByWordWrapping;
    [versionTitle sizeToFit];
    [self.headerImageView addSubview:versionTitle];
    versionTitle.layer.shadowColor = [UIColor blackColor].CGColor;
    versionTitle.layer.shadowRadius = 3.0;
    versionTitle.layer.shadowOpacity = 0.4;
    versionTitle.layer.shadowOffset = CGSizeMake(1, 1);
    versionTitle.layer.masksToBounds = NO;

    [self.headerView addSubview:self.headerImageView];
    [NSLayoutConstraint activateConstraints:@[
        [self.headerImageView.topAnchor constraintEqualToAnchor:self.headerView.topAnchor],
        [self.headerImageView.leadingAnchor constraintEqualToAnchor:self.headerView.leadingAnchor],
        [self.headerImageView.trailingAnchor constraintEqualToAnchor:self.headerView.trailingAnchor],
        [self.headerImageView.bottomAnchor constraintEqualToAnchor:self.headerView.bottomAnchor],
    ]];

    _table.tableHeaderView = self.headerView;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    // Setting up welcome view
    if (@available(iOS 13.0, *)) {
        NSString *version = [self packageVersion];
        NSString *localePath = [NSString stringWithFormat:@"/Library/PreferenceBundles/FLMPrefs.bundle/%@.lproj/Changelog.strings", [[NSLocale currentLocale] languageCode]];
        if (![[NSFileManager defaultManager] fileExistsAtPath:localePath]) {
            localePath = @"/Library/PreferenceBundles/FLMPrefs.bundle/base.lproj/Changelog.strings";
        }
        NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:PLIST_PATH];
        if (![prefs objectForKey:version]) {
            NSDictionary *changeDict = [NSDictionary dictionaryWithContentsOfURL:[NSURL fileURLWithPath:localePath isDirectory:NO] error:nil];
            NSMutableArray *sortedChanges = [NSMutableArray new];
            for (NSString *key in [[changeDict allKeys] sortedArrayUsingSelector:@selector(compare:)]) {
                [sortedChanges addObject:changeDict[key]];
            }

            OBBulletedList *bulletedList = [[OBBulletedList alloc] init];
            for (int i = 0; i < sortedChanges.count - 2; i += 3) {
                NSString *icon = nil;
                NSString *unformattedIcon = [sortedChanges objectAtIndex:i];
                if ([unformattedIcon isEqualToString:@"new"]) {
                    icon = @"plus.circle.fill";
                } else if ([unformattedIcon isEqualToString:@"fix"]) {
                    icon = @"checkmark.circle.fill";
                } else if ([unformattedIcon isEqualToString:@"removed"]) {
                    icon = @"minus.circle";
                } 
                NSString *title = [sortedChanges objectAtIndex:i + 1];
                NSString *content = [sortedChanges objectAtIndex:i + 2];
                [bulletedList addItemWithTitle:title description:content image:[UIImage systemImageNamed:icon]];
            }

            OBWelcomeController *welcomeController = [[WelcomePageController alloc] initWelcomeControllerWithLocalizableTitle:@"FASTLPM" subtitle:version itemsList:bulletedList];
            [self presentViewController:welcomeController animated:YES completion:nil];

            [prefs setObject:@YES forKey:version];
            [prefs writeToFile:PLIST_PATH atomically:YES];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    tableView.tableHeaderView = self.headerView;
    return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    CGRect frame = self.table.bounds;
    frame.origin.y = -frame.size.height;

    self.navigationController.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.00 green:0.00 blue:1.00 alpha:1.00];
    [self.navigationController.navigationController.navigationBar setShadowImage:[UIImage new]];
    self.navigationController.navigationController.navigationBar.translucent = NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetY = scrollView.contentOffset.y;

    if (offsetY > 200) {
        [UIView animateWithDuration:0.2 animations:^{
            self.iconView.alpha = 1.0;
            self.titleLabel.alpha = 0.0;
        }];
    } else {
        [UIView animateWithDuration:0.2 animations:^{
            self.iconView.alpha = 0.0;
            self.titleLabel.alpha = 1.0;
        }];
    }

    self.headerImageView.frame = CGRectMake(0, 0, self.headerImageView.frame.size.width, 200 - (offsetY + 200));
}

// Beginning of useful code
- (NSString *)packageVersion {
    char ver[64];
    FILE *fp = popen("dpkg -s com.redenticdev.fastlpm | grep -i version | cut -d':' -f2 | xargs", "r");
    fscanf(fp, "%s", ver);
    pclose(fp);
    return [NSString stringWithFormat:@"v%@", [NSString stringWithCString:ver encoding:NSUTF8StringEncoding]];
}

- (void)resetPreferences {
    [[NSFileManager defaultManager] removeItemAtPath:@"/var/mobile/Library/Preferences/com.redenticdev.fastlpm.plist" error:nil];
    [HBRespringController respring];
}

- (void)respring {
	UIAlertController *respring = [UIAlertController alertControllerWithTitle:localize(@"FASTLPM", @"Root") message:localize(@"RESPRING_PROMPT", @"Root") preferredStyle:UIAlertControllerStyleAlert];
	UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:localize(@"YES_PROMPT", @"Root") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {
		[HBRespringController respring];
	}];

	UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:localize(@"NO_PROMPT", @"Root") style:UIAlertActionStyleCancel handler:nil];

	[respring addAction:confirmAction];
	[respring addAction:cancelAction];
	[self presentViewController:respring animated:YES completion:nil];
}

@end

@implementation RCLabeledSliderCell // Improved version of kritanta's KRLabeledSliderCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier specifier:(PSSpecifier*)specifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier specifier:specifier]) {
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, 300, 20)];
        label.text = localize(specifier.properties[@"label"], (specifier.properties[@"strings"] ? specifier.properties[@"strings"] : @"Root"));
        label.numberOfLines = 0;
        label.lineBreakMode = NSLineBreakByWordWrapping;
        [label sizeToFit];
        [self.contentView insertSubview:label atIndex:0];
        specifier.properties[@"height"] = [NSString stringWithFormat:@"%ld", (NSInteger)(label.frame.size.height + self.frame.size.height) + 20];
    }

    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    [self.control setFrame:CGRectMake(self.control.frame.origin.x, self.frame.size.height - 45, self.control.frame.size.width, self.control.frame.size.height)];
}

@end
