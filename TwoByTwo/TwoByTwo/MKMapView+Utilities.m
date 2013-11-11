//
//  MKMapView+Utilities.m
//  TwoByTwo
//
//  Created by Joseph Lin on 11/10/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import "MKMapView+Utilities.h"

#define kSpanPadding 1.1


@implementation MKMapView (Utilities)

- (void)zoomToFitAnnotationsAnimated:(BOOL)animated minimumSpan:(MKCoordinateSpan)minimumSpan
{
    if (self.annotations.count == 0)
        return;
    
    CLLocationCoordinate2D topLeftCoord = CLLocationCoordinate2DMake(-90, 180);
    CLLocationCoordinate2D bottomRightCoord = CLLocationCoordinate2DMake(90, -180);
    
    for (id <MKAnnotation> annotation in self.annotations) {
        topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude);
        topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude);
        
        bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude);
        bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude);
    }
    
    MKCoordinateRegion region;
    region.center.latitude = (topLeftCoord.latitude + bottomRightCoord.latitude) * 0.5;
    region.center.longitude = (topLeftCoord.longitude + bottomRightCoord.longitude) * 0.5;
    region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * kSpanPadding;
    region.span.latitudeDelta = MAX(minimumSpan.latitudeDelta, region.span.latitudeDelta);
    region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * kSpanPadding;
    region.span.longitudeDelta = MAX(minimumSpan.longitudeDelta, region.span.longitudeDelta);
    
    region = [self regionThatFits:region];
    [self setRegion:region animated:animated];
}

@end
