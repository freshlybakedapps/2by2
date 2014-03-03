//
//  GridCell.m
//  TwoByTwo
//
//  Created by Joseph Lin on 11/2/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import "GridCell.h"
#import "UserAnnotation.h"
#import "MKMapView+Utilities.h"
#import "UIImageView+AFNetworking.h"

#import "BlocksKit+UIKit.h"

typedef NS_ENUM(NSUInteger, FlagType) {
    FlagTypeInnapropiate = 0,
    FlagTypeSpam,
    FlagTypeScam,
    FlagTypeStolen,
};


@interface GridCell () <MKMapViewDelegate>
//@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) UIImageView *mapView;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UIView *headerView;
@property (nonatomic, weak) IBOutlet UIImageView *firstUserImageView;
@property (nonatomic, weak) IBOutlet UIImageView *secondUserImageView;
@property (nonatomic, weak) IBOutlet UIButton *firstUserButton;
@property (nonatomic, weak) IBOutlet UIButton *secondUserButton;
@property (nonatomic, weak) IBOutlet UIView *footerView;
@property (nonatomic, weak) IBOutlet UIButton *likeButton;
@property (nonatomic, weak) IBOutlet UIButton *commentButton;
//@property (nonatomic, weak) IBOutlet UILabel *filterLabel;
@property (nonatomic, weak) IBOutlet UIButton *mapButton;
@property (nonatomic, weak) IBOutlet UIButton *mapCloseButton;
@property (nonatomic, weak) IBOutlet UIButton *toolButton;

@property (nonatomic, weak) IBOutlet UIView *mapOverlay;
@property (nonatomic, weak) IBOutlet UILabel *mapOverlayYou;
@property (nonatomic, weak) IBOutlet UILabel *mapOverlayUsername;
@property (nonatomic, strong) IBOutlet UIImageView *mapOverlayPinGreen;
@property (nonatomic, strong) IBOutlet UIImageView *mapOverlayPinRed;

@property (nonatomic, strong) NSMutableArray* nLikes;
@end


@implementation GridCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.mapOverlay.hidden = YES;
    self.mapCloseButton.hidden = YES;
    self.mapOverlayPinRed.hidden = YES;
    self.mapOverlayUsername.hidden = YES;
    self.mapOverlayUsername.font = [UIFont appMediumFontOfSize:14];
    self.mapOverlayYou.font = [UIFont appMediumFontOfSize:14];
    
    self.firstUserImageView.layer.cornerRadius = CGRectGetWidth(self.firstUserImageView.frame) * 0.5;
    self.secondUserImageView.layer.cornerRadius = CGRectGetWidth(self.secondUserImageView.frame) * 0.5;
    
    self.firstUserButton.titleLabel.font = [UIFont appMediumFontOfSize:14];
    self.secondUserButton.titleLabel.font = [UIFont appMediumFontOfSize:14];
    self.likeButton.titleLabel.font = [UIFont appMediumFontOfSize:14];
    self.commentButton.titleLabel.font = [UIFont appMediumFontOfSize:14];
}

// Without this, contentView's subviews won't be animated properly.
- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes
{
    [self layoutIfNeeded];
    
    if (CGRectGetWidth(layoutAttributes.frame) > 100) {
        self.headerView.alpha = self.footerView.alpha = 1.0;
        //self.imageView.frame = CGRectMake(self.imageView.frame.origin.x, 50.0, self.imageView.frame.size.width, self.imageView.frame.size.height);
    }
    else {
        if (self.photo.showMap) {
            self.photo.showMap = NO;
            [self showImageOrMapAnimated:YES];
        }
        self.headerView.alpha = self.footerView.alpha = 0.0;
        
    }
}


#pragma mark - Content

