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
@property (nonatomic, weak) IBOutlet UILabel *textLabel;
@property (nonatomic, readonly) PFFile *file;
@end


@implementation GridCell

- (PFFile *)file
{
    NSString *state = [_object objectForKey:@"state"];
    NSString *fileName = ([state isEqualToString:@"full"]) ? @"image_full" : @"image_half";
    PFFile *file = [_object objectForKey:fileName];
    return file;
}

- (void)setObject:(PFObject *)object
{
    if (_object != object) {
        _object = object;
        
        [self.file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                UIImage *image = [UIImage imageWithData:data];
                self.imageView.image = image;
            }
            else {
                NSLog(@"getDataInBackgroundWithBlock: %@", error);
            }
        }];
    }
}

- (void)prepareForReuse
{
//    [self.file cancel]; // This crashes when scrolls. Why?
    self.imageView.image = nil;
    [super prepareForReuse];
}

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes
{
    [self layoutIfNeeded];
}

- (void)updateTextLabel
{
    self.textLabel.alpha = !self.textLabel.alpha;
}

@end
