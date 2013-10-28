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

- (void)setObject:(PFObject *)object
{
    _object = object;
    
    PFFile *file = [object objectForKey:@"newThumbnail"];
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            UIImage *image = [UIImage imageWithData:data];
            
            self.imageView.image = image;
        } else {
            NSLog(@"Error on fetching file");
        }
    }];  
    
}





@end
