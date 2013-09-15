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
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat length = MIN(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    CGRect outerRect = CGRectInset(self.bounds, 0.5 * (CGRectGetWidth(self.bounds) - length), 0.5 * (CGRectGetHeight(self.bounds) - length));
    CGRect trackRect = CGRectInset(outerRect, self.trackInset, self.trackInset);
    CGRect innerRect = CGRectInset(trackRect, self.trackWidth, self.trackWidth);
    
    self.outerLayer.frame = self.bounds;
    self.outerLayer.path = [UIBezierPath bezierPathWithOvalInRect:outerRect].CGPath;
    [self.layer insertSublayer:self.outerLayer atIndex:0];

    self.trackLayer.frame = self.bounds;
    self.trackLayer.path = [UIBezierPath bezierPathWithOvalInRect:trackRect].CGPath;
    [self.layer insertSublayer:self.trackLayer atIndex:1];

    self.progressLayer.frame = self.bounds;
    [self.layer insertSublayer:self.progressLayer atIndex:2];

    self.innerLayer.frame = self.bounds;
    self.innerLayer.path = [UIBezierPath bezierPathWithOvalInRect:innerRect].CGPath;
    [self.layer insertSublayer:self.innerLayer atIndex:3];
}


#pragma mark -

- (void)setProgress:(double)progress
{
    _progress = progress;
    
    CGFloat length = MIN(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    CGFloat radius = (0.5 * length) - self.trackInset;
    CGPoint center = CGPointMake(0.5 * CGRectGetWidth(self.bounds), 0.5 * CGRectGetHeight(self.bounds));
    CGFloat startAngle = -M_PI_2;
    CGFloat endAngle = -M_PI_2 + (2 * M_PI * progress);
    
    self.progressLayer.path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES].CGPath;
    
    [self setTitle:[NSString stringWithFormat:@"%1.0f%%", progress * 100] forState:UIControlStateNormal];
    [self setTitleColor:self.progressColor forState:UIControlStateNormal];
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
    self.outerLayer.fillColor = (self.highlighted) ? self.highlightedOuterColor.CGColor : self.outerColor.CGColor;
}

- (void)setInnerColor:(UIColor *)innerColor
{
    _innerColor = innerColor;
    self.highlightedInnerColor = [innerColor darkenColor];
    self.innerLayer.fillColor = (self.highlighted) ? self.highlightedInnerColor.CGColor : self.innerColor.CGColor;
}

- (void)setTrackColor:(UIColor *)trackColor
{
    _trackColor = trackColor;
    self.highlightedTrackColor = [trackColor darkenColor];
    self.trackLayer.fillColor = (self.highlighted) ? self.highlightedTrackColor.CGColor : self.trackColor.CGColor;
}

- (void)setProgressColor:(UIColor *)progressColor
{
    _progressColor = progressColor;
    self.highlightedProgressColor = [progressColor darkenColor];
    self.progressLayer.fillColor = (self.highlighted) ? self.highlightedProgressColor.CGColor : self.progressColor.CGColor;
}

@end
