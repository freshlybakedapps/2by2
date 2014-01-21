//
//  UserAnnotation.h
//  TwoByTwo
//
//  Created by Joseph Lin on 11/10/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>


@interface UserAnnotation : NSObject <MKAnnotation>

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly, copy) NSString *subtitle;
@property (nonatomic, copy) NSString *halfOrFull;


+ (instancetype)annotationWithGeoPoint:(PFGeoPoint *)geoPoint user:(PFUser *)user;

@end
