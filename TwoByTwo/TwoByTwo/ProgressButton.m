//
//  ProgressButton.m
//  TwoByTwo
//
//  Created by Joseph Lin on 9/15/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import "ProgressButton.h"
#import "UIColor+Utilities.h"


@interface ProgressButton ()
@property (nonatomic, strong) CAShapeLayer *outerLayer;
@property (nonatomic, strong) CAShapeLayer *innerLayer;
@property (nonatomic, strong) CAShapeLayer *trackLayer;
@property (nonatomic, strong) CAShapeLayer *progressLayer;
@property (nonatomic, strong) UIColor *highlightedOuterColor;
@property (nonatomic, strong) UIColor *highlightedInnerColor;
@property (nonatomic, strong) UIColor *highlightedTrackColor;
@property (nonatomic, strong) UIColor *highlightedProgressColor;
@end


@implementation ProgressButton

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.outerLayer = [CAShapeLayer layer];
    self.innerLayer = [CAShapeLayer layer];
    self.trackLayer = [CAShapeLayer layer];
    self.progressLayer = [CAShapeLayer layer];
    
    self.outerColor = [UIColor colorWithRed:41.0/255 green:41.0/255 blue:41.0/255 alpha:1.0];
    self.innerColor = [UIColor colorWithRed:41.0/255 green:41.0/255 blue:41.0/255 alpha:1.0];
    self.trackColor = [UIColor colorWithRed:102.0/255 green:102.0/255 blue:102.0/255 alpha:1.0];
    self.progressColor = [UIColor colorWithRed:255.0/255 green:102.0/255 blue:102.0/255 alpha:1.0];
    self.trackInset = 4.0;
    self.trackWidth = 2.0;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat length = MIN(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    CGFloat radius = (0.5 * length) - self.trackInset;
    CGPoint center = CGPointMake(0.5 * CGRectGetWidth(self.bounds), 0.5 * CGRectGetHeight(self.bounds));
    CGRect outerRect = CGRectInset(self.bounds, 0.5 * (CGRectGetWidth(self.bounds) - length), 0.5 * (CGRectGetHeight(self.bounds) - length));
    CGRect trackRect = CGRectInset(outerRect, self.trackInset, self.trackInset);
    CGRect innerRect = CGRectInset(trackRect, self.trackWidth, self.trackWidth);
    
    self.outerLayer.frame = self.bounds;
    self.outerLayer.path = [UIBezierPath bezierPathWithOvalInRect:outerRect].CGPath;
    self.outerLayer.fillColor = self.outerColor.CGColor;
    [self.layer insertSublayer:self.outerLayer atIndex:0];

    self.trackLayer.frame = self.bounds;
    self.trackLayer.path = [UIBezierPath bezierPathWithOvalInRect:trackRect].CGPath;
    self.trackLayer.fillColor = self.trackColor.CGColor;
    [self.layer insertSublayer:self.trackLayer atIndex:1];

    self.progressLayer.frame = self.bounds;
    self.progressLayer.path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:0 endAngle:M_PI clockwise:YES].CGPath;
    self.progressLayer.fillColor = self.progressColor.CGColor;
    [self.layer insertSublayer:self.progressLayer atIndex:2];

    self.innerLayer.frame = self.bounds;
    self.innerLayer.path = [UIBezierPath bezierPathWithOvalInRect:innerRect].CGPath;
    self.innerLayer.fillColor = self.innerColor.CGColor;
    [self.layer insertSublayer:self.innerLayer atIndex:3];
}


#pragma mark -

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    
    [CATransaction setAnimationDuration:0.1];
    self.outerLayer.fillColor = (highlighted) ? self.highlightedOuterColor.CGColor : self.outerColor.CGColor;
    self.innerLayer.fillColor = (highlighted) ? self.highlightedInnerColor.CGColor : self.innerColor.CGColor;
    self.trackLayer.fillColor = (highlighted) ? self.highlightedTrackColor.CGColor : self.trackColor.CGColor;
    self.progressLayer.fillColor = (highlighted) ? self.highlightedProgressColor.CGColor : self.progressColor.CGColor;
}

- (void)setOuterColor:(UIColor *)outerColor
{
    _outerColor = outerColor;
    self.highlightedOuterColor = [outerColor darkenColor];
}

- (void)setInnerColor:(UIColor *)innerColor
{
    _innerColor = innerColor;
    self.highlightedInnerColor = [innerColor darkenColor];
}

- (void)setTrackColor:(UIColor *)trackColor
{
    _trackColor = trackColor;
    self.highlightedTrackColor = [trackColor darkenColor];
}

- (void)setProgressColor:(UIColor *)progressColor
{
    _progressColor = progressColor;
    self.highlightedProgressColor = [progressColor darkenColor];
}

@end
