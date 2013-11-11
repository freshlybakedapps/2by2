//
//  MKMapView+Utilities.h
//  TwoByTwo
//
//  Created by Joseph Lin on 11/10/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import <MapKit/MapKit.h>


@interface MKMapView (Utilities)

- (void)zoomToFitAnnotationsAnimated:(BOOL)animated minimumSpan:(MKCoordinateSpan)minimumSpan;

@end
