//
//  FeedHeaderView.m
//  TwoByTwo
//
//  Created by Joseph Lin on 11/17/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import "ProfileFeedHeaderView.h"
#import "EditProfileViewController.h"
#import "EverythingElseViewController.h"
#import "UIImageView+AFNetworking.h"
#import "AppDelegate.h"


@interface ProfileFeedHeaderView ()
@property (nonatomic, weak) IBOutlet UIButton *followButton;
@property (nonatomic, weak) IBOutlet UIButton *editButton;
@property (nonatomic, weak) IBOutlet UIButton *moreButton;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UILabel *usernameLabel;
@property (nonatomic, weak) IBOutlet UILabel *followersLabel;
@property (nonatomic, weak) IBOutlet UILabel *bioLabel;
@end


@implementation ProfileFeedHeaderView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.imageView.layer.cornerRadius = 40.0;
    self.title = @"Loading..";
    self.usernameLabel.text = @"Loading..";
    self.followersLabel.text = @"Loading..";
    self.bioLabel.text = @"Loading..";
    
    self.followButton.titleLabel.font = [UIFont appMediumFontOfSize:12];
    self.editButton.titleLabel.font = [UIFont appMediumFontOfSize:14];
    self.usernameLabel.font = [UIFont appFontOfSize:14];
    self.followersLabel.font = [UIFont appFontOfSize:14];
    self.bioLabel.font = [UIFont appFontOfSize:14];
}


#pragma mark - Content

- (void)setUser:(PFUser *)user
{
    _user = user;

    if (user) {
        [user fetchInBackgroundWithBlock:^(PFObject *object, NSError *error){
            [self updateContent];
        }];
    }
    else {
        [self updateContent];
    }
}

- (void)updateContent
{
    PFUser *user = self.user;
    
    if ([user.objectId isEqualToString:[PFUser currentUser].objectId]){
        user = nil;
    }
    
    if (user) {
//        self.followButton.hidden = NO; // Keep followButton hidden until the state is loaded.
        self.editButton.hidden = YES;
        self.moreButton.hidden = YES;
    }
    else {
        user = [PFUser currentUser];
        self.followButton.hidden = YES;
        self.editButton.hidden = NO;
        self.moreButton.hidden = NO;
    }
    
    self.title = [user[@"fullName"] uppercaseString];

    @weakify(self);
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user == %@ OR user_full == %@", user, user];
    PFQuery *query = [PFQuery queryWithClassName:PFPhotoClass predicate:predicate];
    [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        @strongify(self);
        self.usernameLabel.text = [NSString stringWithFormat:@"%@ / %d Photos", user.username, number];
    }];
    
    PFQuery *followingQuery = [PFQuery queryWithClassName:PFFollowersClass];
    [followingQuery whereKey:PFUserIDKey equalTo:user.objectId];
    [followingQuery selectKeys:@[PFFollowingUserIDKey]];
    [followingQuery countObjectsInBackgroundWithBlock:^(int following, NSError *error) {

        PFQuery *followerQuery = [PFQuery queryWithClassName:PFFollowersClass];
        [followerQuery whereKey:PFFollowingUserIDKey equalTo:user.objectId];
        [followerQuery countObjectsInBackgroundWithBlock:^(int followers, NSError *error) {

            @strongify(self);
            self.followersLabel.text = [NSString stringWithFormat:@"%d Following / %d Followers", following, followers];
        }];
    }];
    
    
    self.bioLabel.text = user[@"bio"];
    
    
    PFQuery *followedByMeQuery = [PFQuery queryWithClassName:PFFollowersClass];
    [followedByMeQuery whereKey:PFUserIDKey equalTo:[PFUser currentUser].objectId];
    [followedByMeQuery whereKey:PFFollowingUserIDKey equalTo:user.objectId];
    [followedByMeQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        
        @strongify(self);
        if (![user.objectId isEqualToString:[PFUser currentUser].objectId]){
            self.followButton.hidden = NO;
            
            if (number > 0){
                [self.followButton setTitle:@"Following" forState:UIControlStateNormal];
            }
            else {
                [self.followButton setTitle:@"Follow" forState:UIControlStateNormal];
            }
        }
    }];

    NSURL *URL = [NSURL URLWithFacebookUserID:user.facebookID size:160];
    
    //if user is using twitter, pull the twitter profile image URL
    if (user.twitterProfileImageURL.length){
        URL = [NSURL URLWithString:user.twitterProfileImageURL];
    }
    
    [self.imageView setImageWithURL:URL placeholderImage:[UIImage imageNamed:@"defaultUserImage"]];
}


#pragma mark - IBActions

- (IBAction)followButtonTapped:(UIButton *)sender
{
    __weak typeof(self) weakSelf = self;
    self.followButton.enabled = NO;
    [PFCloud callFunctionInBackground:@"follow"
                       withParameters:@{PFUserIDKey:[PFUser currentUser].objectId, @"username":[PFUser currentUser].username, PFFollowingUserIDKey:self.user.objectId}
                                block:^(NSNumber *result, NSError *error) {
                                    weakSelf.followButton.enabled = YES;
                                    if (!error) {
                                        weakSelf.followButton.hidden = NO;
                                        if ([result isEqual:@0]){
                                            [weakSelf.followButton setTitle:@"Follow" forState:UIControlStateNormal];
                                        }
                                        else {
                                            // In this case, result == @"Notifications sent"
                                            [weakSelf.followButton setTitle:@"Unfollow" forState:UIControlStateNormal];
                                        }
                                    }
                                }];
}

- (IBAction)editButtonTapped:(UIButton *)sender
{
    EditProfileViewController *controller = [EditProfileViewController controller];
    UINavigationController *navController = (id)[AppDelegate delegate].window.rootViewController;
    NSAssert([navController isKindOfClass:[UINavigationController class]], @"rootViewController should be an UINavigationController!");
    [navController pushViewController:controller animated:YES];
}

- (IBAction)moreButtonTapped:(UIButton *)sender
{
    EverythingElseViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"EverythingElseViewController"];
    UINavigationController *navController = (id)[AppDelegate delegate].window.rootViewController;
    NSAssert([navController isKindOfClass:[UINavigationController class]], @"rootViewController should be an UINavigationController!");
    [navController pushViewController:controller animated:YES];
}

@end
