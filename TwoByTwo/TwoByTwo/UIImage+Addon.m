//
//  UIImage+UIImageResizing.m
//  TwoByTwo
//
//  Created by John Tubert on 10/25/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import "UIImage+Addon.h"


@implementation UIImage (Addon)

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

- (UIImage *)imageWithWatermark:(NSString *)text
{
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont appLightFontOfSize:6], NSForegroundColorAttributeName:[UIColor whiteColor]};
    
        
    CGRect rect = [text boundingRectWithSize:CGSizeMake(self.size.width, MAXFLOAT)
                                     options:NSStringDrawingUsesLineFragmentOrigin
                                  attributes:attributes
                                     context:nil];
    CGRect textRect = CGRectMake(self.size.width - rect.size.width-5, self.size.height - rect.size.height-5, rect.size.width, rect.size.height);
    
    //CGRectMake(CGFloat x, CGFloat y, CGFloat width, CGFloat height)
    CGRect backgRect = CGRectMake(self.size.width - rect.size.width-10, self.size.height - rect.size.height-8, rect.size.width+10, rect.size.height+8);
    
    UIGraphicsBeginImageContextWithOptions(self.size, YES, 0.0);
    [self drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
    
    [[UIColor blackColor] set];
    CGContextFillRect( UIGraphicsGetCurrentContext(), backgRect);
    
    
    [text drawInRect:textRect withAttributes:attributes];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (UIImage *)circleWithNumber:(NSInteger)number radius:(CGFloat)radius
{
    CGRect rect = CGRectMake(0, 0, radius, radius);
    
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // 1. Draw image the first time to use as mask
    [[UIColor blackColor] setFill];
    CGContextFillEllipseInRect (context, rect);
    
    NSString *text = [NSString stringWithFormat:@"%ld", (long)number];
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    [text drawInRect:CGRectOffset(rect, 0, 6) withAttributes:@{
                                                               NSFontAttributeName:[UIFont appMediumFontOfSize:14],
                                                               NSForegroundColorAttributeName:[UIColor whiteColor],
                                                               NSParagraphStyleAttributeName:paragraphStyle,
                                                               }];
    
    // 2. Create Mask
    CGContextConcatCTM(context, CGAffineTransformMake(1, 0, 0, -1, 0, CGRectGetHeight(rect)));
    CGImageRef image = CGBitmapContextCreateImage(context);
    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(image), CGImageGetHeight(image), CGImageGetBitsPerComponent(image), CGImageGetBitsPerPixel(image), CGImageGetBytesPerRow(image), CGImageGetDataProvider(image), CGImageGetDecode(image), CGImageGetShouldInterpolate(image));
    CFRelease(image);
    
    
    
    // 3. Clear, apply mask, and then draw image the second time
    CGContextClearRect(context, rect);
    
    CGContextSaveGState(context);
    CGContextClipToMask(context, rect, mask);
    CFRelease(mask);
    
    [[UIColor appRedColor] setFill];
    CGContextFillEllipseInRect (context, rect);
    
    CGContextRestoreGState(context);
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    return finalImage;
}

@end