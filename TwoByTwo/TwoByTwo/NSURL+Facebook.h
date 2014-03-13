//
//  NSURL+Facebook.h
//  TwoByTwo
//
//  Created by Joseph Lin on 3/12/14.
//  Copyright (c) 2014 Joseph Lin. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSURL (Facebook)

+ (NSURL *)URLWithFacebookUserID:(NSString *)userID;
+ (NSURL *)URLWithFacebookUserID:(NSString *)userID size:(int)size;

@end
