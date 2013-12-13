//
//  GridHeaderView.m
//  TwoByTwo
//
//  Created by Joseph Lin on 11/17/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import "GridHeaderView.h"
#import "EverythingElseViewController.h"
#import "EditProfileViewController.h"
#import "NSString+MD5.h"
#import "UIImageView+Network.h"
#import "UIImageView+CircleMask.h"



@implementation GridHeaderView

- (void)render{    
    if(self.friend){
        //if friend, need to load all data from the server
        [self.friend fetchInBackgroundWithBlock:^(PFObject *object, NSError *error){
            [self loadForUser:self.friend];
        }];
    }else{
        [self loadForUser:[PFUser currentUser]];       
    }
}

- (void) loadForUser:(PFUser*) user{
    if(user == [PFUser currentUser]){
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button addTarget:self action:@selector(showEverythingElse) forControlEvents:UIControlEventTouchDown];
        [button setImage:[UIImage imageNamed:@"more"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"more_active"] forState:UIControlStateSelected];
        button.frame = CGRectMake(270.0,20.0, 26.0, 26.0);
        [self addSubview:button];
    }else{
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button addTarget:self action:@selector(follow:) forControlEvents:UIControlEventTouchDown];
        [button setTitle:@"Follow" forState:UIControlStateNormal];
        button.frame = CGRectMake(200.0, 20.0, 90.0, 40.0);
        [self addSubview:button];
    }
    
    self.nameLabel.text = user[@"fullName"];
    self.usernameLabel.text = user.username;
    self.emailLabel.text = user[@"email"];
    
    
    self.numPhotosLabel.text = @"Loading..";
    self.followingLabel.text = @"Loading..";
    self.followersLabel.text = @"Loading..";
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user == %@ OR user_full == %@", user, user];
    PFQuery *query = [PFQuery queryWithClassName:@"Photo" predicate:predicate];
    [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        self.numPhotosLabel.text = [NSString stringWithFormat:@"%d Photos",number];
    }];
    
    PFQuery *followingQuery = [PFQuery queryWithClassName:@"Followers"];
    [followingQuery whereKey:@"userID" equalTo:user.objectId];
    [followingQuery selectKeys:@[@"followingUserID"]];
    
    [followingQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        self.followingLabel.text = [NSString stringWithFormat:@"%lu Following",(unsigned long)number];
    }];
    
    PFQuery *followQuery = [PFQuery queryWithClassName:@"Followers"];
    [followQuery whereKey:@"followingUserID" equalTo:user.objectId];
    
    [followQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        self.followersLabel.text = [NSString stringWithFormat:@"%lu Followers",(unsigned long)number];
    }];
    
    
    self.bioTextview.text = user[@"bio"];
    
    
    NSString *url = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=normal",user[@"facebookId"]];
    NSURL *imageURL = [NSURL URLWithString:url];
    self.photo.frame = CGRectMake(20, 0, 100, 100);
    [self.photo loadImageFromURL:imageURL placeholderImage:[UIImage imageNamed:@"icon-you"] cachingKey:[imageURL.absoluteString MD5Hash]];
    [self.photo addMaskToBounds:CGRectMake(0, 0, 75, 75)];
}



//TODO: grab original value
- (void) follow:(UIButton*)b {
    b.enabled = NO;
    [PFCloud callFunctionInBackground:@"follow"
                       withParameters:@{@"userID":[PFUser currentUser].objectId,@"followingUserID":self.friend.objectId}
                                block:^(NSNumber *result, NSError *error) {
                                    
                                    b.enabled = YES;
                                    
                                    if (!error) {
                                        NSLog(@"Follow: %@", result);
                                        if(result == 0){
                                            [b setTitle:@"Follow" forState:UIControlStateNormal];
                                        }else{
                                            [b setTitle:@"Unfollow" forState:UIControlStateNormal];
                                        }
                                        
                                    }
                                }];
    
}




- (void)showEverythingElse{
    EverythingElseViewController *controller = [EverythingElseViewController controller];    
    [self.controller presentViewController:controller animated:YES completion:nil];
}

@end
