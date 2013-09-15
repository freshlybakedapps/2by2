//
//  UIColor+Addon.h
//  
//
//  Created by Joseph Lin on 9/9/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIColor (Utilities)

+ (UIColor *)colorFromHexString:(NSString *)hexString;
- (UIColor *)darkenColor;

@end
