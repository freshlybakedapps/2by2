//
//  NSObject+Swizzle.h
//  TwoByTwo
//
//  Created by Joseph Lin on 8/19/13.
//  Copyright (c) 2014 Joseph Lin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>


@interface NSObject (Swizzle)

+ (void)swizzleSelector:(SEL)originalSelector withSelector:(SEL)otherSelector;
+ (void)swizzleClassSelector:(SEL)originalSelector withSelector:(SEL)otherSelector;

@end