- (void)setPhoto:(PFObject *)photo
{
    _photo = photo;
    __weak typeof(self) weakSelf = self;
    
    
    // User Avatars
    NSURL *firstURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=square", self.photo.user[@"facebookId"]]];
    [self.firstUserImageView setImageWithURL:firstURL placeholderImage:[UIImage imageNamed:@"defaultUserImage"]];
    [self.firstUserButton setTitle:self.photo.user.username forState:UIControlStateNormal];
    
    if (self.photo.userFull) {
        NSURL *secondURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=square", self.photo.userFull[@"facebookId"]]];
        [self.secondUserImageView setImageWithURL:secondURL placeholderImage:[UIImage imageNamed:@"defaultUserImage"]];
        self.secondUserImageView.hidden = NO;
        [self.secondUserButton setTitle:self.photo.userFull.username forState:UIControlStateNormal];
        self.secondUserButton.hidden = NO;
    }
    else {
        self.secondUserImageView.hidden = YES;
        self.secondUserButton.hidden = YES;
    }

    
    // Photo
    self.imageView.image = nil;
    PFFile *file = ([self.photo.state isEqualToString:@"full"]) ? self.photo.imageFull : self.photo.imageHalf;
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            UIImage *image = [UIImage imageWithData:data];
            weakSelf.imageView.image = image;
        }
        else {
            NSLog(@"getDataInBackgroundWithBlock: %@", error);
        }
    }];
    
    
    // Likes
    [self updateLikeButton];
    
    
    
    // Comments
    if (self.photo.commentCount && ![self.photo.commentCount isEqualToString:@"0"]) {
        [self.commentButton setTitle:self.photo.commentCount forState:UIControlStateNormal];
    }
    else {
        PFQuery *query = [PFQuery queryWithClassName:@"Comment"];
        [query whereKey:@"commentID" equalTo:self.photo.objectId];
        [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
            weakSelf.photo.commentCount = [NSString stringWithFormat:@"%d", number];
            [weakSelf.commentButton setTitle:weakSelf.photo.commentCount forState:UIControlStateNormal];
        }];
    }
    

    // Filter
    //self.filterLabel.text = photo[@"filter"];


    // Map
    self.photo.showMap = NO;
    [self showImageOrMapAnimated:NO];

    
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


#pragma mark - Actions

- (IBAction)closeMap:(id)sender
{
    
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
//    NSArray *oldLikes = self.photo.likes;

    NSMutableArray *newLikes = [self.photo.likes mutableCopy];
    if (self.photo.likedByMe) {
        [newLikes removeObject:[PFUser currentUser].objectId];
    }
    else {
        [newLikes addObject:[PFUser currentUser].objectId];
    }
    self.photo.likes = [newLikes copy];
    [self updateLikeButton];
    
    
//    __weak typeof(self) weakSelf = self;
    PFUser *user = [PFUser currentUser];
    NSDictionary *params = @{@"objectid":self.photo.objectId, @"userWhoLikedID":user.objectId, @"userWhoLikedUsername":user.username};
    [PFCloud callFunctionInBackground:@"likePhoto" withParameters:params block:^(NSNumber *result, NSError *error) {
        if (error) {
            NSLog(@"likePhoto error: %@", error);
            //weakSelf.photo.likes = oldLikes;
            //[weakSelf updateLikeButton];
        }
        else {
            NSLog(@"likePhoto successfull");
        }
    }];
    
    
    NSDictionary *dimensions = @{
                                 @"photoID": self.photo.objectId,
                                 @"userWhoLiked": [PFUser currentUser].username,
                                 @"likeCount": [NSString stringWithFormat:@"%lu",(unsigned long)self.photo.likes.count],
                                 };
    [PFAnalytics trackEvent:@"like_or_unlike" dimensions:dimensions];
}

- (void)updateLikeButton
{
    self.likeButton.selected = self.photo.likedByMe;
    [self.likeButton setTitle:[NSString stringWithFormat:@"%d", self.photo.likes.count] forState:UIControlStateNormal];
}

