//
//  UserDefaultsManager.h
//  TwoByTwo
//
//  Created by Joseph Lin on 3/16/14.
//  Copyright (c) 2014 Joseph Lin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MainViewController.h"


@interface UserDefaultsManager : NSObject

+ (BOOL)headerMessageDismissedForType:(FeedType)type;
+ (void)setHeaderMessageDismissed:(BOOL)dismissed forType:(FeedType)type;

@end
