//
//  MainNavBar.m
//  TwoByTwo
//
//  Created by John Tubert on 12/9/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import "MainNavBar.h"

@implementation MainNavBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (CGSize)sizeThatFits:(CGSize)size {
    CGSize newSize = CGSizeMake(self.frame.size.width,100);
    return newSize;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    for (UIView *view in self.subviews) {
        //NSLog(@"view: %@",view);
        if ([NSStringFromClass([view class]) rangeOfString:@"Segmented"].length != 0) {
            //NSLog(@"UISegmentedControl");
            view.frame = CGRectMake(view.frame.origin.x, 20.0, view.frame.size.width, view.frame.size.height);
        }
    }
}

@end
