//
//  LoginViewController.m
//  TwoByTwo
//
//  Created by John Tubert on 10/11/13.
//
//

#import "LoginViewController.h"
#import "AppDelegate.h"


@interface LoginViewController ()
@property (nonatomic, weak) IBOutlet UIButton *termsButton;
@end


@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.termsButton.titleLabel.numberOfLines = 2;
    self.termsButton.titleLabel.textAlignment = NSTextAlignmentCenter;
}

- (IBAction)loginButtonTouchHandler:(id)sender
{    
    // Login PFUser using facebook
    [PFFacebookUtils logInWithPermissions:@[@"user_about_me", @"email"] block:^(PFUser *user, NSError *error) {
        if (!user) {
            if (!error) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
                [[[UIAlertView alloc] initWithTitle:@"Log In Error" message:@"Uh oh. The user cancelled the Facebook login." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
            }
            else {
                NSLog(@"Uh oh. An error occurred: %@", error);
                [[[UIAlertView alloc] initWithTitle:@"Login was canceled" message:@"If you want to save your images, you need to login." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
            }
        }
        else {
            if (user.isNew) {
                NSLog(@"User with facebook signed up and logged in!");
                
                //
            }
            else {
                NSLog(@"User with facebook logged in!");
            }
            
            // Load facebook user name
            FBRequest *request = [FBRequest requestForGraphPath:@"me"];
            [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {

                if (!error) {
                    NSString *name = result[@"name"];
                    NSString *email = result[@"email"];
                    NSString *username = result[@"username"];
                    
                    if(user.isNew){
                        [PFCloud callFunctionInBackground:@"newUserRegistered"
                                           withParameters:@{@"userID":[PFUser currentUser].objectId,@"username":username}
                                                    block:^(NSString *result, NSError *error) {
                                                        if (!error) {
                                                            NSLog(@"newUserRegistered: %@", result);
                                                        }
                                                    }];
                        
                    }

                    
                    NSLog(@"email %@", email);
                    [PFUser currentUser][@"facebookId"] = result[@"id"];
                    [PFUser currentUser].email = email;
                    [PFUser currentUser].username = username;
                    [PFUser currentUser][@"fullName"] = name;
                    [[PFUser currentUser] saveInBackground];
                    
                    NSDictionary *dimensions = @{
                                                 @"username": username,
                                                 @"fullName": name,
                                                 @"facebookId": result[@"id"]
                                                 };
                    
                    [PFAnalytics trackEvent:@"new_user" dimensions:dimensions];
                    
                    
                    [[AppDelegate delegate] showMainViewController];
                    
                }
                else {
                    NSLog(@"Something went wrong: %@", error);
                    [[[UIAlertView alloc] initWithTitle:@"Something went wrong" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
                }
            }];
        }
    }];
}

@end
