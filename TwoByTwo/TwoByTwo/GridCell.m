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


@interface GridCell () <MKMapViewDelegate>
@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UIView *headerView;
@property (nonatomic, weak) IBOutlet UIView *footerView;
@property (nonatomic, weak) IBOutlet UILabel *textLabel;
@property (nonatomic, weak) IBOutlet UIButton *likeButton;
@property (nonatomic, weak) IBOutlet UIButton *mapButton;
@property (nonatomic, weak) IBOutlet UIButton *toolButton;
@end


@implementation GridCell

#pragma mark - Content

- (void)setPhoto:(PFObject *)photo
{
    _photo = photo;
    
    
    // Name(s)
    NSString* username = photo.user.username;
    if (photo.userFull) {
        username = [username stringByAppendingFormat:@" / %@", photo.userFull.username];
    }
    self.textLabel.text = username;
    
    
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
    
    [PFCloud callFunctionInBackground:@"likePhoto"
                       withParameters:@{@"objectid":self.photo.objectId, @"userWhoLiked":[PFUser currentUser].objectId}
                                block:^(NSNumber *result, NSError *error) {
                                    
                                    if (error) {
                                        NSLog(@"like photo: %@", error);
                                        [UIAlertView showAlertViewWithTitle:@"Error" message:error.localizedDescription cancelButtonTitle:@"OK" otherButtonTitles:nil handler:nil];
                                        
                                        // Revert likes
                                        self.photo.likes = oldLikes;
                                        [self updateLikeButton];
                                    }
                                }];
    
    /*
    [PFCloud callFunctionInBackground:@"getFacebookFriends"
                       withParameters:@{@"user":[PFUser currentUser]}
                                block:^(NSArray *result, NSError *error) {
                                    if (!error) {
                                        NSLog(@"Facebook friends: %@", result);
                                    }
                                }];
     
    
    [PFCloud callFunctionInBackground:@"isUsernameUnique"
                       withParameters:@{@"username":@"jtubert"}
                                block:^(NSString *result, NSError *error) {
                                    if (!error) {
                                        NSLog(@"isUsernameUnique: %@", result);
                                    }
                                }];
     */

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
