//
//  GridFooterView.h
//  TwoByTwo
//
//  Created by John Tubert on 1/27/14.
//  Copyright (c) 2014 Joseph Lin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"


@interface GridFooterView : UICollectionReusableView

@property (nonatomic) FeedType type;
@property (nonatomic) BOOL showingDouble;

@end
