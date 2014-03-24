//
//  EverythingElseViewController.m
//  TwoByTwo
//
//  Created by John Tubert on 11/27/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import "EverythingElseViewController.h"
#import "NotificationSettingsViewController.h"
#import "AboutViewController.h"
#import "FindInviteFriendsViewController.h"
#import "AppDelegate.h"

typedef NS_ENUM(NSUInteger, TableViewRow) {
    TableViewRowAbout = 0,
    TableViewRowNotifications,
    TableViewRowFriends,
    TableViewRowLogout,
    TableViewRowCount,
};


@interface EverythingElseViewController ()
@end


@implementation EverythingElseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Everything else";
    [[UINavigationBar appearance] setTitleTextAttributes:@{
                                                           NSForegroundColorAttributeName:[UIColor appGrayColor],
                                                           NSFontAttributeName:[UIFont appMediumFontOfSize:14],
                                                           }];

    
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (IBAction)logoutButtonTapped:(id)sender
{
    [UIAlertView bk_showAlertViewWithTitle:@"Confirm" message:@"Are you sure you want to logout?" cancelButtonTitle:@"Cancel" otherButtonTitles:@[@"OK"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            [PFUser logOut];
            [[AppDelegate delegate] showLoginViewController];
        }
    }];
}

@end
