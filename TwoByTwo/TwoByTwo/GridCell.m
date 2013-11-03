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


#pragma mark - Content

- (PFFile *)file
{
    NSString *state = [_object objectForKey:@"state"];
    NSString *fileName = ([state isEqualToString:@"full"]) ? @"image_full" : @"image_half";
    PFFile *file = [_object objectForKey:fileName];
    return file;
}

- (void)setObject:(PFObject *)object
{
    _object = object;
    
    PFUser *user = [_object objectForKey:@"user"];
    PFUser *user_full = [_object objectForKey:@"user_full"];
    NSString* username = user.username;
    if (user_full) {
        username = [username stringByAppendingFormat:@" / %@",[user_full username]];
    }
    self.textLabel.text = username;
    
    self.imageView.image = nil;
    [self.file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            UIImage *image = [UIImage imageWithData:data];
            self.imageView.image = image;
        }
        else {
            NSLog(@"getDataInBackgroundWithBlock: %@", error);
        }
    }];
    
    [self checkWhichButtonToShow];
}

- (void)checkWhichButtonToShow
{
    NSString *state = [self.object objectForKey:@"state"];
    PFUser *user = [self.object objectForKey:@"user"];
    
    if ([user.username isEqualToString:[PFUser currentUser].username]) {
        
        //you should not be able to flag your own photo
        self.flagButton.hidden = YES;
        
        if ([state isEqualToString:@"full"]) {
            //you should not be able to delete a photo that was double exposed.
            self.deleteButton.hidden = YES;
        }
        else {
            //if image is half exposed and it's your own photo, you should be able to delete it
            self.deleteButton.hidden = NO;
        }
    }
    else {
        self.flagButton.hidden = NO;
        self.deleteButton.hidden = YES;
    }
}


#pragma mark - Layout

// Without this, contentView's subviews won't be animated properly.
- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes
{
    [self layoutIfNeeded];

    self.textLabel.alpha = self.deleteButton.alpha = self.flagButton.alpha = (CGRectGetWidth(layoutAttributes.frame) > 100) ? 1.0 : 0.0;
}


#pragma mark - Actions

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
