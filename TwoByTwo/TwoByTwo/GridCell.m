//
//  GridCell.m
//  TwoByTwo
//
//  Created by Joseph Lin on 11/2/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import "GridCell.h"
#import <MapKit/MapKit.h>
#import "UserAnnotation.h"
#import "MKMapView+Utilities.h"
#import "UIImageView+Network.h"
#import "NSString+MD5.h"
#import "UIImageView+CircleMask.h"
#import "FriendProfileViewController.h"
#import "CommentsViewController.h"


@interface GridCell () <MKMapViewDelegate>
@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UIView *headerView;
@property (nonatomic, weak) IBOutlet UIView *footerView;
@property (nonatomic, weak) IBOutlet UIButton *likeButton;
@property (nonatomic, weak) IBOutlet UIButton *commentButton;
@property (nonatomic, weak) IBOutlet UILabel *filterLabel;
@property (nonatomic, weak) IBOutlet UIButton *mapButton;
@property (nonatomic, weak) IBOutlet UIButton *toolButton;
@end


@implementation GridCell

#pragma mark - Content

- (void)setPhoto:(PFObject *)photo
{
    _photo = photo;
    
    if(photo[@"filter"]){
        self.filterLabel.text = photo[@"filter"];
    }else{
        self.filterLabel.text = @"";
    }
    
    //TODO: add the actual number of comments from the server
    self.commentButton.titleLabel.text = @"0";
    
    
    [self addPhotographerNames];
    
    // Image
    self.imageView.image = nil;
    PFFile *file = ([self.photo.state isEqualToString:@"full"]) ? self.photo.imageFull : self.photo.imageHalf;
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            UIImage *image = [UIImage imageWithData:data];
            self.imageView.image = image;
        }
        else {
            NSLog(@"getDataInBackgroundWithBlock: %@", error);
        }
    }];
    
    
    // Likes
    [self updateLikeButton];
    

    // Flag or Delte
    if (photo.canDelete) {
        [self.toolButton setImage:[UIImage imageNamed:@"icon-delete"] forState:UIControlStateNormal];
    }
    else {
        [self.toolButton setImage:[UIImage imageNamed:@"icon-flag-on"] forState:UIControlStateNormal];
    }


    // Map
    photo.showMap = NO;
    [self showImageOrMapAnimated:NO];
}



