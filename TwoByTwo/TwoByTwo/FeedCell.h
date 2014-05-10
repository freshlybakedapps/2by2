//
//  FeedCell.h
//  TwoByTwo
//
//  Created by Joseph Lin on 11/2/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"

@protocol FeedCellDelegate;


@interface FeedCell : UICollectionViewCell

@property (nonatomic, weak) PFObject *photo;
@property (nonatomic) BOOL shouldHaveDetailLink;

- (void)showImageOrMapAnimated:(BOOL)animated;

@end


@protocol FeedCellDelegate <NSObject>
- (void)cell:(FeedCell *)cell showProfileForUser:(PFUser *)user;
- (void)cell:(FeedCell *)cell showCommentsForPhoto:(PFObject *)photo;
@end