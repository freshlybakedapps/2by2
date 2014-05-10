//
//  LoginViewController.m
//  TwoByTwo
//
//  Created by John Tubert on 10/11/13.
//
//

#import "LoginViewController.h"
#import "AppDelegate.h"

static NSString * const FacebookNameKey = @"name";
static NSString * const FacebookUsernameKey = @"username";
static NSString * const FacebookEmailKey = @"email";
static NSString * const FacebookIDKey = @"id";


@interface LoginViewController ()
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UIButton *facebookButton;
@property (nonatomic, weak) IBOutlet UIButton *twitterButton;
@property (nonatomic, weak) IBOutlet UIButton *termsButton;
@end


@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.titleLabel.font = [UIFont appMediumFontOfSize:16];
    self.facebookButton.titleLabel.font = [UIFont appMediumFontOfSize:14];
    self.twitterButton.titleLabel.font = [UIFont appMediumFontOfSize:14];
    
    self.termsButton.titleLabel.font = [UIFont appMediumFontOfSize:12];
    self.termsButton.titleLabel.numberOfLines = 2;
    self.termsButton.titleLabel.textAlignment = NSTextAlignmentCenter;
}

- (IBAction)twitterLoginButtonTouchHandler:(id)sender
{
    [PFTwitterUtils logInWithBlock:^(PFUser *user, NSError *error) {
        
        NSLog(@"user: %@ %@", [PFTwitterUtils twitter].screenName, [PFTwitterUtils twitter].userId);
        
        if (!user) {
            NSLog(@"Uh oh. The user cancelled the Twitter login.");
            return;
        }
        
        if (user.isNew) {
            NSLog(@"User signed up and logged in with Twitter!");

            NSString * requestString = [NSString stringWithFormat:@"https://api.twitter.com/1.1/users/show.json?screen_name=%@", [PFTwitterUtils twitter].screenName];
            NSURL *verify = [NSURL URLWithString:requestString];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:verify];
            [[PFTwitterUtils twitter] signRequest:request];
            
            [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                
                if (connectionError) {
                    NSLog(@"Twitter request failed: %@", connectionError);
                    return;
                }
                
                NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                
                //[PFUser currentUser].email = email;
                [PFUser currentUser].username = result[@"name"];
                [PFUser currentUser].fullName = result[@"name"];
                [[PFUser currentUser] setObject:result[@"description"] forKey:@"bio"];
                
                NSString *imageURL = [result[@"profile_image_url"] stringByReplacingOccurrencesOfString:@"_normal.jpeg" withString:@"_bigger.jpeg"];
                [[PFUser currentUser] setObject:imageURL forKey:@"TwitterProfileImage"];
                [[PFUser currentUser] setObject:[PFTwitterUtils twitter].userId forKey:@"twitterId"];
                
                
                //SET SOME DEFAULT VALUES FOR FIRST TIME USERS
                [PFUser currentUser].notificationWasAccessed = [NSDate date];
                
                [PFUser currentUser].likesEmailAlert = NO;
                [PFUser currentUser].followsEmailAlert = NO;
                [PFUser currentUser].commentsEmailAlert = NO;
                [PFUser currentUser].overexposeEmailAlert = NO;
                [PFUser currentUser].friendTookPhotoEmailAlert = NO;
                [PFUser currentUser].digestEmailAlert = NO;
                
                [PFUser currentUser].overexposePushAlert = YES;
                [PFUser currentUser].likesPushAlert = YES;
                [PFUser currentUser].followsPushAlert = YES;
                [PFUser currentUser].commentsPushAlert = YES;
                [PFUser currentUser].friendTookPhotoPushAlert = YES;
                
                [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if(error){
                        NSLog(@"Twitter login %@",error.description);
                    }
                }];
            }];
        }
        else {
            NSLog(@"User logged in with Twitter!");
        }

        [[AppDelegate delegate] showMainViewController];
    }];
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
                    NSString *name = result[FacebookNameKey];
                    NSString *username = result[FacebookUsernameKey];
                    NSString *email = result[FacebookEmailKey];
                    NSString *facebookId = result[FacebookIDKey];
                    
                    if(user.isNew){
                        [PFCloud callFunctionInBackground:@"newUserRegistered"
                                           withParameters:@{PFUserIDKey:[PFUser currentUser].objectId, @"username":name}
                                                    block:^(NSString *result, NSError *error) {
                                                        if (!error) {
                                                            NSLog(@"newUserRegistered: %@", result);
                                                        }
                                                    }];
                    }

                    
                    @try {
                        [PFUser currentUser].email = email;
                        [PFUser currentUser].username = (username) ? : name;
                        [PFUser currentUser].fullName = name;
                        [PFUser currentUser].facebookID = facebookId;

                        //SET SOME DEFAULT VALUES FOR FIRST TIME USERS
                        [PFUser currentUser].notificationWasAccessed = [NSDate date];
                        
                        [PFUser currentUser].likesEmailAlert = NO;
                        [PFUser currentUser].followsEmailAlert = NO;
                        [PFUser currentUser].commentsEmailAlert = NO;
                        [PFUser currentUser].overexposeEmailAlert = NO;
                        [PFUser currentUser].friendTookPhotoEmailAlert = NO;
                        [PFUser currentUser].digestEmailAlert = NO;

                        [PFUser currentUser].overexposePushAlert = YES;
                        [PFUser currentUser].likesPushAlert = YES;
                        [PFUser currentUser].followsPushAlert = YES;
                        [PFUser currentUser].commentsPushAlert = YES;
                        [PFUser currentUser].friendTookPhotoPushAlert = YES;
                        
                        
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
                                                     PFFullNameKey: name,
                                                     PFFacebookIDKey: facebookId
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
