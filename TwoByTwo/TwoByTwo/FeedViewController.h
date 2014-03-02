//
//  FeedViewController.h
//  TwoByTwo
//
//  Created by Joseph Lin on 9/10/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"


@interface FeedViewController : UICollectionViewController

@property (nonatomic) FeedType type;
@property (nonatomic, strong) NSString *photoID;
@property (nonatomic, strong) PFUser *user;

@property (nonatomic) int headerSize;

- (void) toggleGridFeed;

- (void) toggleSingleDouble;


@end
