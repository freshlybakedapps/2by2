//
//  EditProfileViewController.m
//  TwoByTwo
//
//  Created by John Tubert on 12/8/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import "EditProfileViewController.h"
#import "NSString+MD5.h"
#import "UIImageView+Network.h"
#import "UIImageView+CircleMask.h"

@interface EditProfileViewController ()

@end

@implementation EditProfileViewController

+ (instancetype)controller
{
    EditProfileViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"EditProfileViewController"];
    return controller;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
    }
    return YES;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
	self.navigationItem.title = @"Profile";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close"
                                                                             style:UIBarButtonItemStyleBordered
                                                                            target:self
                                                                            action:@selector(close:)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save"
                                                                             style:UIBarButtonItemStyleBordered
                                                                            target:self
                                                                             action:@selector(save:)];
    
    
    
    self.nameLabel.text = [PFUser currentUser][@"fullName"];
    self.emailLabel.text = [PFUser currentUser][@"email"];
    self.username.text = [PFUser currentUser].username;
    
    self.username.delegate = self;
    [self.username setReturnKeyType:UIReturnKeyDone];
    
    if([PFUser currentUser][@"bio"]){
       self.bio.text = [PFUser currentUser][@"bio"];
    }
    [self.bio setReturnKeyType:UIReturnKeyDone];
    self.bio.delegate = self;
    
    
    NSString *url = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=square",[PFUser currentUser][@"facebookId"]];
    NSURL *imageURL = [NSURL URLWithString:url];
    //NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
    //self.photo.image = [UIImage imageWithData:imageData];
    self.photo.frame = CGRectMake(20, 88, 100, 100);
    [self.photo loadImageFromURL:imageURL placeholderImage:[UIImage imageNamed:@"icon-you"] cachingKey:[imageURL.absoluteString MD5Hash]];
    [self.photo addMaskToBounds:CGRectMake(0, 0, 72, 72)];
}


-(void)close:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{ NSLog(@"controller dismissed"); }];
}

- (void) save:(id)sender
{
    [self.username resignFirstResponder];
    [self.bio resignFirstResponder];
    
    if(![[PFUser currentUser].username isEqualToString:self.username.text]){
        NSLog(@"ccc");
        [PFCloud callFunctionInBackground:@"isUsernameUnique"
                           withParameters:@{@"username":self.username.text}
                                    block:^(NSString *result, NSError *error) {
                                        if (!error) {
                                            if([result isEqualToString:@"true"]){
                                                [PFUser currentUser].username = self.username.text;
                                                [PFUser currentUser][@"bio"] = self.bio.text;
                                                
                                                [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                                    [[[UIAlertView alloc] initWithTitle:@"Success" message:@"Profile saved successfully!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                                                }];
                                            }else{
                                                NSString* msg = [NSString stringWithFormat:@"%@ is already taken. Please try another username.",self.username.text];
                                                [[[UIAlertView alloc] initWithTitle:@"Error" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                                            }
                                            
                                            
                                        }
                                    }];

    }else{
        [PFUser currentUser][@"bio"] = self.bio.text;
        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [[[UIAlertView alloc] initWithTitle:@"Success" message:@"Profile saved successfully!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }];

    }
    
    
    
    
    

}

- (IBAction)updateAccount:(id)sender
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
