//
//  NSDate+Addon.m
//  TwoByTwo
//
//  Created by Joseph Lin on 12/31/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import "NSDate+Addon.h"


@implementation NSDate (Addon)

- (NSString *)timeAgoString
{
    NSTimeInterval difference = -[self timeIntervalSinceNow];
    NSArray *periods = @[@"s", @"m", @"h", @"d", @"week", @"month", @"year"];
    NSArray *lengths = @[@60, @60, @24, @7, @4.35, @12];
    
    NSUInteger index;
    for (index = 0; index < lengths.count; index++) {
        NSInteger length = [lengths[index] integerValue];
        if (difference >= length) {
            difference /= length;
        }
        else {
            break;
        }
    }
    
    NSString *period = periods[index];
    if (period.length > 1 && (int)difference != 1) {
        period = [period stringByAppendingString:@"s"];
    }
    
    return [NSString stringWithFormat:@"%d%@", (int)difference, period];
}

@end