- (void) addPhotographerNames{
    if(self.userButton == nil){
        self.userButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [self.userButton addTarget:self action:@selector(goToUserProfile:) forControlEvents:UIControlEventTouchDown];
        self.userButton.frame = CGRectMake(35.0, 0.0, 150.0, 40.0);
        [self.userButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];        
        [self.headerView addSubview:self.userButton];
        
        self.userPhoto = [UIImageView new];
        [self.headerView addSubview:self.userPhoto];
        
    }
    
    NSString *url = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=normal",_photo.user[@"facebookId"]];
    NSURL *imageURL = [NSURL URLWithString:url];
    //NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
    
    //self.userPhoto.image = [UIImage imageWithData:imageData];
    self.userPhoto.frame = CGRectMake(0, 0, 30, 30);
    [self.userPhoto addMaskToBounds:CGRectMake(0, 0, 25, 25)];
    
    
    [self.userPhoto loadImageFromURL:imageURL placeholderImage:[UIImage imageNamed:@"icon-you"] cachingKey:[imageURL.absoluteString MD5Hash]];
    
    
    NSString* username = [NSString stringWithFormat:@"%@",_photo.user.username];
    [self.userButton setTitle:username forState:UIControlStateNormal];
    [self.userButton sizeToFit];
    
    
    if (_photo.userFull) {
        if(self.userFullButton == nil){
            self.userFullButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [self.userFullButton addTarget:self action:@selector(goToUserProfile:) forControlEvents:UIControlEventTouchDown];
            
            
            [self.userFullButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
            [self.headerView addSubview:self.userFullButton];
            
            self.userFullPhoto = [UIImageView new];
            [self.headerView addSubview:self.userFullPhoto];
        }
        
        self.userFullButton.frame = CGRectMake(self.userButton.frame.size.width+self.userButton.frame.origin.x+40, 0.0, 150.0, 40.0);
        [self.userFullButton setTitle:_photo.userFull.username forState:UIControlStateNormal];
        [self.userFullButton sizeToFit];
        
        NSString *url = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=normal",_photo.userFull[@"facebookId"]];
        NSURL *imageURL = [NSURL URLWithString:url];
        //NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
        
        //self.userFullPhoto.image = [UIImage imageWithData:imageData];
        self.userFullPhoto.frame = CGRectMake(self.userButton.frame.size.width+self.userButton.frame.origin.x+5, 0, 30, 30);
        [self.userFullPhoto addMaskToBounds:CGRectMake(0, 0, 25, 25)];

        [self.userFullPhoto loadImageFromURL:imageURL placeholderImage:[UIImage imageNamed:@"icon-you"] cachingKey:[imageURL.absoluteString MD5Hash]];
        
    }else{
        [self.userFullButton setTitle:@"" forState:UIControlStateNormal];
        self.userFullPhoto.image = nil;
    }

}

- (void) goToUserProfile:(id)sender {
    NSString* userID;
    NSString* friendName;
    
    if(sender == self.userButton){
        userID = _photo.user.objectId;
        friendName = _photo.user.username;
    }else{
        userID = _photo.userFull.objectId;
        friendName = _photo.userFull.username;
    }
    
    UINavigationController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"FriendProfileViewController"];
    
    FriendProfileViewController * fvc = (FriendProfileViewController*)controller.topViewController;
    
    fvc.friend = [PFUser objectWithoutDataWithObjectId:userID];
    fvc.friendName = friendName;
    [self.controller presentViewController:controller animated:YES completion:nil];
}


#pragma mark - Layout

// Without this, contentView's subviews won't be animated properly.
- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes
{
    [self layoutIfNeeded];
    
    if (CGRectGetWidth(layoutAttributes.frame) > 100) {
        self.headerView.alpha = self.footerView.alpha = 1.0;
    }
    else {
        if (self.photo.showMap) {
            self.photo.showMap = NO;
            [self showImageOrMapAnimated:YES];
        }
        self.headerView.alpha = self.footerView.alpha = 0.0;
    }
}


#pragma mark - Actions

- (IBAction)commentButtonTapped:(id)sender
{
    UINavigationController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"CommentsViewController"];
    
    CommentsViewController * cvc = (CommentsViewController*)controller.topViewController;
    cvc.commentID = self.photo.objectId;
    
    
    [self.controller presentViewController:controller animated:YES completion:nil];
}

- (IBAction)likeButtonTapped:(id)sender
{
    NSArray *oldLikes = self.photo.likes;
    if(self.photo.likes){
        self.nLikes = [NSMutableArray arrayWithArray:self.photo.likes];
    }else{
        self.nLikes = [NSMutableArray new];
    }
    
    if (self.photo.likedByMe) {
        [self.nLikes removeObject:[PFUser currentUser].objectId];
    }
    else {
        [self.nLikes addObject:[PFUser currentUser].objectId];
    }
    self.photo.likes = self.nLikes;
    [self updateLikeButton];
    
    
    @try {
        __weak typeof(self) weakSelf = self;
        
        PFUser* user = [PFUser currentUser];
        
        NSDictionary* params = @{@"objectid":self.photo.objectId, @"userWhoLikedID":user.objectId, @"userWhoLikedUsername":user.username};
        
        [PFCloud callFunctionInBackground:@"likePhoto"
                           withParameters:params
                                    block:^(NSNumber *result, NSError *error) {
                                        
                                        if (error) {
                                            NSLog(@"like photo: %@", error);
                                            
                                            
                                            // Revert likes
                                            weakSelf.photo.likes = oldLikes;
                                            [weakSelf updateLikeButton];
                                        }else{
                                            NSLog(@"Like successfull");
                                        }
                                    }];

    }
    @catch (NSException *exception) {
        NSLog(@"error %@", exception.description);
    }
    
    
    @try {
        NSDictionary *dimensions = @{
                                     @"photoID": self.photo.objectId,
                                     @"userWhoLiked": [PFUser currentUser].username,
                                     @"likeCount": [NSString stringWithFormat:@"%lu",(unsigned long)self.photo.likes.count],
                                     };
        
        [PFAnalytics trackEvent:@"like_or_unlike" dimensions:dimensions];
    }
    @catch (NSException *exception) {
        NSLog(@"like_or_unlike error: %@",exception.description);
    }
    
    
    
}

