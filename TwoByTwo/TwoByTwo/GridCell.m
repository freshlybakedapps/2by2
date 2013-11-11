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
@property (nonatomic, readonly) PFFile *file;
@end


@implementation GridCell


#pragma mark - Content

- (PFFile *)file
{
    NSString *state = [_object objectForKey:@"state"];
    NSString *fileName = ([state isEqualToString:@"full"]) ? @"image_full" : @"image_half";
    PFFile *file = [_object objectForKey:fileName];
    return file;
}

- (void)setObject:(PFObject *)object
{
    _object = object;
    
    PFUser *user = [_object objectForKey:@"user"];
    PFUser *user_full = [_object objectForKey:@"user_full"];
    NSString* username = user.username;
    if (user_full) {
        username = [username stringByAppendingFormat:@" / %@",[user_full username]];
    }
    self.textLabel.text = username;
    
    self.imageView.image = nil;
    [self.file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            UIImage *image = [UIImage imageWithData:data];
            self.imageView.image = image;
        }
        else {
            NSLog(@"getDataInBackgroundWithBlock: %@", error);
        }
    }];
    
    self.object[@"showMap"] = @(NO);
    [self showImageOrMapAnimated:NO];
    [self checkWhichButtonToShow];
}

- (void)checkWhichButtonToShow
{
    NSString *state = [self.object objectForKey:@"state"];
    PFUser *user = [self.object objectForKey:@"user"];
    
    if ([user.username isEqualToString:[PFUser currentUser].username]) {
        
        //you should not be able to flag your own photo
        self.flagButton.hidden = YES;
        
        if ([state isEqualToString:@"full"]) {
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

    self.textLabel.alpha = self.deleteButton.alpha = self.flagButton.alpha = self.mapButton.alpha = (CGRectGetWidth(layoutAttributes.frame) > 100) ? 1.0 : 0.0;
}


#pragma mark - Actions

- (IBAction)flagButtonTapped:(id)sender
{
    [UIAlertView showAlertViewWithTitle:@"Confirm" message:@"Are you sure you want to flag this photo?" cancelButtonTitle:@"Cancel" otherButtonTitles:@[@"OK"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            [PFCloud callFunctionInBackground:@"flagPhoto"
                               withParameters:@{@"objectid":self.object.objectId, @"userWhoFlagged":[PFUser currentUser].username}
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
            [self.object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadImagesTable" object:nil];
            }];
        }
    }];
}

- (IBAction)mapButtonTapped:(id)sender
{
    BOOL showMap = [self.object[@"showMap"] boolValue];
    self.object[@"showMap"] = @(!showMap);
    [self showImageOrMapAnimated:YES];
}

- (void)showImageOrMapAnimated:(BOOL)animated
{
    void (^action)(void) = ^{
        if ([self.object[@"showMap"] boolValue]) {
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
                           options:([self.object[@"showMap"] boolValue]) ? UIViewAnimationOptionTransitionFlipFromRight : UIViewAnimationOptionTransitionFlipFromLeft
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
    PFGeoPoint *half = self.object[@"location_half"];
    if (half) {
        PFUser *user = self.object[@"user_half"];
        UserAnnotation *annotation = [UserAnnotation annotationWithGeoPoint:half user:user];
        [self.mapView addAnnotation:annotation];
    }
    
    PFGeoPoint *full = self.object[@"location_full"];
    if (full) {
        PFUser *user = self.object[@"user_full"];
        UserAnnotation *annotation = [UserAnnotation annotationWithGeoPoint:full user:user];
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
