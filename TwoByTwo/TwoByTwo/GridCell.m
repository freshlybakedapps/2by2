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
@property (nonatomic, weak) IBOutlet UIButton *deleteButton;
@property (nonatomic, weak) IBOutlet UIButton *flagButton;
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
        
        PFUser *user = [_object objectForKey:@"user"];
        PFUser *user_full = [_object objectForKey:@"user_full"];
        NSString* username = user.username;
        if (user_full) {
            username = [username stringByAppendingFormat:@" / %@",[user_full username]];
        }
        self.textLabel.text = username;

        
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

- (void)updateContent
{
    BOOL shouldShow = (CGRectGetWidth(self.frame) > 100);
    
    [UIView animateWithDuration:0.3 animations:^{
        self.textLabel.alpha = self.deleteButton.alpha = self.flagButton.alpha = (shouldShow) ? 1.0 : 0.0;
    }];
}

- (IBAction)flagButtonTapped:(id)sender
{
    [PFCloud callFunctionInBackground:@"flagPhoto"
                       withParameters:@{@"objectid":self.object.objectId, @"userWhoFlagged":[PFUser currentUser].username}
                                block:^(NSString *result, NSError *error) {
                                    if (!error) {
                                        [UIAlertView showAlertViewWithTitle:@"Flag" message:@"Thanks for flagging this image." cancelButtonTitle:@"OK" otherButtonTitles:nil handler:nil];
                                    }
                                }];
}

- (IBAction)deleteButtonTapped:(id)sender
{
    [UIAlertView showAlertViewWithTitle:@"Confirm" message:@"Are you sure you want to delete this photo?" cancelButtonTitle:@"Cancel" otherButtonTitles:@[@"OK"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            [self.object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadImagesTable" object:nil];
            }];
        }
    }];
}

@end
