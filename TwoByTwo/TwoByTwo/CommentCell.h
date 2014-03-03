//
//  CommentCell.h
//  TwoByTwo
//
//  Created by Joseph Lin on 12/31/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CommentCell : UICollectionViewCell

@property (nonatomic, strong) PFObject *comment;

+ (CGFloat)heightForComment:(PFObject *)comment;

@end
