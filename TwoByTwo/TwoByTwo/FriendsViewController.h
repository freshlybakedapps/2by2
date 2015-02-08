//
//  FriendsViewController.h
//  TwoByTwo
//
//  Created by Tuberts on 2/8/15.
//  Copyright (c) 2015 John Tubert. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CameraViewController.h"
#import "Constants.h"

@interface FriendsViewController : UIViewController

@property (nonatomic, strong) CameraViewController *cameraViewController;

+ (instancetype)controller;

@end
