//
//  Constants.h
//  TwoByTwo
//
//  Created by Joseph Lin on 5/10/14.
//  Copyright (c) 2014 Joseph Lin. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const NoficationDidUpdatePushNotificationCount;
extern NSString * const NoficationUserInfoKeyCount;
extern NSString * const NoficationShouldReloadPhotos;

typedef NS_ENUM(NSUInteger, FeedType) {
    FeedTypeSingle = 0,
    FeedTypeGlobal,
    FeedTypeFollowing,
    FeedTypeYou,
    FeedTypeNotifications,
    FeedTypeFriend,
    FeedTypeHashtag,
};

typedef NS_ENUM(NSUInteger, ContentType) {
    ContentTypePopular = 0,
    ContentTypePublic,
    ContentTypeFriends,
    ContentTypeProfile,
    ContentTypeNotifications,
    ContentTypeCount,
};
