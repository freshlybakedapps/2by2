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


@interface FeedCell ()
@property (nonatomic, weak) IBOutlet UIView *headerView;
@property (nonatomic, weak) IBOutlet UIImageView *firstUserImageView;
@property (nonatomic, weak) IBOutlet UIImageView *secondUserImageView;
@property (nonatomic, weak) IBOutlet UIButton *firstUserButton;
@property (nonatomic, weak) IBOutlet UIButton *secondUserButton;

@property (nonatomic, weak) IBOutlet UIButton *detailsButton;

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
@property (nonatomic, weak) IBOutlet UIButton *mapButton;
@property (nonatomic, weak) IBOutlet UIButton *toolButton;
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
    self.mapSecondUserLabel.font = [UIFont appMediumFontOfSize:14];
    self.mapFirstUserLabel.font = [UIFont appMediumFontOfSize:14];
    
    self.detailsButton.titleLabel.font = [UIFont appMediumFontOfSize:14];
    
}


#pragma mark - Content


- (void)setPhoto:(PFObject *)photo
{    
    
    if(!self.shouldHaveDetailLink){
        self.detailsButton.hidden = YES;
    }

    
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
        PFQuery *query = [PFQuery queryWithClassName:@"Comment"];
        [query whereKey:@"commentID" equalTo:self.photo.objectId];
        [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
            weakSelf.photo.commentCount = [NSString stringWithFormat:@"%d", number];
            [weakSelf.commentButton setTitle:weakSelf.photo.commentCount forState:UIControlStateNormal];
        }];
    }
    
    
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
    PFFile *file = ([self.photo.state isEqualToString:@"full"]) ? self.photo.imageFull : self.photo.imageHalf;
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
    NSString *markers;
    if (self.photo.locationHalf) {
        markers = [NSString stringWithFormat:@"&markers=icon:http://2by2.parseapp.com/images/redMarker@2x.png|color:0x00cc99|%f,%f", self.photo.locationHalf.latitude, self.photo.locationHalf.longitude];
    }
    if ([self.photo.state isEqualToString:@"full"] && self.photo.locationFull) {
        markers = [NSString stringWithFormat:@"%@&markers=icon:http://2by2.parseapp.com/images/greenMarker@2x.png|color:0xff3366|%f,%f", markers, self.photo.locationFull.latitude, self.photo.locationFull.longitude];
    }
    
    NSString *mapURLString = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/staticmap?key=AIzaSyDG_mNGbYeKU_UHS5n5CbreCkJ-Qo18A_M&style=lightness:-57|saturation:-100&size=640x640&maptype=roadmap%@&sensor=false", markers];
    mapURLString = [mapURLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *URL = [NSURL URLWithString:mapURLString];
    [self.imageView setImageWithURL:URL placeholderImage:[UIImage imageNamed:@"defaultUserImage"]];
    
    
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
    [self.likeButton setTitle:[NSString stringWithFormat:@"%d", self.photo.likes.count] forState:UIControlStateNormal];
}


#pragma mark - Actions

- (IBAction)detailButtonTapped:(id)sender
{
    NSLog(@"detailButtonTapped");
    [self.delegate cell:self showCommentsForPhoto:self.photo];
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
    NSDictionary *params = @{@"objectid":self.photo.objectId, @"userWhoLikedID":user.objectId, @"userWhoLikedUsername":user.username};
    [PFCloud callFunctionInBackground:@"likePhoto" withParameters:params block:^(NSNumber *result, NSError *error) {
        if (error) {
            NSLog(@"likePhoto error: %@", error);
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
                                 @"photoID": self.photo.objectId,
                                 @"user": [PFUser currentUser].username,
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


/*
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
