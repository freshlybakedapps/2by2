//
//  UIImage+UIImageResizing.m
//  TwoByTwo
//
//  Created by John Tubert on 10/25/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import "UIImage+UIImageResizing.h"


@implementation UIImage (Resize)

- (UIImage *)scaleToSize:(CGSize)size contentMode:(UIViewContentMode)contentMode interpolationQuality:(CGInterpolationQuality)quality
{
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetInterpolationQuality(context, quality);
    CGContextSetShouldAntialias(context, YES);
    
    float oldRatio = self.size.width / self.size.height;
    float newRatio = size.width / size.height;
    
    switch (contentMode) {
        case UIViewContentModeScaleAspectFit:
            if (oldRatio > newRatio) {
                CGFloat height = size.width / oldRatio;
                [self drawInRect:CGRectMake(0, 0.5*(size.height - height), size.width, height) blendMode:kCGBlendModeNormal alpha:1.0];
            }
            else {
                CGFloat width = size.height * oldRatio;
                [self drawInRect:CGRectMake(0.5*(size.width - width), 0, width, size.height) blendMode:kCGBlendModeNormal alpha:1.0];
            }
            break;
            
        case UIViewContentModeScaleAspectFill:
            if (oldRatio > newRatio) {
                CGFloat width = size.height * oldRatio;
                [self drawInRect:CGRectMake(0.5*(size.width - width), 0, width, size.height) blendMode:kCGBlendModeNormal alpha:1.0];
            }
            else {
                CGFloat height = size.width / oldRatio;
                [self drawInRect:CGRectMake(0, 0.5*(size.height - height), size.width, height) blendMode:kCGBlendModeNormal alpha:1.0];
            }
            break;
            
        default:
            [self drawInRect:CGRectMake(0, 0, size.width, size.height) blendMode:kCGBlendModeNormal alpha:1.0];
            break;
    }
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end