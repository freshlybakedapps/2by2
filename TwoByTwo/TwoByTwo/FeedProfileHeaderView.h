//
//  FeedHeaderView.h
//  TwoByTwo
//
//  Created by Joseph Lin on 11/17/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FeedViewController.h"


@interface FeedProfileHeaderView : UICollectionReusableView
@property (nonatomic, strong) PFUser *user;

@property (nonatomic, weak) FeedViewController* controller;

- (void) toggleFeedFeed;
@end
