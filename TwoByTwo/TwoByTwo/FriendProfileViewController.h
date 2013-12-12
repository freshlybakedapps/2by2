//
//  FriendProfileViewController.h
//  TwoByTwo
//
//  Created by John Tubert on 12/11/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendProfileViewController : UIViewController

@property (nonatomic, strong) PFUser *friend;
@property (nonatomic, strong) NSString *friendName;

@end
