//
//  GridHeaderView.m
//  TwoByTwo
//
//  Created by Joseph Lin on 11/17/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import "GridProfileHeaderView.h"
#import "EditProfileViewController.h"
#import "EverythingElseViewController.h"
#import "UIImageView+AFNetworking.h"


@interface GridProfileHeaderView ()
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UIButton *followButton;
@property (nonatomic, weak) IBOutlet UIButton *editButton;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UIButton *moreButton;
@property (nonatomic, weak) IBOutlet UILabel *usernameLabel;
@property (nonatomic, weak) IBOutlet UILabel *numPhotosLabel;
@property (nonatomic, weak) IBOutlet UILabel *followingLabel;
@property (nonatomic, weak) IBOutlet UILabel *followersLabel;
@property (nonatomic, weak) IBOutlet UILabel *bioLabel;
@end


@implementation GridProfileHeaderView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.imageView.layer.cornerRadius = 40.0;
    self.usernameLabel.text = @"Loading..";
    self.numPhotosLabel.text = @"Loading..";
    self.followingLabel.text = @"Loading..";
    self.followersLabel.text = @"Loading..";
    self.bioLabel.text = @"Loading..";
    
    self.titleLabel.font = [UIFont appMediumFontOfSize:14];
    self.followButton.titleLabel.font = [UIFont appMediumFontOfSize:12];
    self.editButton.titleLabel.font = [UIFont appMediumFontOfSize:14];
    self.usernameLabel.font = [UIFont appFontOfSize:14];
    self.numPhotosLabel.font = [UIFont appFontOfSize:14];
    self.followingLabel.font = [UIFont appFontOfSize:14];
    self.followersLabel.font = [UIFont appFontOfSize:14];
    self.bioLabel.font = [UIFont appFontOfSize:14];
}

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
    
    if (user) {
        self.followButton.hidden = NO;
        self.editButton.hidden = YES;
        self.moreButton.hidden = YES;
        //TODO: load follow state
    }
    else {
        user = [PFUser currentUser];
        self.followButton.hidden = YES;
        self.editButton.hidden = NO;
        self.moreButton.hidden = NO;
    }
    
    __weak typeof(self) weakSelf = self;
    
    self.titleLabel.text = [user[@"fullName"] uppercaseString];
    self.usernameLabel.text = user.username;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user == %@ OR user_full == %@", user, user];
    PFQuery *query = [PFQuery queryWithClassName:@"Photo" predicate:predicate];
    [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        weakSelf.numPhotosLabel.text = [NSString stringWithFormat:@"%d Photos", number];
    }];
    
    PFQuery *followingQuery = [PFQuery queryWithClassName:@"Followers"];
    [followingQuery whereKey:@"userID" equalTo:user.objectId];
    [followingQuery selectKeys:@[@"followingUserID"]];
    [followingQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        weakSelf.followingLabel.text = [NSString stringWithFormat:@"%d Following", number];
    }];
    
    PFQuery *followQuery = [PFQuery queryWithClassName:@"Followers"];
    [followQuery whereKey:@"followingUserID" equalTo:user.objectId];
    [followQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        weakSelf.followersLabel.text = [NSString stringWithFormat:@"%d Followers", number];
    }];
    

    self.bioLabel.text = user[@"bio"];
    
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=normal", user[@"facebookId"]]];
    [self.imageView setImageWithURL:URL placeholderImage:[UIImage imageNamed:@"icon-you"]];
}

- (IBAction)followButtonTapped:(UIButton *)sender
{
    __weak typeof(self) weakSelf = self;
    self.followButton.enabled = NO;
    [PFCloud callFunctionInBackground:@"follow"
                       withParameters:@{@"userID":[PFUser currentUser].objectId,@"username":[PFUser currentUser].username,@"followingUserID":self.user.objectId}
                                block:^(NSNumber *result, NSError *error) {
                                    weakSelf.followButton.enabled = YES;
                                    if (!error) {
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
