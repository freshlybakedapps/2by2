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
@property (nonatomic, weak) IBOutlet UITableViewCell *linkCell1;
@property (nonatomic, weak) IBOutlet UITableViewCell *linkCell2;
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


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(cell == self.linkCell1){
        
        cell.textLabel.textColor = [UIColor appGreenColor];
        
        if(![PFUser currentUser].facebookID || [[PFUser currentUser].facebookID isEqualToString:@""]){
            cell.textLabel.text = @"Connect Facebook account";
        }else if(![PFTwitterUtils twitter].screenName || [[PFTwitterUtils twitter].screenName isEqualToString:@""]){
            cell.textLabel.text = @"Connect Twitter account";
        }else{
            cell.textLabel.text = @"Disconnect Twitter account";
        }
    }else if(cell == self.linkCell2){
        if([PFUser currentUser].facebookID && ![[PFUser currentUser].facebookID isEqualToString:@""] && [PFTwitterUtils twitter].screenName && ![[PFTwitterUtils twitter].screenName isEqualToString:@""]){
            cell.textLabel.textColor = [UIColor appGreenColor];
            cell.textLabel.text = @"Disconnect Facebook account";
            cell.hidden = NO;
        }else{
            cell.hidden = YES;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (cell == self.linkCell2) {
        if([PFUser currentUser].facebookID && [PFTwitterUtils twitter].screenName){
            [PFFacebookUtils unlinkUserInBackground:[PFUser currentUser] block:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    [PFUser currentUser].email = @"";
                    [PFUser currentUser].facebookID = @"";
                    
                    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if(error){
                            NSLog(@"FB unlinkUser: %@",error.description);
                        }
                        
                        [tableView reloadData];
                    }];
                }
                
            }];

        }
    
    }
    
    if (cell == self.linkCell1) {
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
                                
                                [tableView reloadData];
                            }];
                        }
                    }];
                }
            }];
            
        }else if(![PFTwitterUtils twitter].screenName || [[PFTwitterUtils twitter].screenName isEqualToString:@""]){
            
            
            [PFTwitterUtils linkUser:[PFUser currentUser] block:^(BOOL succeeded, NSError *error) {
                NSString * requestString = [NSString stringWithFormat:@"https://api.twitter.com/1.1/users/show.json?screen_name=%@", [PFTwitterUtils twitter].screenName];
                
                
                NSURL *verify = [NSURL URLWithString:requestString];
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:verify];
                [[PFTwitterUtils twitter] signRequest:request];
                NSURLResponse *response = nil;
                NSData *data = [NSURLConnection sendSynchronousRequest:request
                                                     returningResponse:&response
                                                                 error:&error];
                
                if ( error == nil){
                    NSDictionary* result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
                    NSString* imageURL = [[result objectForKey:@"profile_image_url"] stringByReplacingOccurrencesOfString:@"_normal.jpeg" withString:@"_bigger.jpeg"];
                    [[PFUser currentUser] setObject:imageURL forKey:@"TwitterProfileImage"];
                    [[PFUser currentUser] setObject:[PFTwitterUtils twitter].userId forKey:@"twitterId"];
                    
                    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if(error){
                            NSLog(@"Twitter login %@",error.description);
                        }
                        
                        [tableView reloadData];
                    }];
                }
            }];
        }else{
            
            [PFTwitterUtils unlinkUserInBackground:[PFUser currentUser] block:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    [[PFUser currentUser] setObject:@"" forKey:@"TwitterProfileImage"];
                    [[PFUser currentUser] setObject:@"" forKey:@"twitterId"];
                    
                    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if(error){
                            NSLog(@"FB unlinkUser: %@",error.description);
                        }
                        
                        [tableView reloadData];
                    }];
                }
                
            }];

            
        }

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
