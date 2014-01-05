//
//  IconSegmentedControl.m
//  TwoByTwo
//
//  Created by Joseph Lin on 11/17/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import "IconSegmentedControl.h"


@implementation IconSegmentedControl

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setBackgroundImage:[UIImage new] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [self setBackgroundImage:[UIImage new] forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    [self setDividerImage:[UIImage new] forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [self addTarget:self action:@selector(updateImages) forControlEvents:UIControlEventValueChanged];
    [self updateImages];
}

- (void)updateImages
{
    for (NSUInteger i = 0; i < self.numberOfSegments; i++) {
        UIImage *image = [self imageForSegmentAtIndex:i];
        [self setImage:image forSegmentAtIndex:i];
    }
}

- (void)setImage:(UIImage *)image forSegmentAtIndex:(NSUInteger)segment
{
    image = (segment == self.selectedSegmentIndex) ? [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] : [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [super setImage:image forSegmentAtIndex:segment];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSInteger previousIndex = self.selectedSegmentIndex;
    [super touchesEnded:touches withEvent:event];
    if (previousIndex == self.selectedSegmentIndex) {
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}


@end
