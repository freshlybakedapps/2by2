//
//  MainViewController.m
//  TwoByTwo
//
//  Created by Joseph Lin on 9/10/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import "MainViewController.h"
#import "GridViewController.h"
#import "EditProfileViewController.h"
#import "NotificationsViewController.h"

NSString * const NoficationDidUpdatePushNotificationCount = @"NoficationDidUpdatePushNotificationCount";
NSString * const NoficationUserInfoKeyCount = @"NoficationUserInfoKeyCount";


@interface MainViewController ()
@property (nonatomic, strong) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic, strong) UILabel *leftLabel;
@property (nonatomic, strong) UIButton *rightButton;
@property (nonatomic, strong) UIViewController *childViewController;
@property (nonatomic) FeedType currentFeedType;
@end


@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNotificationCount:) name:NoficationDidUpdatePushNotificationCount object:nil];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    [self showControllerWithType:0];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - IBAction

- (IBAction)segmentedControlValueChanged:(UISegmentedControl *)sender
{
    if (self.childViewController && self.currentFeedType == sender.selectedSegmentIndex) {
        [self.navigationController popToRootViewControllerAnimated:YES];
        if ([self.childViewController isKindOfClass:[GridViewController class]]) {
            GridViewController *controller = (id)self.childViewController;
            if ([controller.collectionView numberOfItemsInSection:0] > 0) {
                [controller.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
            }
        }
    }
    else {
        // Must call 'showControllerWithType' BEFORE poping child view controller, otherwise the collectionView contentInset will mess up.
        [self showControllerWithType:sender.selectedSegmentIndex];
        [self.navigationController popToRootViewControllerAnimated:NO];
    }
}

- (IBAction)actionButtonTapped:(id)sender
{
    NSLog(@"EditProfileViewController");
    if (self.currentFeedType == FeedTypeYou) {
        EditProfileViewController *controller = [EditProfileViewController controller];
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (void)showControllerWithType:(FeedType)type
{
    // Show Child Controller
    
    if (self.childViewController) {
        [self.childViewController willMoveToParentViewController:nil];
        [self.childViewController.view removeFromSuperview];
        [self.childViewController removeFromParentViewController];
    }
    
    if (type == FeedTypeNotifications) {
        self.childViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"NotificationsViewController"];
    }
    else {
        self.childViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"GridViewController"];
        ((GridViewController *)self.childViewController).type = type;
    }
    
    [self addChildViewController:self.childViewController];
    self.childViewController.view.frame = self.view.bounds;
    [self.view insertSubview:self.childViewController.view atIndex:0];
    [self.childViewController didMoveToParentViewController:self];
    
    self.currentFeedType = type;
}


#pragma mark - Notification

- (void)updateNotificationCount:(NSNotification *)notification
{
    NSNumber *count = notification.userInfo[NoficationUserInfoKeyCount];
    if (count.integerValue) {
        UIImage *image = [self circleWithNumber:count.integerValue radius:30];
        [self.segmentedControl setImage:image forSegmentAtIndex:4];
    }
    else {
        UIImage *image = [UIImage imageNamed:@"notifications_Active"];
        [self.segmentedControl setImage:image forSegmentAtIndex:4];
    }
}

- (UIImage *)circleWithNumber:(NSInteger)number radius:(CGFloat)radius
{
    CGRect rect = CGRectMake(0, 0, radius, radius);
    
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // 1. Draw image the first time to use as mask
    [[UIColor blackColor] setFill];
    CGContextFillEllipseInRect (context, rect);
    
    NSString *text = [NSString stringWithFormat:@"%d", number];
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    [text drawInRect:CGRectOffset(rect, 0, 6) withAttributes:@{
                                                               NSFontAttributeName:[UIFont appMediumFontOfSize:14],
                                                               NSForegroundColorAttributeName:[UIColor whiteColor],
                                                               NSParagraphStyleAttributeName:paragraphStyle,
                                                               }];
    
    // 2. Create Mask
    CGContextConcatCTM(context, CGAffineTransformMake(1, 0, 0, -1, 0, CGRectGetHeight(rect)));
    CGImageRef image = CGBitmapContextCreateImage(context);
    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(image), CGImageGetHeight(image), CGImageGetBitsPerComponent(image), CGImageGetBitsPerPixel(image), CGImageGetBytesPerRow(image), CGImageGetDataProvider(image), CGImageGetDecode(image), CGImageGetShouldInterpolate(image));
    CFRelease(image);
    
    
    
    // 3. Clear, apply mask, and then draw image the second time
    CGContextClearRect(context, rect);
    
    CGContextSaveGState(context);
    CGContextClipToMask(context, rect, mask);
    CFRelease(mask);
    
    [[UIColor appRedColor] setFill];
    CGContextFillEllipseInRect (context, rect);
    
    CGContextRestoreGState(context);
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    return finalImage;
}

@end