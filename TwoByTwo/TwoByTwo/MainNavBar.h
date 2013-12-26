//
//  MainNavBar.h
//  TwoByTwo
//
//  Created by John Tubert on 12/9/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainNavBar : UINavigationBar

@property (nonatomic, strong) UILabel* label;

- (void) updateNotification:(int)n;

@end
