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

static NSString * const FacebookNameKey = @"name";
static NSString * const FacebookUsernameKey = @"username";
static NSString * const FacebookEmailKey = @"email";
static NSString * const FacebookIDKey = @"id";


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


- (IBAction)linkAccountButtonTapped:(id)sender
{
    
    /*
    [PFFacebookUtils unlinkUserInBackground:[PFUser currentUser] block:^(BOOL succeeded, NSError *error) {
        if (!error) {
            [PFUser currentUser].email = @"";
            [PFUser currentUser].facebookID = @"";
            
            [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if(error){
                    NSLog(@"FB unlinkUser: %@",error.description);
                }
            }];
        }

    }];
    */
    
    
    if(![PFUser currentUser].facebookID || [[PFUser currentUser].facebookID isEqualToString:@""]){
        
        [PFFacebookUtils linkUser:[PFUser currentUser] permissions:@[@"user_about_me", @"email"] block:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                FBRequest *request = [FBRequest requestForGraphPath:@"me"];
                [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                    
                    if (!error) {
                        
                        NSString *email = result[FacebookEmailKey];
                        NSString *facebookId = result[FacebookIDKey];
                        [PFUser currentUser].email = email;
                        [PFUser currentUser].facebookID = facebookId;
                        
                        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            if(error){
                                NSLog(@"FB login %@",error.description);
                            }
                        }];
                    }
                }];
            }
        }];
        
    }
    
    if(![PFTwitterUtils twitter].screenName){
        
    }

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
