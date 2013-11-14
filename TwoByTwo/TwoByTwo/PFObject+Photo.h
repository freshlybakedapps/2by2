//
//  PFObject+Photo.h
//  TwoByTwo
//
//  Created by Joseph Lin on 11/10/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import <Parse/Parse.h>

extern NSString * const PFPhotoKey;
extern NSString * const PFImageFullKey;
extern NSString * const PFImageHalfKey;
extern NSString * const PFLocationFullKey;
extern NSString * const PFLocationHalfKey;
extern NSString * const PFStateKey;
extern NSString * const PFUserKey;
extern NSString * const PFUserFullKey;
extern NSString * const PFUserHalfKey;
extern NSString * const PFUserInUseKey;
extern NSString * const PFLikesKey;


@interface PFObject (Photo)

@property (nonatomic, weak) PFFile *imageFull;
@property (nonatomic, weak) PFFile *imageHalf;
@property (nonatomic, weak) PFGeoPoint *locationFull;
@property (nonatomic, weak) PFGeoPoint *locationHalf;
@property (nonatomic, weak) NSString *state;
@property (nonatomic, weak) PFUser *user;
@property (nonatomic, weak) PFUser *userFull;
@property (nonatomic, weak) PFUser *userInUse;
@property (nonatomic, weak) NSArray *likes;

@property (nonatomic) BOOL showMap;

@end