- (IBAction)toolButtonTapped:(id)sender
{
    if (self.photo.canDelete) {
        
        [UIAlertView bk_showAlertViewWithTitle:@"Confirm" message:@"Are you sure you want to delete this photo?" cancelButtonTitle:@"Cancel" otherButtonTitles:@[@"OK"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex != alertView.cancelButtonIndex) {
                [self.photo deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadImagesTable" object:nil];
                }];
            }
        }];
    }
    else {
        UIAlertView *alert = [UIAlertView bk_alertViewWithTitle:@"Flagging this photo" message:@"Choose a reason for flagging:"];
        [alert bk_addButtonWithTitle:@"This photo is inappropriate" handler:^{
            [self flagWithType:FlagTypeInnapropiate];
        }];
        [alert bk_addButtonWithTitle:@"This photo is a spam" handler:^{
            [self flagWithType:FlagTypeSpam];
        }];
        [alert bk_addButtonWithTitle:@"This photo is a scam" handler:^{
            [self flagWithType:FlagTypeScam];
        }];
        [alert bk_addButtonWithTitle:@"This photo displays stolen content" handler:^{
            [self flagWithType:FlagTypeStolen];
        }];
        [alert bk_setCancelButtonWithTitle:@"CANCEL" handler:^{
            
        }];
        [alert show];
    }
    
    
    NSDictionary *dimensions = @{
                                 @"photoID": self.photo.objectId,
                                 @"user": [PFUser currentUser].username,
                                 @"flag_or_delete": (self.photo.canDelete) ? @"delete" : @"flag",
                                 };
    [PFAnalytics trackEvent:@"flag_or_delete_photo" dimensions:dimensions];
}

- (void)flagWithType:(FlagType)type
{
    NSString* typeString = @"";
    switch (type) {
        case FlagTypeInnapropiate:
            typeString = @"FlagTypeInnapropiate";
            break;
        case FlagTypeScam:
            typeString = @"FlagTypeScam";
            break;
        case FlagTypeSpam:
            typeString = @"FlagTypeSpam";
            break;
        case FlagTypeStolen:
            typeString = @"FlagTypeStolen";
            break;
        default:
            break;
    }
    
    [PFCloud callFunctionInBackground:@"flagPhoto"
                       withParameters:@{@"objectid":self.photo.objectId, @"userWhoFlagged":[PFUser currentUser].username, @"type":typeString}
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
    if(self.photo.showMap){
        [self.mapButton setImage:[UIImage imageNamed:@"map_Active"] forState:UIControlStateNormal];
        self.mapCloseButton.hidden = NO;
    }else{
        [self.mapButton setImage:[UIImage imageNamed:@"map"] forState:UIControlStateNormal];
        self.mapCloseButton.hidden = YES;
    }
}

- (void)showImageOrMapAnimated:(BOOL)animated
{
    self.mapOverlay.hidden = YES;
    
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
                        completion:^(BOOL b){
                            self.mapOverlay.hidden = (self.photo.showMap) ? NO:YES;
                        }];
    }
    else {
        action();
    }
}


#pragma mark - Map


