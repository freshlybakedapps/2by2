//
//  GridHeaderView.m
//  TwoByTwo
//
//  Created by Joseph Lin on 11/17/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import "GridHeaderView.h"
#import "EverythingElseViewController.h"
#import "UIImageView+AFNetworking.h"


@interface GridHeaderView ()
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UIButton *actionButton;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *usernameLabel;
@property (nonatomic, weak) IBOutlet UILabel *numPhotosLabel;
@property (nonatomic, weak) IBOutlet UILabel *followingLabel;
@property (nonatomic, weak) IBOutlet UILabel *followersLabel;
@property (nonatomic, weak) IBOutlet UILabel *bioLabel;
@end


@implementation GridHeaderView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.imageView.layer.cornerRadius = 40.0;
    self.nameLabel.text = @"Loading..";
    self.usernameLabel.text = @"Loading..";
    self.numPhotosLabel.text = @"Loading..";
    self.followingLabel.text = @"Loading..";
    self.followersLabel.text = @"Loading..";
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
        [self.actionButton setImage:nil forState:UIControlStateNormal];
        [self.actionButton setImage:nil forState:UIControlStateHighlighted];
        [self.actionButton setTitle:@"Follow" forState:UIControlStateNormal];
        //TODO: load follow state
    }
    else {
        user = [PFUser currentUser];
        [self.actionButton setImage:[UIImage imageNamed:@"more"] forState:UIControlStateNormal];
        [self.actionButton setImage:[UIImage imageNamed:@"more_active"] forState:UIControlStateHighlighted];
        [self.actionButton setTitle:nil forState:UIControlStateNormal];
    }
    
    __weak typeof(self) weakSelf = self;
    
    self.nameLabel.text = user[@"fullName"];
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

- (IBAction)actionButtonTapped:(UIButton *)sender
{
    if (self.user) {
        self.actionButton.enabled = NO;
        [PFCloud callFunctionInBackground:@"follow"
                           withParameters:@{@"userID":[PFUser currentUser].objectId,@"followingUserID":self.user.objectId}
                                    block:^(NSNumber *result, NSError *error) {
                                        self.actionButton.enabled = YES;
                                        if (!error) {
                                            if ([result isEqual:@0]){
                                                [self.actionButton setTitle:@"Follow" forState:UIControlStateNormal];
                                            }
                                            else {
                                                // In this case, result == @"Notifications sent"
                                                [self.actionButton setTitle:@"Unfollow" forState:UIControlStateNormal];
                                            }
                                        }
                                    }];
    }
    else {
        EverythingElseViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"EverythingElseViewController"];

        UINavigationController *navController = (id)[AppDelegate delegate].window.rootViewController;
        NSAssert([navController isKindOfClass:[UINavigationController class]], @"rootViewController should be an UINavigationController!");
        [navController pushViewController:controller animated:YES];
        
    }
}

@end
