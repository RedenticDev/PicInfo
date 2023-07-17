// UIWindow *rootViewController -> PUTabbedLibraryViewController *childViewControllers 0 -> PUNavigationController *presentedViewController -> __PUOneUpViewController__ *previewActionController -> PUPreviewActionController -> NSArray *actions

@interface PUOneUpViewController: UIViewController
-(id)pu_debugCurrentAsset;
@end

@interface PUPreviewActionController: NSObject
-(id)delegate;
@end

@interface PHAsset: NSObject
@property (nonatomic, readonly) NSString *originalFilename;
@property (nonatomic, readonly) CGSize size;
@property (nonatomic, readonly) NSInteger originalFilesize;
@property (nonatomic, readonly) NSDate *creationDate;
@property (nonatomic, readonly) NSDate *modificationDate;
// @property (nonatomic, readonly) CLLocation *location;
@property (nonatomic, readonly) NSDictionary *imageProperties;
@end

BOOL enabled = YES;

static NSString* toFormattedDate(NSDate *date) {
    // @"MM/dd/YYYY @ hh:m a"
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterShortStyle;
    dateFormatter.timeStyle = NSDateFormatterShortStyle;
    return [dateFormatter stringFromDate:date];
}

static UIViewController* infoViewFromAsset(PHAsset *assets) {
    NSString *msg = [NSString stringWithFormat:@"Name: %@\nDimension: %@\nSize: %@\nCreation date: %@\nModification date: %@\nLocation: %@\nType: %@",
    assets.originalFilename, [NSString stringWithFormat:@"%.fx%.f", assets.size.width, assets.size.height], [NSByteCountFormatter stringFromByteCount:assets.originalFilesize countStyle:NSByteCountFormatterCountStyleFile], toFormattedDate(assets.creationDate), toFormattedDate(assets.modificationDate), /*assets.location*/@"nil", [[assets.imageProperties objectForKey:@"{Exif}"] objectForKey:@"UserComment"]];

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"PicInfo" message:msg preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil]];
    return alert;
}

%hook PUPreviewActionController

    - (NSArray *)actions {
        NSMutableArray *menuList = [%orig mutableCopy];
        if (!menuList) menuList = [NSMutableArray new];

        if (enabled) {
            PHAsset *picAssets = (PHAsset *)[(PUOneUpViewController *)[self delegate] pu_debugCurrentAsset];
            UIAction *picInfoAction = [UIAction actionWithTitle:@"Picture Info" image:[UIImage systemImageNamed:@"info.circle"] identifier:nil handler:^(UIAction *action) {
                [[UIApplication sharedApplication].windows[0].rootViewController presentViewController:infoViewFromAsset(picAssets) animated:YES completion:nil];
            }];
            [menuList insertObject:picInfoAction atIndex:0];
        }

        return menuList;
    }

%end