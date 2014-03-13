//
//  PFObject+Photo.h
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
extern NSString * const PFLikesKey;


@interface PFObject (Photo)

@property (nonatomic, strong) PFFile *imageFull;
@property (nonatomic, strong) PFFile *imageHalf;
@property (nonatomic, strong) PFGeoPoint *locationFull;
@property (nonatomic, strong) PFGeoPoint *locationHalf;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) PFUser *user;
@property (nonatomic, strong) PFUser *userFull;
@property (nonatomic, strong) PFUser *userInUse;
@property (nonatomic, strong) NSArray *likes;

@property (nonatomic) BOOL showMap;
@property (nonatomic, strong) NSString *commentCount;
@property (nonatomic, readonly) BOOL canDelete;
@property (nonatomic, readonly) BOOL likedByMe;

@end
