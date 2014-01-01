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
#import "MainNavigationBar.h"


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
    
    self.leftLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 240, 20)];
    self.leftLabel.textColor = [UIColor grayColor];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.leftLabel];
    
    self.rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightButton];
    
    MainNavigationBar *navBar = [AppDelegate delegate].mainNavigationBar;
    navBar.segmentedControl = self.segmentedControl;
    self.navigationItem.titleView = nil;
    
    [self showControllerWithType:0];
}


#pragma mark - IBAction

- (IBAction)segmentedControlValueChanged:(UISegmentedControl *)sender
{
    if (self.childViewController && self.currentFeedType == sender.selectedSegmentIndex) {
        [self.navigationController popToRootViewControllerAnimated:YES];
        if ([self.childViewController isKindOfClass:[GridViewController class]]) {
            GridViewController *controller = (id)self.childViewController;
            [controller.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
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
    if (self.currentFeedType == FeedTypeYou) {
        EditProfileViewController *controller = [EditProfileViewController controller];
        [self presentViewController:controller animated:YES completion:nil];
    }
}

- (void)showControllerWithType:(FeedType)type
{
    switch (type) {
        case FeedTypeSingle:
            self.leftLabel.text = @"Single exposure shots";
            self.rightButton.hidden = YES;
            break;
            
        case FeedTypeGlobal:
            self.leftLabel.text = @"Public feed";
            self.rightButton.hidden = YES;
            break;

        case FeedTypeFollowing:
            self.leftLabel.text = @"From People you follow";
            self.rightButton.hidden = YES;
            break;
            
        case FeedTypeYou:
            self.leftLabel.text = [PFUser currentUser][@"fullName"];
            self.rightButton.hidden = NO;
            [self.rightButton setImage:[UIImage imageNamed:@"edit"] forState:UIControlStateNormal];
            [self.rightButton setImage:[UIImage imageNamed:@"edit_Down"] forState:UIControlStateHighlighted];
            break;

        case FeedTypeNotifications:
            self.leftLabel.text = @"Notifications";
            self.rightButton.hidden = YES;
            break;

        default:
            break;
    }
    
    
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

@end
