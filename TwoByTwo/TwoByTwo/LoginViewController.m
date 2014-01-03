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
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UIButton *facebookButton;
@property (nonatomic, weak) IBOutlet UIButton *termsButton;
@end


@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.titleLabel.font = [UIFont appMediumFontOfSize:16];
    self.facebookButton.titleLabel.font = [UIFont appMediumFontOfSize:14];
    self.termsButton.titleLabel.font = [UIFont appMediumFontOfSize:12];
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
                                           withParameters:@{@"userID":[PFUser currentUser].objectId, @"username":name}
                                                    block:^(NSString *result, NSError *error) {
                                                        if (!error) {
                                                            NSLog(@"newUserRegistered: %@", result);
                                                        }
                                                    }];
                    }

                    
                    @try {
                        [PFUser currentUser][@"facebookId"] = result[@"id"];
                        [PFUser currentUser].email = email;
                        
                        if(username){
                           [PFUser currentUser].username = username;
                        }else{
                           [PFUser currentUser].username = name;
                        }
                        
                        
                        [PFUser currentUser][@"fullName"] = name;
                        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            if(error){
                                NSLog(@"FB login %@",error.description);
                            }
                        }];

                    }
                    @catch (NSException *exception) {
                        NSLog(@"login/exception: %@",exception.description);
                    }
                    
                    @try {
                        NSDictionary *dimensions = @{                                                    
                                                     @"fullName": name,
                                                     @"facebookId": result[@"id"]
                                                     };
                        
                        [PFAnalytics trackEvent:@"new_user" dimensions:dimensions];
                    }
                    @catch (NSException *exception) {
                        NSLog(@"new_user_PFAnalytics/exception: %@",exception.description);
                    }
                    

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
