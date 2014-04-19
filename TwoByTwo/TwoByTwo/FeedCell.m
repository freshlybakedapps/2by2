//
//  FeedCell.m
//  TwoByTwo
//
//  Created by Joseph Lin on 11/2/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import "FeedCell.h"
#import "UserAnnotation.h"
#import "MKMapView+Utilities.h"
#import "UIImageView+AFNetworking.h"
#import "BlocksKit+UIKit.h"
#import "PDPViewController.h"
#import "NSURL+Facebook.h"


@interface FeedCell ()
@property (nonatomic, weak) IBOutlet UIView *headerView;
@property (nonatomic, weak) IBOutlet UIImageView *firstUserImageView;
@property (nonatomic, weak) IBOutlet UIImageView *secondUserImageView;
@property (nonatomic, weak) IBOutlet UIButton *firstUserButton;
@property (nonatomic, weak) IBOutlet UIButton *secondUserButton;

@property (nonatomic, weak) IBOutlet UIView *containerView;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UIButton *mapCloseButton;
@property (nonatomic, weak) IBOutlet UIView *mapInfoView;
@property (nonatomic, weak) IBOutlet UIImageView *mapFirstUserImageView;
@property (nonatomic, weak) IBOutlet UIImageView *mapSecondUserImageView;
@property (nonatomic, weak) IBOutlet UILabel *mapFirstUserLabel;
@property (nonatomic, weak) IBOutlet UILabel *mapSecondUserLabel;

@property (nonatomic, weak) IBOutlet UIView *footerView;
@property (nonatomic, weak) IBOutlet UIButton *likeButton;
@property (nonatomic, weak) IBOutlet UIButton *commentButton;
@property (nonatomic, weak) IBOutlet UIButton *detailsButton;
@property (nonatomic, weak) IBOutlet UIButton *mapButton;
@property (nonatomic, weak) IBOutlet UIButton *toolButton;

@property (nonatomic, weak) IBOutlet UIButton *featuredButton;
@end


@implementation FeedCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.firstUserImageView.layer.cornerRadius = CGRectGetWidth(self.firstUserImageView.frame) * 0.5;
    self.secondUserImageView.layer.cornerRadius = CGRectGetWidth(self.secondUserImageView.frame) * 0.5;
    
    self.firstUserButton.titleLabel.font = [UIFont appMediumFontOfSize:14];
    self.secondUserButton.titleLabel.font = [UIFont appMediumFontOfSize:14];
    self.likeButton.titleLabel.font = [UIFont appMediumFontOfSize:14];
    self.commentButton.titleLabel.font = [UIFont appMediumFontOfSize:14];
    self.detailsButton.titleLabel.font = [UIFont appMediumFontOfSize:14];
    self.mapSecondUserLabel.font = [UIFont appMediumFontOfSize:14];
    self.mapFirstUserLabel.font = [UIFont appMediumFontOfSize:14];
    
    
}


#pragma mark - Content

