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
    
    self.segmentedControl.frame = CGRectMake(20, 20, 280, 30);
    [self addSubview:self.segmentedControl];
}

- (void)updateNotificationCount:(NSUInteger)count
{
    //TODO: update the icon in the segmented control
}


@end
