//
//  GridCell.m
//  TwoByTwo
//
//  Created by Joseph Lin on 11/2/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import "GridCell.h"


@interface GridCell ()
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@end


@implementation GridCell

- (void)setObject:(PFObject *)object
{
    _object = object;
    
    NSString *state = [_object objectForKey:@"state"];
    NSString *fileName = ([state isEqualToString:@"full"]) ? @"image_full" : @"image_half";
    PFFile *file = [_object objectForKey:fileName];
    
    PFUser *user = [_object objectForKey:@"user"];
    NSString* username = user.username;
    
    PFUser *user_full = [_object objectForKey:@"user_full"];
    if (user_full) {
        username = [username stringByAppendingFormat:@" / %@",[user_full username]];
    }
    
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
