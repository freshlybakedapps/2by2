//
//  FeedTitleHeaderView.h
//  TwoByTwo
//
//  Created by Joseph Lin on 1/18/14.
//  Copyright (c) 2014 Joseph Lin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FeedViewController.h"


@protocol FeedHeaderViewDelegate <NSObject>
- (void)setShowingFeed:(BOOL)showingFeed;
- (void)setShowingDouble:(BOOL)showingDouble;
- (void)updateHeaderHeight;
@end


@interface FeedHeaderView : UICollectionReusableView

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UIView *controlView;
@property (nonatomic, weak) IBOutlet UIButton *feedToggleButton;
@property (nonatomic, weak) IBOutlet UILabel *exposureLabel;
@property (nonatomic, weak) IBOutlet UIButton *exposureToggleButton;

@property (nonatomic) FeedType type;
@property (nonatomic, weak) id <FeedHeaderViewDelegate> delegate;

+ (CGFloat)headerHeightForType:(FeedType)type;

@end
