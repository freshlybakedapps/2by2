//
//  LikersCell.h
//  TwoByTwo
//
//  Created by Joseph Lin on 3/2/14.
//  Copyright (c) 2014 Joseph Lin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"

@protocol LikersCellDelegate;


@interface LikersCell : UICollectionViewCell

@property (nonatomic, strong) NSArray *likers;
@property (nonatomic, weak) id <LikersCellDelegate> delegate;

@end

@protocol LikersCellDelegate <NSObject>
- (void)cell:(LikersCell *)cell showProfileForUser:(PFUser *)user;
- (void)cell:(LikersCell *)cell showCommentsForPhoto:(PFObject *)photo;
@end


