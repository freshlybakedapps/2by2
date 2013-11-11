//
//  Photo.h
//  TwoByTwo
//
//  Created by Joseph Lin on 11/10/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import <Parse/Parse.h>

extern NSString * const PFImageFullKey;
extern NSString * const PFImageHalfKey;
extern NSString * const PFLocationFullKey;
extern NSString * const PFLocationHalfKey;
extern NSString * const PFStateKey;
extern NSString * const PFUserKey;
extern NSString * const PFUserFullKey;
extern NSString * const PFUserHalfKey;
extern NSString * const PFUserInUseKey;



@interface Photo : PFObject

@property PFFile *imageFull;
@property PFFile *imageHalf;
@property PFGeoPoint *locationFull;
@property PFGeoPoint *locationHalf;
@property NSString *state;
@property PFUser *user;
@property PFUser *userFull;
@property PFUser *userHalf;
@property PFUser *userInUse;

@property (nonatomic) BOOL showMap;

@end
