//
//  MainNavBar.h
//  TwoByTwo
//
//  Created by John Tubert on 12/9/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MainNavigationBar : UINavigationBar

@property (nonatomic, strong) UISegmentedControl *segmentedControl;

- (void)updateNotificationCount:(NSUInteger)count;

@end
