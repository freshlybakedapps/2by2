//
//  ProfileViewController.h
//  TwoByTwo
//
//  Created by John Tubert on 10/25/14.
//  Copyright (c) 2014 John Tubert. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"

@interface ProfileViewController : UIViewController

@property (nonatomic) FeedType type;
@property (nonatomic, strong) PFUser *user;

+ (instancetype)controller;

@end
