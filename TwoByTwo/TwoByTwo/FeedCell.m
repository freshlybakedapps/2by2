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
@property (nonatomic, weak) IBOutlet UILabel *username;
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
    
    NSString *state = [object objectForKey:@"state"];
    NSString *fileName;
    if([state isEqualToString:@"full"]){
        fileName = @"image_full";
    }else{
        fileName = @"image_half";
    }
    
    PFFile *file = [object objectForKey:fileName];
    
    PFUser *user = [object objectForKey:@"user"];
    
    PFUser *user_full = [object objectForKey:@"user_full"];
    
    NSString* username = [user username];
    
    if(user_full){
        NSLog(@"user_full: %@", [user_full username]);
        username = [username stringByAppendingFormat:@" / %@",[user_full username]];

    }
    
    
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            UIImage *image = [UIImage imageWithData:data];
            
            self.username.text = username;
            
            self.imageView.image = image;
        } else {
            NSLog(@"Error on fetching file");
        }
    }];  
    
}





@end
