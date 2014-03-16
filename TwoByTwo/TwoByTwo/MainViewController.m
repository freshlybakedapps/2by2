//
//  MainViewController.m
//  TwoByTwo
//
//  Created by Joseph Lin on 9/10/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import "MainViewController.h"
#import "FeedViewController.h"
#import "EditProfileViewController.h"
#import "NotificationsViewController.h"
#import "CameraViewController.h"
#import "UIImage+Addon.h"

NSString * const NoficationDidUpdatePushNotificationCount = @"NoficationDidUpdatePushNotificationCount";
NSString * const NoficationUserInfoKeyCount = @"NoficationUserInfoKeyCount";
NSString * const NoficationShouldReloadPhotos = @"NoficationShouldReloadPhotos";


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
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNotificationCount:) name:NoficationDidUpdatePushNotificationCount object:nil];

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
        if ([self.childViewController isKindOfClass:[FeedViewController class]]) {
            FeedViewController *controller = (id)self.childViewController;
            [controller.collectionView setContentOffset:CGPointMake(0, -controller.collectionView.contentInset.top) animated:YES];
        }
    }
    else {
        [self showControllerWithType:sender.selectedSegmentIndex];
    }
}

- (IBAction)cameraButtonTapped:(id)sender
{
    CameraViewController *controller = [CameraViewController controller];
    [self presentViewController:controller animated:YES completion:nil];
}


#pragma mark - Child Controller

- (void)showControllerWithType:(FeedType)type
{
    // Show Child Controller
    
    if (self.childViewController) {
        [self.childViewController willMoveToParentViewController:nil];
        [self.childViewController.view removeFromSuperview];
        [self.childViewController removeFromParentViewController];
    }
    
    if (type == FeedTypeNotifications) {
        NotificationsViewController *controller = [NotificationsViewController controller];
        self.childViewController = controller;
    }
    else {
        FeedViewController *controller = [FeedViewController controller];
        controller.type = type;
        self.childViewController = controller;
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
        UIImage *image = [UIImage circleWithNumber:count.integerValue radius:30];
        [self.segmentedControl setImage:image forSegmentAtIndex:FeedTypeNotifications];
    }
    else {
        UIImage *image = [UIImage imageNamed:@"notifications_Active"];
        [self.segmentedControl setImage:image forSegmentAtIndex:FeedTypeNotifications];
    }
}

@end