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
@property (nonatomic, weak) IBOutlet UIButton *mapButton;
@property (nonatomic, weak) IBOutlet UIButton *deleteButton;
@property (nonatomic, weak) IBOutlet UIButton *flagButton;
@property (nonatomic, weak) IBOutlet UILabel *textLabel;
@property (nonatomic, weak) IBOutlet UIButton *likes;
@end


@implementation GridCell


#pragma mark - Content

- (void)setPhoto:(PFObject *)photo
{
    _photo = photo;
    
    NSString* username = photo.user.username;
    if (photo.userFull) {
        username = [username stringByAppendingFormat:@" / %@", photo.userFull.username];
    }
    self.textLabel.text = username;
    
    
    NSArray *likesArray = photo.likes;
    int result = [likesArray count];
    [self.likes setTitle:[NSString stringWithFormat:@"%d", result] forState:UIControlStateNormal];
    
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
    
    photo.showMap = NO;
    [self showImageOrMapAnimated:NO];
    [self checkWhichButtonToShow];
}

- (void)checkWhichButtonToShow
{
    if ([self.photo.user.username isEqualToString:[PFUser currentUser].username]) {
        
        //you should not be able to flag your own photo
        self.flagButton.hidden = YES;
        
        if ([self.photo.state isEqualToString:@"full"]) {
            //you should not be able to delete a photo that was double exposed.
            self.deleteButton.hidden = YES;
        }
        else {
            //if image is half exposed and it's your own photo, you should be able to delete it
            self.deleteButton.hidden = NO;
        }
    }
    else {
        self.flagButton.hidden = NO;
        self.deleteButton.hidden = YES;
    }
}


#pragma mark - Layout

// Without this, contentView's subviews won't be animated properly.
- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes
{
    [self layoutIfNeeded];

    self.likes.alpha = self.textLabel.alpha = self.deleteButton.alpha = self.flagButton.alpha = self.mapButton.alpha = (CGRectGetWidth(layoutAttributes.frame) > 100) ? 1.0 : 0.0;
}


#pragma mark - Actions

- (IBAction)likeButtonTapped:(id)sender{
    
    [PFCloud callFunctionInBackground:@"likePhoto"
                       withParameters:@{@"objectid":self.photo.objectId, @"userWhoLiked":[PFUser currentUser].objectId}
                                block:^(NSNumber *result, NSError *error) {
                                    if (!error) {
                                        NSLog(@"The photo was sucessfully liked: %@", result);
                                        [self.likes setTitle:[result stringValue] forState:UIControlStateNormal];
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

- (IBAction)flagButtonTapped:(id)sender
{
    [UIAlertView showAlertViewWithTitle:@"Confirm" message:@"Are you sure you want to flag this photo?" cancelButtonTitle:@"Cancel" otherButtonTitles:@[@"OK"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            [PFCloud callFunctionInBackground:@"flagPhoto"
                               withParameters:@{@"objectid":self.photo.objectId, @"userWhoFlagged":[PFUser currentUser].username}
                                        block:^(NSString *result, NSError *error) {
                                            if (!error) {
                                                NSLog(@"Thanks for flagging this image.");
                                                //[UIAlertView showAlertViewWithTitle:@"Flag" message:@"Thanks for flagging this image." cancelButtonTitle:@"OK" otherButtonTitles:nil handler:nil];
                                            }
                                        }];

        }
    }];
}

- (IBAction)deleteButtonTapped:(id)sender
{
    [UIAlertView showAlertViewWithTitle:@"Confirm" message:@"Are you sure you want to delete this photo?" cancelButtonTitle:@"Cancel" otherButtonTitles:@[@"OK"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            [self.photo deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadImagesTable" object:nil];
            }];
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
            [self.contentView insertSubview:self.mapView belowSubview:self.imageView];
            [self.imageView removeFromSuperview];
            [self.mapButton setTitle:@"Close" forState:UIControlStateNormal];
        }
        else {
            if (!self.imageView.superview) {
                [self.contentView insertSubview:self.imageView belowSubview:self.mapView];
                [self.mapView removeFromSuperview];
                self.mapView = nil;
                [self.mapButton setTitle:@"Map" forState:UIControlStateNormal];
            }
        }
    };
    
    if (animated) {
        [UIView transitionWithView:self.contentView
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
        _mapView = [[MKMapView alloc] initWithFrame:self.contentView.bounds];
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
