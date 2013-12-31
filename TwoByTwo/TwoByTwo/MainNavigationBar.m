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
    
    CGFloat width = CGRectGetWidth(self.frame);
    
    self.textLabel.frame = CGRectMake(kLabelPaddingX, kLabelOffsetY, width - 2 * kLabelPaddingX, kLabelHeight);
    self.actionButton.frame = CGRectMake(width - kLabelPaddingX - kLabelHeight, kLabelOffsetY, kLabelHeight, kLabelHeight);

    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[UISegmentedControl class]]) {
            view.frame = CGRectMake(view.frame.origin.x, kSegmentedControlOffsetY, view.frame.size.width, view.frame.size.height);
        }
    }
}

- (UILabel *)textLabel
{
    if (!_textLabel) {
        _textLabel = [UILabel new];
        _textLabel.textColor = [UIColor grayColor];
        _textLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_textLabel];
    }
    return _textLabel;
}

- (UIButton *)actionButton
{
    if (!_actionButton){
        _actionButton = [UIButton new];
        [self addSubview:_actionButton];
    }
    return _actionButton;
}

- (void)updateNotificationCount:(NSUInteger)count
{
    //TODO: update the icon in the segmented control
}


@end
