//
//  GridCell.h
//  TwoByTwo
//
//  Created by Joseph Lin on 11/2/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GridCellDelegate;


@interface GridCell : UICollectionViewCell
@property (nonatomic, weak) PFObject *photo;
@property (nonatomic, weak) id <GridCellDelegate> delegate;
- (void)showImageOrMapAnimated:(BOOL)animated;
@end


@protocol GridCellDelegate <NSObject>
- (void)cell:(GridCell *)cell showProfileForUser:(PFUser *)user;
- (void)cell:(GridCell *)cell showCommentsForPhoto:(PFObject *)photo;
@end