//
//  UINavigationBar+CustomNav.m
//  TwoByTwo
//
//  Created by John Tubert on 12/9/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import "UINavigationBar+CustomNav.h"

@implementation UINavigationBar (customNav)
- (CGSize)sizeThatFits:(CGSize)size {
    CGSize newSize = CGSizeMake(self.frame.size.width,100);
    return newSize;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}


@end