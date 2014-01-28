//
//  GridTitleHeaderView.h
//  TwoByTwo
//
//  Created by Joseph Lin on 1/18/14.
//  Copyright (c) 2014 Joseph Lin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"
#import "GridViewController.h"


@interface GridTitleHeaderView : UICollectionReusableView
@property (nonatomic) FeedType type;
@property (nonatomic, weak) GridViewController* controller;
@end