- (void)setPhoto:(PFObject *)photo
{    
    _photo = photo;
    __weak typeof(self) weakSelf = self;
    
    if([[PFUser currentUser].email isEqualToString:@"jtubert@hotmail.com"]){
        self.featuredButton.hidden = NO;
        
        BOOL b = [self.photo[@"featured"] boolValue];
        
        //NSLog(@"XXXXXXXXXX %ld",(long)[self.photo[@"featured"] integerValue]);
        
        if(b == YES){
            [self.featuredButton setTitle:@"Featured" forState:UIControlStateNormal];
        }else{
            [self.featuredButton setTitle:@"Not Featured" forState:UIControlStateNormal];
        }
        
        
    }else{
        self.featuredButton.hidden = YES;
    }
    
    
    // User Avatars
    NSURL *firstURL = [NSURL URLWithFacebookUserID:self.photo.user.facebookID];
    
    //if user is using twitter, pull the twitter profile image URL
    if(self.photo.user.twitterProfileImageURL && ![self.photo.user.twitterProfileImageURL isEqualToString:@""]){
        firstURL = [NSURL URLWithString:self.photo.user.twitterProfileImageURL];
    }
    
    [self.firstUserImageView setImageWithURL:firstURL placeholderImage:[UIImage imageNamed:@"defaultUserImage"]];
    [self.firstUserButton setTitle:self.photo.user.username forState:UIControlStateNormal];
    
    if (self.photo.userFull) {
        NSURL *secondURL = [NSURL URLWithFacebookUserID:self.photo.userFull.facebookID];
        
        //if user is using twitter, pull the twitter profile image URL
        if(self.photo.userFull.twitterProfileImageURL && ![self.photo.userFull.twitterProfileImageURL isEqualToString:@""]){
            secondURL = [NSURL URLWithString:self.photo.userFull.twitterProfileImageURL];
        }
        
        
        [self.secondUserImageView setImageWithURL:secondURL placeholderImage:[UIImage imageNamed:@"defaultUserImage"]];
        self.secondUserImageView.hidden = NO;
        [self.secondUserButton setTitle:self.photo.userFull.username forState:UIControlStateNormal];
        self.secondUserButton.hidden = NO;
    }
    else {
        self.secondUserImageView.hidden = YES;
        self.secondUserButton.hidden = YES;
    }

    
    // Main
    self.photo.showMap = NO;
    [self showImageOrMapAnimated:NO];

    
    // Likes
    [self updateLikeButton];
    
    
    // Comments
    if (self.photo.commentCount && ![self.photo.commentCount isEqualToString:@"0"]) {
        [self.commentButton setTitle:self.photo.commentCount forState:UIControlStateNormal];
    }
    else {
        PFQuery *query = [PFQuery queryWithClassName:PFCommentClass];
        [query whereKey:PFCommentIDKey equalTo:self.photo.objectId];
        [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
            weakSelf.photo.commentCount = [NSString stringWithFormat:@"%d", number];
            [weakSelf.commentButton setTitle:weakSelf.photo.commentCount forState:UIControlStateNormal];
        }];
    }
    
    
    // Detail
    self.detailsButton.hidden = (self.shouldHaveDetailLink) ? NO : YES;

    
    // Flag or Delte
    if (photo.canDelete) {
        [self.toolButton setImage:[UIImage imageNamed:@"icon-delete-off"] forState:UIControlStateNormal];
        [self.toolButton setImage:[UIImage imageNamed:@"icon-delete-on"] forState:UIControlStateHighlighted];
    }
    else {
        [self.toolButton setImage:[UIImage imageNamed:@"icon-flag-off"] forState:UIControlStateNormal];
        [self.toolButton setImage:[UIImage imageNamed:@"icon-flag-on"] forState:UIControlStateHighlighted];
    }
}

- (void)showPhoto
{
    __weak typeof(self) weakSelf = self;

    self.imageView.image = nil;
    PFFile *file = ([self.photo.state isEqualToString:PFStateValueFull]) ? self.photo.imageFull : self.photo.imageHalf;
    if (file.isDataAvailable) {
        UIImage *image = [UIImage imageWithData:file.getData];
        self.imageView.image = image;
    }
    else {
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                UIImage *image = [UIImage imageWithData:data];
                weakSelf.imageView.image = image;
            }
            else {
                NSLog(@"getDataInBackgroundWithBlock: %@", error);
            }
        }];
    }
}

