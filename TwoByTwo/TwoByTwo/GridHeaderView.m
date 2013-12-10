//
//  GridHeaderView.m
//  TwoByTwo
//
//  Created by Joseph Lin on 11/17/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import "GridHeaderView.h"
#import "EverythingElseViewController.h"
#import "EditProfileViewController.h"


@implementation GridHeaderView

- (void)render{    
    self.nameLabel.text = [PFUser currentUser][@"fullName"];
    self.usernameLabel.text = [PFUser currentUser].username;
    self.emailLabel.text = [PFUser currentUser][@"email"];
    self.numPhotosLabel.text = [NSString stringWithFormat:@"%lu Photos",(unsigned long)self.controller.objects.count];
    self.followingLabel.text = [NSString stringWithFormat:@"%lu Following",(unsigned long)self.controller.followers.count];
    self.followersLabel.text = [NSString stringWithFormat:@"%lu followers",(unsigned long)self.controller.followers.count];
    self.bioTextview.text = [PFUser currentUser][@"bio"];
    
    //let's make sure we only nake this request once
    if(self.controller.facebookId == nil){
        [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if (!error) {
                self.controller.facebookId = [result objectForKey:@"id"];
            }
        }];
    }
    
    NSString *url = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=normal",self.controller.facebookId];
    NSURL *imageURL = [NSURL URLWithString:url];
    NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
    self.photo.image = [UIImage imageWithData:imageData];
    self.photo.frame = CGRectMake(20, 0, 100, 100);
    [self addMaskToBounds:CGRectMake(0, 0, 75, 75)];
}

- (void) addMaskToBounds:(CGRect) maskBounds
{
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    
    CGPathRef maskPath = CGPathCreateWithEllipseInRect(maskBounds, NULL);
    maskLayer.bounds = maskBounds;
    [maskLayer setPath:maskPath];
    [maskLayer setFillColor:[[UIColor blackColor] CGColor]];
    maskLayer.position = CGPointMake(maskBounds.size.width/2, maskBounds.size.height/2);
    
    [self.photo.layer setMask:maskLayer];
}

- (IBAction)showEverythingElse:(id)sender{
    EverythingElseViewController *controller = [EverythingElseViewController controller];    
    [self.controller presentViewController:controller animated:YES completion:nil];
}

@end
