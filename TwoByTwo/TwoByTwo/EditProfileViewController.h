//
//  EditProfileViewController.h
//  TwoByTwo
//
//  Created by John Tubert on 12/8/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditProfileViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate>

@property (nonatomic, weak) IBOutlet UIImageView *photo;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *emailLabel;
@property (nonatomic, weak) IBOutlet UITextField *username;
@property (nonatomic, weak) IBOutlet UITextView *bio;

@property (strong,nonatomic) NSString* previousUsername;

- (IBAction)updateAccount:(id)sender;

+ (instancetype)controller;

@end