- (void)showMap
{
    
    int locations = 0;
    
    
    
    NSString *markers;
    if (self.photo.locationHalf && self.photo.locationHalf.longitude != 0) {
        markers = [NSString stringWithFormat:@"&markers=icon:http://www.2by2app.com/images/redMarker@2x.png|color:0x00cc99|%f,%f", self.photo.locationHalf.latitude, self.photo.locationHalf.longitude];
        locations++;
    }
    if ([self.photo.state isEqualToString:PFStateValueFull] && self.photo.locationFull && self.photo.locationFull.longitude != 0) {
        markers = [NSString stringWithFormat:@"%@&markers=icon:http://www.2by2app.com/images/greenMarker@2x.png|color:0xff3366|%f,%f", markers, self.photo.locationFull.latitude, self.photo.locationFull.longitude];
        locations++;
    }
    
    NSString *mapURLString = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/staticmap?key=AIzaSyDG_mNGbYeKU_UHS5n5CbreCkJ-Qo18A_M&style=lightness:-57|saturation:-100&size=640x640&maptype=roadmap%@&sensor=false", markers];
    mapURLString = [mapURLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *URL = [NSURL URLWithString:mapURLString];
    
    
    if(locations == 0){
        if([self.photo.state isEqualToString:@"full"]){
            [self.imageView setImage:[UIImage imageNamed:@"NoLocationSharedBoth"]];
        }else{
            [self.imageView setImage:[UIImage imageNamed:@"NoLocationShared"]];
        }
        
    }else{
        [self.imageView setImageWithURL:URL placeholderImage:[UIImage imageNamed:@"NoLocationShared"]];
    }
    
    
    
    
    if (self.photo.locationHalf && self.photo.locationHalf.latitude != 0) {
        if ([self.photo.user.objectId isEqualToString:[PFUser currentUser].objectId]){
            self.mapFirstUserLabel.text = @"You!";
        }
        else {
            self.mapFirstUserLabel.text = self.photo.user.username;
        }
    }
    else {
        if ([self.photo.user.objectId isEqualToString:[PFUser currentUser].objectId]){
            self.mapFirstUserLabel.text = @"You!(?)";
        }
        else {
            self.mapFirstUserLabel.text = [NSString stringWithFormat:@"%@(?)", self.photo.user.username];
        }
    }
    
    if (self.photo.locationFull) {
        self.mapSecondUserImageView.hidden = NO;
        self.mapSecondUserLabel.hidden = NO;
    }
    else {
        self.mapSecondUserImageView.hidden = YES;
        self.mapSecondUserLabel.hidden = YES;
    }
    
    if (self.photo.locationFull && self.photo.locationFull.latitude != 0) {
        if ([self.photo.userFull.objectId isEqualToString:[PFUser currentUser].objectId]) {
            self.mapSecondUserLabel.text = @"You!";
        }
        else {
            self.mapSecondUserLabel.text = self.photo.userFull.username;
        }
        
    }
    else {
        if ([self.photo.userFull.objectId isEqualToString:[PFUser currentUser].objectId]) {
            self.mapSecondUserLabel.text = @"You!(?)";
        } else {
            self.mapSecondUserLabel.text = [NSString stringWithFormat:@"%@(?)", self.photo.userFull.username];
        }
    }
}

- (void)updateLikeButton
{
    self.likeButton.selected = self.photo.likedByMe;
    [self.likeButton setTitle:[NSString stringWithFormat:@"%lu", (unsigned long)self.photo.likes.count] forState:UIControlStateNormal];
}


#pragma mark - Actions

- (IBAction)detailButtonTapped:(id)sender
{
    [self.delegate cell:self showCommentsForPhoto:self.photo];
}

- (IBAction)featuredButtonTapped:(id)sender
{
    BOOL b = [self.photo[@"featured"] boolValue];
    
    if(b == YES){
        self.photo[@"featured"] = [NSNumber numberWithBool:NO];
        [self.featuredButton setTitle:@"Not Featured" forState:UIControlStateNormal];
    }else{
        self.photo[@"featured"] = [NSNumber numberWithBool:YES];
        [self.featuredButton setTitle:@"Featured" forState:UIControlStateNormal];
    }
    
    
    [self.photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        NSLog(@"featured photo saved");
    }];
}


- (IBAction)userButtonTapped:(id)sender
{
    if (sender == self.firstUserButton) {
        [self.delegate cell:self showProfileForUser:self.photo.user];
    }
    else {
        [self.delegate cell:self showProfileForUser:self.photo.userFull];
    }
}

- (IBAction)commentButtonTapped:(id)sender
{
    [self.delegate cell:self showCommentsForPhoto:self.photo];
}

