//
//  InviteManager.h
//  TwoByTwo
//
//  Created by Joseph Lin on 5/27/14.
//  Copyright (c) 2014 Joseph Lin. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface InviteManager : NSObject

+ (instancetype)sharedInstance;
- (void)inviteByEmail;
- (void)inviteByFacebook;

@end
