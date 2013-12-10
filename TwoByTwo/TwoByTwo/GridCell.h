//
//  GridCell.h
//  TwoByTwo
//
//  Created by Joseph Lin on 11/2/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GridCell : UICollectionViewCell

@property (nonatomic, weak) PFObject *photo;
@property (nonatomic, strong) NSMutableArray* nLikes;

@property (nonatomic, weak) UIButton *userButton;
@property (nonatomic, weak) UIButton *userFullButton;

- (void)showImageOrMapAnimated:(BOOL)animated;

@end
