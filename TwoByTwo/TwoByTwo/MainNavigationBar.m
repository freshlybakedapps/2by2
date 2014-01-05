//
//  MainNavBar.m
//  TwoByTwo
//
//  Created by John Tubert on 12/9/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import "MainNavigationBar.h"

static CGFloat const kLabelPaddingX = 20.0;
static CGFloat const kLabelOffsetY = 60.0;
static CGFloat const kLabelHeight = 30.0;
static CGFloat const kSegmentedControlOffsetY = 20.0;


@interface MainNavigationBar ()
@end


@implementation MainNavigationBar

- (CGSize)sizeThatFits:(CGSize)size
{
    CGSize newSize = CGSizeMake(self.frame.size.width, 100);
    return newSize;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.segmentedControl.frame = CGRectMake(10, 20, 300, 30);
    [self addSubview:self.segmentedControl];
}

- (void)updateNotificationCount:(NSUInteger)count
{
    if (count) {
        UIImage *image = [self circleWithNumber:count radius:30];
        [self.segmentedControl setImage:image forSegmentAtIndex:4];
    }
    else {
        UIImage *image = [UIImage imageNamed:@"notifications_Active"];
        [self.segmentedControl setImage:image forSegmentAtIndex:4];
    }
}

- (UIImage *)circleWithNumber:(NSInteger)number radius:(CGFloat)radius
{
    CGRect rect = CGRectMake(0, 0, radius, radius);
    
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // 1. Draw image the first time to use as mask
    [[UIColor blackColor] setFill];
    CGContextFillEllipseInRect (context, rect);

    NSString *text = [NSString stringWithFormat:@"%d", number];
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
