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
#import "UIButton+AFNetworking.h"
#import "BlocksKit+UIKit.h"

typedef NS_ENUM(NSUInteger, FlagType) {
    FlagTypeInnapropiate = 0,
    FlagTypeSpam,
    FlagTypeScam,
    FlagTypeStolen,
};


@interface GridCell () <MKMapViewDelegate>
@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UIView *headerView;
@property (nonatomic, weak) IBOutlet UIButton *firstUserButton;
@property (nonatomic, weak) IBOutlet UIButton *secondUserButton;
@property (nonatomic, weak) IBOutlet UIView *footerView;
@property (nonatomic, weak) IBOutlet UIButton *likeButton;
@property (nonatomic, weak) IBOutlet UIButton *commentButton;
@property (nonatomic, weak) IBOutlet UILabel *filterLabel;
@property (nonatomic, weak) IBOutlet UIButton *mapButton;
@property (nonatomic, weak) IBOutlet UIButton *toolButton;

@property (nonatomic, strong) NSMutableArray* nLikes;
@end


@implementation GridCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.firstUserButton.imageView.layer.cornerRadius = 12.0;
    self.secondUserButton.imageView.layer.cornerRadius = 12.0;
}

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


#pragma mark - Content

- (void)setPhoto:(PFObject *)photo
{
    _photo = photo;
    __weak typeof(self) weakSelf = self;
    
    
    // User Avatars
    NSURL *firstURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=square", self.photo.user[@"facebookId"]]];
    [self.firstUserButton setImageForState:UIControlStateNormal withURL:firstURL placeholderImage:[UIImage imageNamed:@"icon-you"]];
    [self.firstUserButton setTitle:self.photo.user.username forState:UIControlStateNormal];
    
    if (self.photo.userFull) {
        NSURL *secondURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=square", self.photo.userFull[@"facebookId"]]];
        [self.secondUserButton setImageForState:UIControlStateNormal withURL:secondURL placeholderImage:[UIImage imageNamed:@"icon-you"]];
        [self.secondUserButton setTitle:self.photo.userFull.username forState:UIControlStateNormal];
        self.secondUserButton.hidden = NO;
    }
    else {
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
    if (self.photo.commentCount) {
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
    self.filterLabel.text = photo[@"filter"];


    // Map
    self.photo.showMap = NO;
    [self showImageOrMapAnimated:NO];

    
    // Flag or Delte
    if (photo.canDelete) {
        [self.toolButton setImage:[UIImage imageNamed:@"icon-delete"] forState:UIControlStateNormal];
    }
    else {
        [self.toolButton setImage:[UIImage imageNamed:@"icon-flag-on"] forState:UIControlStateNormal];
    }
}


#pragma mark - Actions

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
    NSArray *oldLikes = self.photo.likes;

    NSMutableArray *newLikes = [self.photo.likes mutableCopy];
    if (self.photo.likedByMe) {
        [newLikes removeObject:[PFUser currentUser].objectId];
    }
    else {
        [newLikes addObject:[PFUser currentUser].objectId];
    }
    self.photo.likes = [newLikes copy];
    [self updateLikeButton];
    
    
    __weak typeof(self) weakSelf = self;
    PFUser *user = [PFUser currentUser];
    NSDictionary *params = @{@"objectid":self.photo.objectId, @"userWhoLikedID":user.objectId, @"userWhoLikedUsername":user.username};
    [PFCloud callFunctionInBackground:@"likePhoto" withParameters:params block:^(NSNumber *result, NSError *error) {
        if (error) {
            NSLog(@"likePhoto error: %@", error);
            weakSelf.photo.likes = oldLikes;
            [weakSelf updateLikeButton];
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
        UIAlertView *alert = [UIAlertView bk_alertViewWithTitle:@"FLAGGING THIS PHOTO" message:@"Choose a reason for flagging:"];
        [alert bk_addButtonWithTitle:@"This photo is inappropriate" handler:^{
            [self flagWithType:FlagTypeInnapropiate];
        }];
        [alert bk_addButtonWithTitle:@"This photo is a spam" handler:^{
            [self flagWithType:FlagTypeSpam];
        }];
        [alert bk_addButtonWithTitle:@"This photo is a scam" handler:^{
            [self flagWithType:FlagTypeScam];
        }];
        [alert bk_addButtonWithTitle:@"This photo display stolen content" handler:^{
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
