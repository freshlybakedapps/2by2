//
//  UserDefaultsManager.m
//  TwoByTwo
//
//  Created by Joseph Lin on 3/16/14.
//  Copyright (c) 2014 Joseph Lin. All rights reserved.
//

#import "UserDefaultsManager.h"


@implementation UserDefaultsManager

+ (NSString *)messageKeyForType:(FeedType)type
{
    NSString *key = [NSString stringWithFormat:@"messageWasSeen_%lu", (unsigned long)type];
    return key;
}

+ (BOOL)headerMessageDismissedForType:(FeedType)type
{
    NSString *key = [self messageKeyForType:type];
    BOOL value = [[NSUserDefaults standardUserDefaults] boolForKey:key];
    return value;
}

+ (void)setHeaderMessageDismissed:(BOOL)dismissed forType:(FeedType)type
{
    NSString *key = [self messageKeyForType:type];
    [[NSUserDefaults standardUserDefaults] setBool:dismissed forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
