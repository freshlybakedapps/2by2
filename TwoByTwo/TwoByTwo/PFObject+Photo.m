//
//  PFObject+Photo.m
//  TwoByTwo
//
//  Created by Joseph Lin on 11/10/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import "PFObject+Photo.h"

NSString * const PFImageFullKey     = @"image_full";
NSString * const PFImageHalfKey     = @"image_half";
NSString * const PFLocationFullKey  = @"location_full";
NSString * const PFLocationHalfKey  = @"location_half";
NSString * const PFStateKey         = @"state";
NSString * const PFUserKey          = @"user";
NSString * const PFUserFullKey      = @"user_full";
NSString * const PFUserInUseKey     = @"user_inuse";
NSString * const PFLikesKey         = @"likes";

static NSString * const kShowMap      = @"show_map";
static NSString * const kCommentCount = @"comment_count";


@implementation PFObject (Photo)

- (NSArray *)likes
{
    if(!self[PFLikesKey]){
        self[PFLikesKey] = @[];
    }
    
    return self[PFLikesKey];
}

- (void)setLikes:(NSArray *)likes
{
    NSLog(@"likes: %@",likes);
    if(likes){
       self[PFLikesKey] = likes;
    }    
}

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

- (PFUser *)userInUse
{
    return self[PFUserInUseKey];
}

- (void)setUserInUse:(PFUser *)userInUse
{
    self[PFUserInUseKey] = userInUse;
}

#pragma mark -

- (BOOL)showMap
{
    return [self[kShowMap] boolValue];
}

- (void)setShowMap:(BOOL)showMap
{
    self[kShowMap] = @(showMap);
}

- (NSString *)commentCount
{
    return self[kCommentCount];
}

- (void)setCommentCount:(NSString *)commentCount
{
    self[kCommentCount] = commentCount;
}

#pragma mark -

- (BOOL)canDelete
{
    // You can only delete your own photo that is not double-exposed yet.
    //NSLog(@"user: %@ %@",self.user,[PFUser currentUser]);
    return ([self.user.username isEqualToString:[PFUser currentUser].username] && [self.state isEqualToString:PFStateValueHalf]);
}

- (BOOL)likedByMe
{
    return ([self.likes containsObject:[PFUser currentUser].objectId]);
}

@end
