//
//  ThumbCell.m
//  TwoByTwo
//
//  Created by Joseph Lin on 3/1/14.
//  Copyright (c) 2014 Joseph Lin. All rights reserved.
//

#import "ThumbCell.h"


@interface ThumbCell ()
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@end


@implementation ThumbCell

- (void)setPhoto:(PFObject *)photo
{
    _photo = photo;
    
    self.imageView.image = nil;
    PFFile *file = ([self.photo.state isEqualToString:PFStateValueFull]) ? self.photo.imageFull : self.photo.imageHalf;
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            UIImage *image = [UIImage imageWithData:data];
            self.imageView.image = image;
        }
        else {
            NSLog(@"getDataInBackgroundWithBlock: %@", error);
        }
    }];
}

@end