- (void)updateLikeButton
{
    self.likeButton.selected = self.photo.likedByMe;
    [self.likeButton setTitle:[NSString stringWithFormat:@"%d", self.photo.likes.count] forState:UIControlStateNormal];
}

- (IBAction)toolButtonTapped:(id)sender
{
    if (self.photo.canDelete) {
        [UIAlertView showAlertViewWithTitle:@"Confirm" message:@"Are you sure you want to delete this photo?" cancelButtonTitle:@"Cancel" otherButtonTitles:@[@"OK"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex != alertView.cancelButtonIndex) {
                [self.photo deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadImagesTable" object:nil];
                }];
            }
        }];
    }
    else {
        [UIAlertView showAlertViewWithTitle:@"Confirm" message:@"Are you sure you want to flag this photo?" cancelButtonTitle:@"Cancel" otherButtonTitles:@[@"OK"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex != alertView.cancelButtonIndex) {
                [PFCloud callFunctionInBackground:@"flagPhoto"
                                   withParameters:@{@"objectid":self.photo.objectId, @"userWhoFlagged":[PFUser currentUser].username}
                                            block:^(NSString *result, NSError *error) {
                                                if (error) {
                                                    NSLog(@"Failed to flag: %@", error);
                                                }
                                            }];
                
            }
        }];
    }
    
    NSString* flag_or_delete = @"flag";
    
    if (self.photo.canDelete) {
        flag_or_delete = @"delete";
    }
    
    NSDictionary *dimensions = @{
                                 @"photoID": self.photo.objectId,
                                 @"user": [PFUser currentUser].username,
                                 @"flag_or_delete": flag_or_delete,
                                 };
    
    [PFAnalytics trackEvent:@"flag_or_delete_photo" dimensions:dimensions];
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
            [self.imageView addSubview:self.mapView];
        }
        else {
            [self.mapView removeFromSuperview];
            self.mapView = nil;
        }
    };
    
    if (animated) {
        [UIView transitionWithView:self.imageView
                          duration:0.5
                           options:(self.photo.showMap) ? UIViewAnimationOptionTransitionFlipFromRight : UIViewAnimationOptionTransitionFlipFromLeft
                        animations:action
                        completion:nil];
    }
    else {
        action();
    }
}


#pragma mark - Map

- (MKMapView *)mapView
{
    if (!_mapView) {
        _mapView = [[MKMapView alloc] initWithFrame:self.imageView.bounds];
        _mapView.userInteractionEnabled = NO;
        _mapView.delegate = self;
        
        [self addAnnotations];
    }
    return _mapView;
}

- (void)addAnnotations
{
    if (self.photo.locationHalf) {
        UserAnnotation *annotation = [UserAnnotation annotationWithGeoPoint:self.photo.locationHalf user:self.photo.user];
        [self.mapView addAnnotation:annotation];
    }
    
    if (self.photo.locationFull) {
        UserAnnotation *annotation = [UserAnnotation annotationWithGeoPoint:self.photo.locationFull user:self.photo.userFull];
        [self.mapView addAnnotation:annotation];
    }
    
    [self.mapView zoomToFitAnnotationsAnimated:NO minimumSpan:MKCoordinateSpanMake(0.3, 0.3)];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id < MKAnnotation >)annotation
{
    MKPinAnnotationView *pin = (id)[mapView dequeueReusableAnnotationViewWithIdentifier:@"Pin"];
    if (!pin) {
        pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Pin"];
    }
    pin.annotation = annotation;
    return pin;
}

@end
