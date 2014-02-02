//
//  EditProfileViewController.m
//  TwoByTwo
//
//  Created by John Tubert on 12/8/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import "EditProfileViewController.h"
#import "UIImageView+AFNetworking.h"


@interface EditProfileViewController ()
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *emailLabel;
@property (nonatomic, weak) IBOutlet UITextField *usernameTextField;
@property (nonatomic, weak) IBOutlet UITextView *bioTextView;
@end

#define MAX_LENGTH 140

@implementation EditProfileViewController

+ (instancetype)controller
{
    EditProfileViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"EditProfileViewController"];
    return controller;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	self.title = @"Profile";

    self.nameLabel.text = [PFUser currentUser][@"fullName"];
    self.emailLabel.text = [PFUser currentUser][@"email"];
    self.usernameTextField.text = [PFUser currentUser].username;
    self.bioTextView.text = [PFUser currentUser][@"bio"];
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=normal", [PFUser currentUser][@"facebookId"]]];
    [self.imageView setImageWithURL:URL placeholderImage:[UIImage imageNamed:@"icon-you"]];
    self.imageView.layer.cornerRadius = CGRectGetWidth(self.imageView.frame) * 0.5;
}

- (IBAction)updateButtonTapped:(id)sender
{
    [self.usernameTextField resignFirstResponder];
    [self.bioTextView resignFirstResponder];
    
    if (![[PFUser currentUser].username isEqualToString:self.usernameTextField.text]) {

        [PFCloud callFunctionInBackground:@"isUsernameUnique"
                           withParameters:@{@"username":self.usernameTextField.text}
                                    block:^(NSString *result, NSError *error) {
                                        if (!error) {
                                            if ([result isEqualToString:@"true"]) {
                                                [PFUser currentUser].username = self.usernameTextField.text;
                                                [PFUser currentUser][@"bio"] = self.bioTextView.text;
                                                
                                                [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                                    [[[UIAlertView alloc] initWithTitle:@"Success" message:@"Profile saved successfully!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                                                }];
                                            }
                                            else {
                                                NSString *msg = [NSString stringWithFormat:@"%@ is already taken. Please try another username.", self.usernameTextField.text];
                                                [[[UIAlertView alloc] initWithTitle:@"Error" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                                            }
                                            
                                            
                                        }
                                    }];

    }
    else {
        [PFUser currentUser][@"bio"] = self.bioTextView.text;
        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [[[UIAlertView alloc] initWithTitle:@"Success" message:@"Profile saved successfully!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }];
    }
}


#pragma mark -

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
    }
    
    NSUInteger newLength = (textView.text.length - range.length) + text.length;
    if(newLength <= MAX_LENGTH)
    {
        return YES;
    } else {
        NSUInteger emptySpace = MAX_LENGTH - (textView.text.length - range.length);
        textView.text = [[[textView.text substringToIndex:range.location]
                          stringByAppendingString:[text substringToIndex:emptySpace]]
                         stringByAppendingString:[textView.text substringFromIndex:(range.location + range.length)]];
        return NO;
    }
}


@end
