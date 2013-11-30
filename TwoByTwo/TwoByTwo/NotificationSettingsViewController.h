//
//  NotificationSettingsViewController.h
//  TwoByTwo
//
//  Created by John Tubert on 11/27/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotificationSettingsViewController : UITableViewController

@property (strong,nonatomic) NSMutableArray* emailSection;
@property (strong,nonatomic) NSMutableArray* pushSection;
@property (strong,nonatomic) NSMutableArray* digestSection;

extern NSString * const ALERT_EMAIL_OVEREXPOSED;
extern NSString * const ALERT_EMAIL_LIKES;
extern NSString * const ALERT_EMAIL_FOLLOW;
extern NSString * const ALERT_PUSH_OVEREXPOSED;
extern NSString * const ALERT_PUSH_LIKES;
extern NSString * const ALERT_PUSH_FOLLOW;
extern NSString * const DIGEST_EMAIL;


@end
