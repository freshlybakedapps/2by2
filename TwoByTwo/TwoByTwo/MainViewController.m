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
#import "MainNavBar.h"


@interface MainViewController ()
@property (nonatomic, strong) UIViewController *childViewController;
@end


@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self showControllerWithType:0];
    //self.segControl.frame = CGRectMake(0.0, 20.0, self.segControl.frame.size.width, self.segControl.frame.size.height);
}

+ (void) updateNotification:(int)n{
    UINavigationController *navController =(UINavigationController*)[[[[UIApplication sharedApplication]delegate] window] rootViewController];
    MainNavBar *mnb = (MainNavBar*)navController.navigationBar;
    [mnb updateNotification:n];
}


- (IBAction)segmentedControlValueChanged:(UISegmentedControl *)sender
{
    [self showControllerWithType:sender.selectedSegmentIndex];
}

- (void)editProfile{
    EditProfileViewController *controller = [EditProfileViewController controller];
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)showControllerWithType:(FeedType)type
{
    
    /*
    if(self.childViewController != nil && self.currentFeedType == type && self.currentFeedType != FeedTypeNotifications){
        
        NSLog(@"showControllerWithType");
        //GridViewController* c = (GridViewController*)self.childViewController;
         //[c scrollToTop];
     
        //return;
    }
    */
    
    
    if(!self.label){
        self.label = [ [UILabel alloc ] initWithFrame:CGRectMake(20.0, 80.0, 320.0, 43.0) ];
        self.label.textColor = [UIColor grayColor];
        //self.label.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(36.0)];
        [self.navigationController.view addSubview:self.label];
    }
    
    if(type == FeedTypeYou){
        if(!self.button){
            self.button = [UIButton buttonWithType:UIButtonTypeCustom];
            [self.button addTarget:self action:@selector(editProfile) forControlEvents:UIControlEventTouchDown];
            [self.button setImage:[UIImage imageNamed:@"edit"] forState:UIControlStateNormal];
            [self.button setImage:[UIImage imageNamed:@"edit_Down"] forState:UIControlStateSelected];
            self.button.frame = CGRectMake(self.view.frame.size.width - (26+20), 80.0, 26.0, 26.0);
        }
        [self.navigationController.view addSubview:self.button];
    }else{
        [self.button removeFromSuperview];
    }
    
    switch (type) {
        case FeedTypeYou:
            //NewNav_06.psd
            self.label.text = [PFUser currentUser][@"fullName"];
            break;
        case FeedTypeSingle:
            //NewNav_03.psd
            self.label.text = @"Single exposure shots";
            //These photos are waiting for a final exposure before they go to the public feed. Tap on any of these  to expose a second shot over them
            break;
        case FeedTypeFollowing:
            //NewNav_05.psd
            self.label.text = @"From People you follow";
            break;
        case FeedTypeNotifications:
            self.label.text = @"Notifications";
            break;
        case FeedTypeGlobal:
            //NewNav_04.psd
            self.label.text = @"Public feed";
            break;
        default:
            break;
    }

    
    
    if (self.childViewController) {
        [self.childViewController willMoveToParentViewController:nil];
        [self.childViewController.view removeFromSuperview];
        [self.childViewController removeFromParentViewController];
    }
    
    id controller;
    
    if(type == FeedTypeNotifications){
        controller = [[NotificationsViewController alloc] init];
        NotificationsViewController* c = (NotificationsViewController*) controller;
    }else{
        controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"GridViewController"];
        
        GridViewController* c = (GridViewController*) controller;
        c.type = type;
    }
    
    //GridViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"GridViewController"];
    //controller.type = type;
    self.childViewController = controller;
    
    [self addChildViewController:self.childViewController];
    self.childViewController.view.frame = self.view.bounds;
    [self.view insertSubview:self.childViewController.view atIndex:0];
    [self.childViewController didMoveToParentViewController:self];
    
    self.currentFeedType = type;
}

@end
