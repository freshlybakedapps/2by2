//
//  ContainerCell.h
//  TwoByTwo
//
//  Created by Joseph Lin on 5/10/14.
//  Copyright (c) 2014 Joseph Lin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"


@interface ContainerCell : UICollectionViewCell

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, readonly) ContentType type;

- (void)performQuery;
- (PFQuery *)photoQuery;
- (void)loadPhotosWithCompletion:(PFArrayResultBlock)completion;
- (void)loadFollowersWithCompletion:(PFArrayResultBlock)completion;

@end
