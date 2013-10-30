//
//  LoginViewController.m
//  TwoByTwo
//
//  Created by John Tubert on 10/11/13.
//
//

#import "LoginViewController.h"


@interface LoginViewController ()

@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) viewDidLoad{
    NSLog(@"viewDidLoad %@",[PFUser currentUser]);
}

- (void) viewDidAppear:(BOOL)animated{
    NSLog(@"viewDidAppear %@",[PFUser currentUser]);
    
    
    //[PFUser logOut];
    
    if ([PFUser currentUser]) {
        [self start];
    }else{
        NSLog(@"viewDidAppear %@",[PFUser currentUser]);
    }
}

- (IBAction)loginButtonTouchHandler:(id)sender{
    // Set permissions required from the facebook user account
    //NSArray *permissionsArray = @[ @"photo_upload", @"publish_stream",@"user_about_me", @"user_relationships", @"user_birthday", @"user_location"];
    NSArray *permissionsArray = @[@"user_about_me", @"email"];
    
    // Login PFUser using facebook
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        if (!user) {
            if (!error) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error" message:@"Uh oh. The user cancelled the Facebook login." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
                [alert show];
            } else {
                NSLog(@"Uh oh. An error occurred: %@", error);
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login was canceled" message:@"If you want to save your images, you need to login." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
                [alert show];
            }
        } else if (user.isNew) {
            [Flurry setUserID:[user username]];
            
            NSLog(@"email: %@",[user email]);
            
            NSLog(@"User with facebook signed up and logged in!");
            
            [self onFacebookLogin];
            
            [self start];
        } else {
            [Flurry setUserID:[user username]];
            NSLog(@"User with facebook logged in!");
            
            NSLog(@"username: %@",[user username]);
            
            NSLog(@"email: %@",[user email]);
            
            [self onFacebookLogin];
            
            [self start];
        }
    }];
}

- (void) onFacebookLogin{
    // Create request for user's facebook data
    NSString *requestPath = @"me/?fields=name,location,gender,birthday,relationship_status";
    
    
    
    // Send request to Facebook
    FBRequest *request = [FBRequest requestForGraphPath:requestPath];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        // handle response
        if (!error) {
            // Parse the data received
            NSDictionary *userData = (NSDictionary *)result;
            //NSString *facebookId = userData[@"id"];
            NSString *name = userData[@"name"];
            NSString *location = userData[@"location"][@"name"];
            NSString *gender = userData[@"gender"];
            NSString *birthday = userData[@"birthday"];
            NSString *email = userData[@"email"];
            NSString *relationship = userData[@"relationship_status"];
            
            // Set received values if they are not nil and reload the table
            if (name) {
                NSLog(@"%@",name);
            }
            
            if (location) {
                NSLog(@"%@",location);
            }
            
            if (gender) {
                NSLog(@"%@",gender);
            }
            
            if (birthday) {
                NSLog(@"%@",birthday);
            }
            
            if (relationship) {
                NSLog(@"%@",relationship);
            }
            
            if (email) {
                NSLog(@"%@",email);
            }
            
            [Flurry setUserID:userData[@"id"]];
            
            
            
            
            [PFUser currentUser].username = name;
            [[PFUser currentUser] saveInBackground];
            
            //NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookId]];
            
            //[[NSNotificationCenter defaultCenter] postNotificationName:@"addImage" object:[UIImage imageWithData:[NSData dataWithContentsOfURL:pictureURL]]];
            
            
        } else if ([[[[error userInfo] objectForKey:@"error"] objectForKey:@"type"]
                    isEqualToString: @"OAuthException"]) { // Since the request failed, we can check if it was due to an invalid session
            NSLog(@"The facebook session was invalidated");
            //[self logoutButtonTouchHandler:nil];
        } else {
            NSLog(@"Some other error: %@", error);
        }
    }];
    
}


- (void) start{
    [self performSegueWithIdentifier:@"MainView" sender:self];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
