//
//  ContainerCell.h
//  TwoByTwo
//
//  Created by Joseph Lin on 5/10/14.
//  Copyright (c) 2014 Joseph Lin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FeedHeaderView.h"
#import "FeedFooterView.h"
#import "Constants.h"


@interface ContainerCell : UICollectionViewCell <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic) BOOL showingFeed;
@property (nonatomic) BOOL showingDouble;
@property (nonatomic, readonly) ContentType type;

- (void)performQuery;
- (PFQuery *)photoQuery;
- (void)loadPhotosWithCompletion:(PFArrayResultBlock)completion;
- (void)loadFollowersWithCompletion:(PFArrayResultBlock)completion;

@end
