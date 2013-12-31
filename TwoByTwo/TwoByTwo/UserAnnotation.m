//
//  UserAnnotation.m
//  TwoByTwo
//
//  Created by Joseph Lin on 11/10/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import "UserAnnotation.h"


@interface UserAnnotation ()
@property (nonatomic, strong) PFUser *user;
@end


@implementation UserAnnotation

+ (instancetype)annotationWithGeoPoint:(PFGeoPoint *)geoPoint user:(PFUser *)user
{
    UserAnnotation *annotation = [UserAnnotation new];
    annotation.coordinate = CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude);
    annotation.user = user;
    return annotation;
}

- (NSString *)title
{
//    PFUser *currentUser = [PFUser currentUser];
    return self.user.username;
}

- (NSString *)subtitle
{
    return nil;
}

@end
