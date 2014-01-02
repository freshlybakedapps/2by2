//
//  UIFont+TwoByTwo.m
//  TwoByTwo
//
//  Created by Joseph Lin on 1/2/14.
//  Copyright (c) 2014 Joseph Lin. All rights reserved.
//

#import "UIFont+TwoByTwo.h"


@implementation UIFont (TwoByTwo)

+ (UIFont *)appLightFontOfSize:(CGFloat)fontSize
{
    return [UIFont fontWithName:@"Dosis-Light" size:fontSize];
}


+ (UIFont *)appFontOfSize:(CGFloat)fontSize
{
    return [UIFont fontWithName:@"Dosis-Regular" size:fontSize];
}

+ (UIFont *)appMediumFontOfSize:(CGFloat)fontSize
{
    return [UIFont fontWithName:@"Dosis-Medium" size:fontSize];
}

@end
