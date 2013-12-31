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
@property (nonatomic, strong) UIViewController *childViewController;
@property (nonatomic) FeedType currentFeedType;
@end


@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self showControllerWithType:0];
    
    MainNavigationBar *navBar = [AppDelegate delegate].mainNavigationBar;
    [navBar.actionButton addTarget:self action:@selector(actionButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
}


#pragma mark - IBAction

- (IBAction)segmentedControlValueChanged:(UISegmentedControl *)sender
{
    if (self.childViewController && self.currentFeedType == sender.selectedSegmentIndex) {
        if ([self.childViewController isKindOfClass:[GridViewController class]]) {
            GridViewController *controller = (id)self.childViewController;
            [controller.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
        }
    }
    else {
        [self showControllerWithType:sender.selectedSegmentIndex];
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
    // Update Navigation Bar
    
    MainNavigationBar *navBar = [AppDelegate delegate].mainNavigationBar;
    switch (type) {
        case FeedTypeSingle:
            navBar.textLabel.text = @"Single exposure shots";
            navBar.actionButton.hidden = YES;
            break;
            
        case FeedTypeGlobal:
            navBar.textLabel.text = @"Public feed";
            navBar.actionButton.hidden = YES;
            break;

        case FeedTypeFollowing:
            navBar.textLabel.text = @"From People you follow";
            navBar.actionButton.hidden = YES;
            break;
            
        case FeedTypeYou:
            navBar.textLabel.text = [PFUser currentUser][@"fullName"];
            navBar.actionButton.hidden = NO;
            [navBar.actionButton setImage:[UIImage imageNamed:@"edit"] forState:UIControlStateNormal];
            [navBar.actionButton setImage:[UIImage imageNamed:@"edit_Down"] forState:UIControlStateHighlighted];
            break;

        case FeedTypeNotifications:
            navBar.textLabel.text = @"Notifications";
            navBar.actionButton.hidden = YES;
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
        self.childViewController = [[NotificationsViewController alloc] init];
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
