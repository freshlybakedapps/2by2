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
            
            [self start];
        } else {
            [Flurry setUserID:[user username]];
            NSLog(@"User with facebook logged in!");
            
            NSLog(@"email: %@",[user email]);
            
            [self start];
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
