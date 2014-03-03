//
//  AddCommentCell.m
//  TwoByTwo
//
//  Created by Joseph Lin on 3/2/14.
//  Copyright (c) 2014 Joseph Lin. All rights reserved.
//

#import "AddCommentCell.h"


@interface AddCommentCell ()
@property (nonatomic, weak) IBOutlet UITextField *textField;
@end


@implementation AddCommentCell

- (IBAction)sendButtonTapped:(UIButton *)sender
{
    [self.textField resignFirstResponder];
    
    if (self.textField.text.length == 0) {
        return;
    }
    
    sender.enabled = NO;
    __weak typeof(self) weakSelf = self;
    
    PFObject *comment = [PFObject objectWithClassName:@"Comment"];
    comment[@"text"] = self.textField.text;
    comment[@"username"] = [PFUser currentUser].username;
    comment[@"commentID"] = self.photo.objectId;
    comment[@"facebookId"] = [PFUser currentUser][@"facebookId"];
    comment[@"userID"] = [PFUser currentUser].objectId;
    
    [comment saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            if (weakSelf.didSendComment) {
                weakSelf.didSendComment(comment);
            }
        }
        sender.enabled = YES;
        weakSelf.textField.text = nil;
    }];
}

@end
