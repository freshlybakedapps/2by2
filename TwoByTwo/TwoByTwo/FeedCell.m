//
//  FeedCell.m
//  TwoByTwo
//
//  Created by Joseph Lin on 9/10/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import "FeedCell.h"


@interface FeedCell ()
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@end


@implementation FeedCell

- (void)setPhoto:(Photo *)photo
{
    _photo = photo;
    
    UIImage *image = [UIImage imageWithContentsOfFile:photo.photoPath];
    self.imageView.image = image;
}

@end