- (UIImageView *)mapView
{
    if (!_mapView) {
        
        _mapView = [[UIImageView alloc] initWithFrame:self.imageView.bounds];
        
        NSString* markers;
        
        if(self.photo.locationHalf){
            markers = [NSString stringWithFormat:@"&markers=icon:http://2by2.parseapp.com/images/red.png|color:0x00cc99|%f,%f",self.photo.locationHalf.latitude,self.photo.locationHalf.longitude];
        }
        
        if([self.photo.state isEqualToString:@"full"] && self.photo.locationFull){
            
            markers = [NSString stringWithFormat:@"%@&markers=icon:http://2by2.parseapp.com/images/green.png|color:0xff3366|%f,%f",markers,self.photo.locationFull.latitude,self.photo.locationFull.longitude];
        }
        
        //NSInteger niceInt = niceCGFloat + 0.5f;
        
        NSInteger w = (NSInteger)self.imageView.frame.size.width;
        NSInteger h = (NSInteger)self.imageView.frame.size.height;
        
        NSString *mapImageURL = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/staticmap?key=AIzaSyDG_mNGbYeKU_UHS5n5CbreCkJ-Qo18A_M&zoom=12&style=lightness:-57|saturation:-100&size=%ldx%ld&maptype=roadmap%@&sensor=false",(long)w,(long)h,markers];
        
        NSString *escappedURL = [mapImageURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        NSLog(@"MapImageURL: %@",escappedURL);

        NSURL *URL = [NSURL URLWithString:escappedURL];

        
        [_mapView setImageWithURL:URL placeholderImage:[UIImage imageNamed:@"defaultUserImage"]];
        
        if (self.photo.locationHalf && self.photo.locationHalf.latitude != 0) {
            if([self.photo.user.objectId isEqualToString:[PFUser currentUser].objectId]){
                self.mapOverlayYou.text = @"You!";
            }else{
                self.mapOverlayYou.text = self.photo.user.username;
            }
            
        }else{
            if([self.photo.user.objectId isEqualToString:[PFUser currentUser].objectId]){
                self.mapOverlayYou.text = @"You!(?)";
            }else{
                self.mapOverlayYou.text = [NSString stringWithFormat:@"%@(?)",self.photo.user.username];
            }
        }
        
        if (self.photo.locationFull){
            self.mapOverlayPinRed.hidden = NO;
            self.mapOverlayUsername.hidden = NO;
        }
        
        if (self.photo.locationFull && self.photo.locationFull.latitude != 0) {
            if([self.photo.userFull.objectId isEqualToString:[PFUser currentUser].objectId]){
                self.mapOverlayUsername.text = @"You!";
            }else{
                self.mapOverlayUsername.text = self.photo.userFull.username;
            }
            
        }else{
            if([self.photo.userFull.objectId isEqualToString:[PFUser currentUser].objectId]){
                self.mapOverlayUsername.text = @"You!(?)";
            }else{
                self.mapOverlayUsername.text = [NSString stringWithFormat:@"%@(?)",self.photo.userFull.username];
            }
        }

        
        
    }
    return _mapView;
}

/*
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
    if (self.photo.locationHalf && self.photo.locationHalf.latitude != 0) {
        UserAnnotation *annotation = [UserAnnotation annotationWithGeoPoint:self.photo.locationHalf user:self.photo.user];
        annotation.halfOrFull = @"half";
        [self.mapView addAnnotation:annotation];
        
        if([self.photo.user.objectId isEqualToString:[PFUser currentUser].objectId]){
            self.mapOverlayYou.text = @"You!";
        }else{
            self.mapOverlayYou.text = self.photo.user.username;
        }
        
    }else{
        if([self.photo.user.objectId isEqualToString:[PFUser currentUser].objectId]){
            self.mapOverlayYou.text = @"You!(?)";
        }else{
            self.mapOverlayYou.text = [NSString stringWithFormat:@"%@(?)",self.photo.user.username];
        }
    }
    
    if (self.photo.locationFull){
        self.mapOverlayPinRed.hidden = NO;
        self.mapOverlayUsername.hidden = NO;
    }
    
    if (self.photo.locationFull && self.photo.locationFull.latitude != 0) {
        UserAnnotation *annotation = [UserAnnotation annotationWithGeoPoint:self.photo.locationFull user:self.photo.userFull];
        annotation.halfOrFull = @"full";
        [self.mapView addAnnotation:annotation];
        
        //NSLog(@"%@ / %@",self.photo.userFull.objectId,[PFUser currentUser].objectId);
        
        if([self.photo.userFull.objectId isEqualToString:[PFUser currentUser].objectId]){
            self.mapOverlayUsername.text = @"You!";
        }else{
            self.mapOverlayUsername.text = self.photo.userFull.username;
        }
        
    }else{
        if([self.photo.userFull.objectId isEqualToString:[PFUser currentUser].objectId]){
            self.mapOverlayUsername.text = @"You!(?)";
        }else{
            self.mapOverlayUsername.text = [NSString stringWithFormat:@"%@(?)",self.photo.userFull.username];
        }
    }
    
    [self.mapView zoomToFitAnnotationsAnimated:NO minimumSpan:MKCoordinateSpanMake(0.3, 0.3)];
}


- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id < MKAnnotation >)annotation
{
    
    MKAnnotationView *pin = (id)[mapView dequeueReusableAnnotationViewWithIdentifier:@"Pin"];
    if (pin == nil) {
        pin = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Pin"];
    }
    
    UserAnnotation* ua = (UserAnnotation*) annotation;
    
    if([ua.halfOrFull isEqualToString:@"half"]){
        pin.image = [UIImage imageNamed:@"pin_green.png"];
    }else{
        pin.image = [UIImage imageNamed:@"pin_red.png"];
    }
    
    
    pin.annotation = annotation;
    return pin;
}
  */

@end
