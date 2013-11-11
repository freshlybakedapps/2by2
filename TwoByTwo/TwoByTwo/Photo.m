//
//  Photo.m
//  TwoByTwo
//
//  Created by Joseph Lin on 11/10/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import "Photo.h"

NSString * const PFImageFullKey     = @"image_full";
NSString * const PFImageHalfKey     = @"image_half";
NSString * const PFLocationFullKey  = @"location_full";
NSString * const PFLocationHalfKey  = @"location_half";
NSString * const PFStateKey         = @"state";
NSString * const PFUserKey          = @"user";
NSString * const PFUserFullKey      = @"user_full";
NSString * const PFUserHalfKey      = @"user_half";
NSString * const PFUserInUseKey     = @"user_inuse";


@implementation Photo

@synthesize showMap;


- (PFFile *)imageFull
{
    return self[PFImageFullKey];
}

- (void)setImageFull:(PFFile *)imageFull
{
    self[PFImageFullKey] = imageFull;
}

- (PFFile *)imageHalf
{
    return self[PFImageHalfKey];
}

- (void)setImageHalf:(PFFile *)imageHalf
{
    self[PFImageHalfKey] = imageHalf;
}

- (PFGeoPoint *)locationFull
{
    return self[PFLocationFullKey];
}

- (void)setLocationFull:(PFGeoPoint *)locationFull
{
    self[PFLocationFullKey] = locationFull;
}

- (PFGeoPoint *)locationHalf
{
    return self[PFLocationHalfKey];
}

- (void)setLocationHalf:(PFGeoPoint *)locationHalf
{
    self[PFLocationHalfKey] = locationHalf;
}

- (NSString *)state
{
    return self[PFStateKey];
}

- (void)setState:(NSString *)state
{
    self[PFStateKey] = state;
}

- (PFUser *)user
{
    return self[PFUserKey];
}

- (void)setUser:(PFUser *)user
{
    self[PFUserKey] = user;
}

- (PFUser *)userFull
{
    return self[PFUserFullKey];
}

- (void)setUserFull:(PFUser *)userFull
{
    self[PFUserFullKey] = userFull;
}

- (PFUser *)userHalf
{
    return self[PFUserHalfKey];
}

- (void)setUserHalf:(PFUser *)userHalf
{
    self[PFUserHalfKey] = userHalf;
}

- (PFUser *)userInUse
{
    return self[PFUserInUseKey];
}

- (void)setUserInUse:(PFUser *)userInUse
{
    self[PFUserInUseKey] = userInUse;
}

@end
