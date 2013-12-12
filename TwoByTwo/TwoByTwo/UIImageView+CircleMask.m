//
//  UIImageView+CircleMask.m
//  TwoByTwo
//
//  Created by John Tubert on 12/11/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import "UIImageView+CircleMask.h"

@implementation UIImageView (CircleMask)

- (void) addMaskToBounds:(CGRect) maskBounds
{
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    
    CGPathRef maskPath = CGPathCreateWithEllipseInRect(maskBounds, NULL);
    maskLayer.bounds = maskBounds;
    [maskLayer setPath:maskPath];
    [maskLayer setFillColor:[[UIColor blackColor] CGColor]];
    maskLayer.position = CGPointMake(maskBounds.size.width/2, maskBounds.size.height/2);
    
    [self.layer setMask:maskLayer];
}


@end
