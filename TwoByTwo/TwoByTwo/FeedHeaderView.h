//
//  FeedTitleHeaderView.h
//  TwoByTwo
//
//  Created by Joseph Lin on 1/18/14.
//  Copyright (c) 2014 Joseph Lin. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol FeedHeaderViewDelegate <NSObject>
- (void)setShowingFeed:(BOOL)showingFeed;
- (void)setShowingDouble:(BOOL)showingDouble;
- (void)updateHeaderHeight;
@end


@interface FeedHeaderView : UICollectionReusableView

@property (nonatomic, copy) NSString *title;
@property (nonatomic, weak) id <FeedHeaderViewDelegate> delegate;

@end
