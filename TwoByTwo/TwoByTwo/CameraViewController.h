//
//  CameraViewController.h
//  TwoByTwo
//
//  Created by Joseph Lin on 9/10/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CameraViewController : UIViewController <CLLocationManagerDelegate>

@property (nonatomic, weak) PFObject *photo;
@property (nonatomic) BOOL sharingFacebook;
@property (nonatomic) BOOL m_postingInProgress;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) UIImageView* watermark;

+ (instancetype)controller;

@end
