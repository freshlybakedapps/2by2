//
//  AppDelegate.h
//  TwoByTwo
//
//  Created by Joseph Lin on 9/10/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) UIWindow *window;





@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, readonly) int networkStatus;

- (void)showLoginViewController;
- (void)showMainViewController;
- (BOOL)isParseReachable;

+ (AppDelegate *)delegate;

@end
