//
//  UIImage+UIImageResizing.h
//  TwoByTwo
//
//  Created by John Tubert on 10/25/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIImage (Addon)

- (UIImage *)scaleToSize:(CGSize)size contentMode:(UIViewContentMode)contentMode interpolationQuality:(CGInterpolationQuality)quality;
- (UIImage *)imageWithWatermark:(NSString *)text;

@end