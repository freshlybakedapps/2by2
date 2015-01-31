//
//  UIViewController+Swizzle.m
//  TwoByTwo
//
//  Created by Joseph Lin on 5/27/14.
//  Copyright (c) 2014 Joseph Lin. All rights reserved.
//

#import "UIViewController+Swizzle.h"
#import "NSObject+Swizzle.h"


@implementation UIViewController (Swizzle)

+ (void)load
{
    [super load];
    [self swizzleSelector:@selector(viewDidLoad) withSelector:@selector(swizzledViewDidLoad)];
}

- (void)swizzledViewDidLoad
{
    [self swizzledViewDidLoad];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

@end
