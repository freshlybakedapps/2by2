//
//  CameraFriendsContainerCell.h
//  TwoByTwo
//
//  Created by Tuberts on 2/8/15.
//  Copyright (c) 2015 John Tubert. All rights reserved.
//

#import "ContainerCell.h"
#import "CameraViewController.h"
#import "FriendsViewController.h"

@interface CameraFriendsContainerCell : ContainerCell

@property (nonatomic, strong) CameraViewController *cameraViewController;

@property (nonatomic, strong) FriendsViewController *parent;

@end
