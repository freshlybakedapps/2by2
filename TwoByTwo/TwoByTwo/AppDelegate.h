//
//  AppDelegate.h
//  TwoByTwo
//
//  Created by Joseph Lin on 9/10/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainNavigationBar.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) UIWindow *window;

+ (AppDelegate *)delegate;
- (MainNavigationBar *)mainNavigationBar;
- (void)showLoginViewController;
- (void)showMainViewController;

@end
