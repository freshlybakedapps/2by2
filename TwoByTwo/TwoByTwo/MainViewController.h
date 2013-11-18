//
//  MainViewController.h
//  TwoByTwo
//
//  Created by Joseph Lin on 9/10/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, FeedType) {
    FeedTypeSingle = 0,
    FeedTypeGlobal,
    FeedTypeFollowing,
    FeedTypeYou,
};


@interface MainViewController : UIViewController

@end
