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
@property (nonatomic, weak) IBOutlet UILabel *textLabel;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@end


@implementation FindFacebookFriendCell
/*
 facebookID = 100006174907836;
 following = 1;
 name = "Gabriela Tubert";
 parseID = zqRi8FTL8j;
 twitterProfileImage = "http://pbs.twimg.com/profile_images/378800000139726237/6e41ef19d7fb264a073b9954fe4aecab_bigger.jpeg";
 */

- (void)setData:(NSDictionary *)data
{
    _data = data;
    
    NSURL *URL;
    
    if([data objectForKey:@"facebookID"]){
        URL = [NSURL URLWithFacebookUserID:data[@"facebookID"]];
    }
    
    
    if(data[@"twitterProfileImage"]){
        URL = [NSURL URLWithString:data[@"twitterProfileImage"]];
    }
    
    [self.imageView setImageWithURL:URL placeholderImage:[UIImage imageNamed:@"defaultUserImage"]];
    self.imageView.layer.cornerRadius = CGRectGetHeight(self.imageView.frame) * 0.5;  
    
    self.textLabel.font = [UIFont appFontOfSize:14];
    self.textLabel.text = data[@"name"];
    
    
    if (!self.followButton) {
        self.followButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 30)];
        self.followButton.titleLabel.font = [UIFont appFontOfSize:14];
        UIImage *btnImage = [UIImage imageNamed:@"button-red"];
        [self.followButton setBackgroundImage:btnImage forState:UIControlStateNormal];
        [self.followButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
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
                       withParameters:@{PFUserIDKey:[PFUser currentUser].objectId, @"username":[PFUser currentUser].username, PFFollowingUserIDKey:self.data[@"parseID"]}
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
