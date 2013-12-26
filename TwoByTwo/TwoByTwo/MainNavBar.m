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

- (void) updateNotification:(int)n{
    if(n > 0){
        self.label.text = [NSString stringWithFormat:@"%d",n];
        self.label.hidden = NO;
    }else{
        self.label.hidden = YES;
    }
    
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize newSize = CGSizeMake(self.frame.size.width,100);
    return newSize;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if(!self.label){
        CGFloat n = 20;
        self.label = [ [UILabel alloc ] initWithFrame:CGRectMake(270.0, 10.0, n, n) ];
        self.label.text = @"1";
        self.label.layer.cornerRadius = n/2;
        [self.label setTextAlignment:NSTextAlignmentCenter];
        
        
        self.label.textColor = [UIColor whiteColor];
        self.label.backgroundColor = [UIColor redColor];
        self.label.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(10.0)];
        [self addSubview:self.label];
        
        self.label.hidden = YES;
    }
    
    
    for (UIView *view in self.subviews) {
        //NSLog(@"view: %@",view);
        if ([NSStringFromClass([view class]) rangeOfString:@"Segmented"].length != 0) {
            //NSLog(@"UISegmentedControl");
            view.frame = CGRectMake(view.frame.origin.x, 20.0, view.frame.size.width, view.frame.size.height);
        }
    }
}

@end
