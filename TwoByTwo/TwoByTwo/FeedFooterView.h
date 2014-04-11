//
//  FeedFooterView.h
//  TwoByTwo
//
//  Created by John Tubert on 1/27/14.
//  Copyright (c) 2014 Joseph Lin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"
#import "FeedViewController.h"


@interface FeedFooterView : UICollectionReusableView

@property (nonatomic) FeedType type;
@property (nonatomic) BOOL showingDouble;
@property (nonatomic, strong) FeedViewController *controller;


@end