- (IBAction)likeButtonTapped:(id)sender
{
    NSMutableArray *newLikes = [self.photo.likes mutableCopy];
    if (self.photo.likedByMe) {
        [newLikes removeObject:[PFUser currentUser].objectId];
    }
    else {
        [newLikes addObject:[PFUser currentUser].objectId];
    }
    self.photo.likes = [newLikes copy];
    [self updateLikeButton];
    
    
    PFUser *user = [PFUser currentUser];
    NSDictionary *params = @{@"objectid":self.photo.objectId, PFUserWhoLikedIDKey:user.objectId, PFUserWhoLikedUsernameKey:user.username};
    [PFCloud callFunctionInBackground:@"likePhoto" withParameters:params block:^(NSNumber *result, NSError *error) {
        if (error) {
            NSLog(@"likePhoto error: %@", error);
        }
        else {
            NSLog(@"likePhoto successfull");
        }
    }];
    
    
    NSDictionary *dimensions = @{
                                 PFPhotoIDKey: self.photo.objectId,
                                 @"userWhoLiked": [PFUser currentUser].username,
                                 @"likeCount": [NSString stringWithFormat:@"%lu",(unsigned long)self.photo.likes.count],
                                 };
    [PFAnalytics trackEvent:@"like_or_unlike" dimensions:dimensions];
}

- (IBAction)toolButtonTapped:(id)sender
{
    if (self.photo.canDelete) {
        
        [UIAlertView bk_showAlertViewWithTitle:@"Confirm" message:@"Are you sure you want to delete this photo?" cancelButtonTitle:@"Cancel" otherButtonTitles:@[@"OK"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex != alertView.cancelButtonIndex) {
                [self.photo deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    NSLog(@"DELETE");
                    [[NSNotificationCenter defaultCenter] postNotificationName:NoficationShouldReloadPhotos object:nil];
                }];
            }
        }];
    }
    else {
        UIAlertView *alert = [UIAlertView bk_alertViewWithTitle:@"Flagging this photo" message:@"Choose a reason for flagging:"];
        [alert bk_addButtonWithTitle:@"This photo is inappropriate" handler:^{
            [self flagWithType:@"FlagTypeInnapropiate"];
        }];
        [alert bk_addButtonWithTitle:@"This photo is a spam" handler:^{
            [self flagWithType:@"FlagTypeSpam"];
        }];
        [alert bk_addButtonWithTitle:@"This photo is a scam" handler:^{
            [self flagWithType:@"FlagTypeScam"];
        }];
        [alert bk_addButtonWithTitle:@"This photo displays stolen content" handler:^{
            [self flagWithType:@"FlagTypeStolen"];
        }];
        [alert bk_setCancelButtonWithTitle:@"CANCEL" handler:^{
            
        }];
        [alert show];
    }
    
    
    NSDictionary *dimensions = @{
                                 PFPhotoIDKey: self.photo.objectId,
                                 PFUserKey: [PFUser currentUser].username,
                                 @"flag_or_delete": (self.photo.canDelete) ? @"delete" : @"flag",
                                 };
    [PFAnalytics trackEvent:@"flag_or_delete_photo" dimensions:dimensions];
}

- (void)flagWithType:(NSString *)type
{
    [PFCloud callFunctionInBackground:@"flagPhoto"
                       withParameters:@{@"objectid":self.photo.objectId, @"userWhoFlagged":[PFUser currentUser].username, @"type":type}
                                block:^(NSString *result, NSError *error) {
                                    if (error) {
                                        NSLog(@"flagPhoto error: %@", error);
                                    }
                                }];
}

- (IBAction)mapButtonTapped:(id)sender
{
    self.photo.showMap = !self.photo.showMap;
    [self showImageOrMapAnimated:YES];
}

- (void)showImageOrMapAnimated:(BOOL)animated
{
    void (^action)(void) = ^{
        if (self.photo.showMap) {
            [self.mapButton setImage:[UIImage imageNamed:@"map_Active"] forState:UIControlStateNormal];
            self.mapCloseButton.hidden = NO;
            self.mapInfoView.hidden = NO;
            [self showMap];
        }
        else {
            [self.mapButton setImage:[UIImage imageNamed:@"map"] forState:UIControlStateNormal];
            self.mapCloseButton.hidden = YES;
            self.mapInfoView.hidden = YES;
            [self showPhoto];
        }
    };
    
    if (animated) {
        [UIView transitionWithView:self.containerView
                          duration:0.5
                           options:(self.photo.showMap) ? UIViewAnimationOptionTransitionFlipFromRight : UIViewAnimationOptionTransitionFlipFromLeft
                        animations:action
                        completion:^(BOOL finished) {
                        }];
    }
    else {
        action();
    }
}

@end
