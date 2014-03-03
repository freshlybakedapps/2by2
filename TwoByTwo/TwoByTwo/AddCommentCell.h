//
//  AddCommentCell.h
//  TwoByTwo
//
//  Created by Joseph Lin on 3/2/14.
//  Copyright (c) 2014 Joseph Lin. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AddCommentCell : UICollectionViewCell

@property (nonatomic, strong) PFObject *photo;
@property (nonatomic, copy) void(^didSendComment)(PFObject *comment);

@end
