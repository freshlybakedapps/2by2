//
//  NSMutableArray+Shuffling.m
//  TwoByTwo
//
//  Created by John Tubert on 1/2/15.
//  Copyright (c) 2015 John Tubert. All rights reserved.
//

#import "NSMutableArray+Shuffling.h"


@implementation NSMutableArray (Shuffling)

- (void)shuffle
{
    NSUInteger count = [self count];
    for (NSUInteger i = 0; i < count; ++i) {
        NSInteger remainingCount = count - i;
        NSInteger exchangeIndex = i + arc4random_uniform((u_int32_t )remainingCount);
        [self exchangeObjectAtIndex:i withObjectAtIndex:exchangeIndex];
    }
}

@end