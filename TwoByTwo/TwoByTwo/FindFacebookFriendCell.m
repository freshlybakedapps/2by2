//
//  FindFacebookFriendCell.m
//  TwoByTwo
//
//  Created by John Tubert on 11/30/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import "FindFacebookFriendCell.h"
#import "UIImageView+AFNetworking.h"


@interface FindFacebookFriendCell ()
@property (nonatomic, strong) UIButton *followButton;
@end


@implementation FindFacebookFriendCell
/*
 facebookID = 100006174907836;
 following = 1;
 name = "Gabriela Tubert";
 parseID = zqRi8FTL8j;
 */

- (void)setData:(NSDictionary *)data
{
    _data = data;
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=square", data[@"facebookID"]]];
    [self.imageView setImageWithURL:URL placeholderImage:[UIImage imageNamed:@"icon-you"]];
    self.imageView.layer.cornerRadius = 15;
    
    self.textLabel.text = data[@"name"];
    
    
    if (!self.followButton) {
        self.followButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 90, 40)];
        self.followButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [self.followButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self.followButton addTarget:self action:@selector(followButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        self.accessoryView = self.followButton;
    }
    
    NSString *buttonTitle = ([data[@"following"] boolValue]) ? @"Unfollow" : @"Follow";
    [self.followButton setTitle:buttonTitle forState:UIControlStateNormal];
}

- (IBAction)followButtonTapped:(UIButton *)sender
{
    sender.enabled = NO;
    [PFCloud callFunctionInBackground:@"follow"
                       withParameters:@{@"userID":[PFUser currentUser].objectId, @"username":[PFUser currentUser].username, @"followingUserID":self.data[@"parseID"]}
                                block:^(NSNumber *result, NSError *error) {
                                    sender.enabled = YES;
                                    if (!error) {
                                        if ([result isEqual:@0]){
                                            [sender setTitle:@"Follow" forState:UIControlStateNormal];
                                        }
                                        else {
                                            // In this case, result == @"Notifications sent"
                                            [sender setTitle:@"Unfollow" forState:UIControlStateNormal];
                                        }
                                    }
                                }];
}

@end
