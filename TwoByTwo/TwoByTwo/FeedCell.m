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
@property (nonatomic, weak) IBOutlet UIButton *deleteButton;
@property (nonatomic, weak) IBOutlet UIButton *flagButton;

-(IBAction)flagPhoto:(id)sender;
-(IBAction)deletePhoto:(id)sender;

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
    
    NSString *state = [_object objectForKey:@"state"];
    PFUser *user = [_object objectForKey:@"user"];
    
    //NSLog(@"%@ / %@",[user username], [[PFUser currentUser] username]);
    
    
    NSString *fileName;
    if([state isEqualToString:@"full"]){
        //NSLog(@"state is full");
        fileName = @"image_full";
    }else{
        //NSLog(@"state is halfffff");
        fileName = @"image_half";
    }
    
    PFFile *file = [_object objectForKey:fileName];
    PFUser *user_full = [_object objectForKey:@"user_full"];
    NSString* username = [user username];
    
    if(user_full){
        //NSLog(@"user_full: %@", [user_full username]);
        username = [username stringByAppendingFormat:@" / %@",[user_full username]];
    }
    
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            UIImage *image = [UIImage imageWithData:data];
            
            self.username.text = username;
            
            self.imageView.image = image;
            
            [self checkWhichButtonToShow];
        } else {
            NSLog(@"Error on fetching file");
        }
    }];  
    
}

- (void) checkWhichButtonToShow{
    NSString *state = [_object objectForKey:@"state"];
    PFUser *user = [_object objectForKey:@"user"];
    
    self.deleteButton.hidden = NO;
    self.flagButton.hidden = NO;
    
    if([state isEqualToString:@"full"]){
        //you should not be able to delete a photo that was double exposed.
        self.deleteButton.hidden = YES;
    }else{
        //if image is half exposed and it's your own photo, you should be able to delete it
        if([[user username] isEqualToString:[[PFUser currentUser] username]]){
            self.deleteButton.hidden = NO;
        }else{
            self.deleteButton.hidden = YES;
        }
        
    }
    //you should not be able to flag your own photo
    if([[user username] isEqualToString:[[PFUser currentUser] username]]){
        self.flagButton.hidden = YES;
    }
}

-(IBAction)flagPhoto:(id)sender{
    [PFCloud callFunctionInBackground:@"flagPhoto"
                       withParameters:@{@"objectid":[_object objectId],@"userWhoFlagged":[[PFUser currentUser] username]}
                                block:^(NSString *result, NSError *error) {
                                    if (!error) {
                                        NSLog(@"flag photo result: %@", result);
                                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Flag" message:@"Thanks for flagging this image." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
                                        [alert show];
                                    }
                                }];
}

-(IBAction)deletePhoto:(id)sender{
    UIAlertView * confirmAlert = [[UIAlertView alloc] initWithTitle:@"Confirm" message:@"Are you sure you want to delete this photo?" delegate:self cancelButtonTitle:@"CANCEL" otherButtonTitles:@"OK",nil];
    [confirmAlert show];
}


- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != [alertView cancelButtonIndex])
    {
        [_object deleteInBackgroundWithBlock:^(BOOL b, NSError *error){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadImagesTable" object:nil];
        }];
    }	
}






@end
