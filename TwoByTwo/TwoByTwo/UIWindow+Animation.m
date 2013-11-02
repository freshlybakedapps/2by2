//
//  UIWindow+Animation.m
//  TwoByTwo
//
//  Created by Joseph Lin on 5/20/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import "UIWindow+Animation.h"


@implementation UIWindow (Animation)

- (void)setRootViewController:(UIViewController *)rootViewController animated:(BOOL)animated
{
    if (animated) {
        [UIView transitionWithView:self
                          duration:0.3
                           options:UIViewAnimationOptionTransitionFlipFromRight
                        animations:^{
                            
                            // Disable animation to fix glitch
                            // http://stackoverflow.com/questions/8053832/rootviewcontroller-animation-transition-initial-orientation-is-wrong
                            BOOL oldState = [UIView areAnimationsEnabled];
                            [UIView setAnimationsEnabled:NO];
                            self.rootViewController = rootViewController;
                            [UIView setAnimationsEnabled:oldState];
                        }
                        completion:nil];
    }
    else {
        self.rootViewController = rootViewController;
    }
}

@end
