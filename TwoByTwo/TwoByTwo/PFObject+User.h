//
//  PFObject+User.h
//  TwoByTwo
//
//  Created by Joseph Lin on 3/12/14.
//  Copyright (c) 2014 Joseph Lin. All rights reserved.
//

#import <Parse/Parse.h>
#import "NSURL+Facebook.h"

extern NSString * const PFFullNameKey;
extern NSString * const PFFacebookIDKey;
extern NSString * const PFNotificationWasAccessedKey;

extern NSString * const PFCommentsEmailAlertKey;
extern NSString * const PFDigestEmailAlertKey;
extern NSString * const PFFollowsEmailAlertKey;
extern NSString * const PFFriendTookPhotoEmailAlertKey;
extern NSString * const PFLikesEmailAlertKey;
extern NSString * const PFOverexposeEmailAlertKey;

extern NSString * const PFCommentsPushAlertKey;
extern NSString * const PFFollowsPushAlertKey;
extern NSString * const PFFriendTookPhotoPushAlertKey;
extern NSString * const PFLikesPushAlertKey;
extern NSString * const PFOverexposePushAlertKey;


@interface PFObject (User)

@property (nonatomic, strong) NSString *fullName;
@property (nonatomic, strong) NSString *facebookID;
@property (nonatomic, strong) NSDate *notificationWasAccessed;

@property (nonatomic) BOOL commentsEmailAlert;
@property (nonatomic) BOOL digestEmailAlert;
@property (nonatomic) BOOL followsEmailAlert;
@property (nonatomic) BOOL friendTookPhotoEmailAlert;
@property (nonatomic) BOOL likesEmailAlert;
@property (nonatomic) BOOL overexposeEmailAlert;

@property (nonatomic) BOOL commentsPushAlert;
@property (nonatomic) BOOL followsPushAlert;
@property (nonatomic) BOOL friendTookPhotoPushAlert;
@property (nonatomic) BOOL likesPushAlert;
@property (nonatomic) BOOL overexposePushAlert;

@end
