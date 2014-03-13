//
//  NSURL+Facebook.m
//  TwoByTwo
//
//  Created by Joseph Lin on 3/12/14.
//  Copyright (c) 2014 Joseph Lin. All rights reserved.
//

#import "NSURL+Facebook.h"


@implementation NSURL (Facebook)

+ (NSURL *)URLWithFacebookUserID:(NSString *)userID
{
    return [self URLWithFacebookUserID:userID size:60];
}

+ (NSURL *)URLWithFacebookUserID:(NSString *)userID size:(int)size
{
    if (!userID.length) {
        return nil;
    }

    NSString *string = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=square&width=%d&height=%d", userID, size, size];
    NSURL *URL = [NSURL URLWithString:string];
    return URL;
}


@end
