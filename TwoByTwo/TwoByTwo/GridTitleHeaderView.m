//
//  GridTitleHeaderView.m
//  TwoByTwo
//
//  Created by Joseph Lin on 1/18/14.
//  Copyright (c) 2014 Joseph Lin. All rights reserved.
//

#import "GridTitleHeaderView.h"


@interface GridTitleHeaderView ()
@property (nonatomic, weak) IBOutlet UILabel *textLabel;
@property (nonatomic, weak) IBOutlet UILabel *messageLabel;
@property (nonatomic, weak) IBOutlet UIButton *closeButton;
@property (nonatomic, weak) IBOutlet UIView *messageHolder;



@end


@implementation GridTitleHeaderView

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.textLabel.font = [UIFont appMediumFontOfSize:14];
}

- (IBAction)closeButtonTapped:(id)sender{
    NSString* keyStoreValue = [NSString stringWithFormat:@"messageWasSeen_%lu",(unsigned long)self.type];
    [[NSUbiquitousKeyValueStore defaultStore] setString:@"YES" forKey:keyStoreValue];
     [[NSUbiquitousKeyValueStore defaultStore] synchronize];
    
    
    [self.controller.collectionView performBatchUpdates:^{
        [UIView animateWithDuration:0.5f animations:^{
            self.messageHolder.frame = CGRectMake(self.messageHolder.frame.origin.x, self.messageHolder.frame.origin.y, self.bounds.size.width, 0);
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.bounds.size.width, 36.0);
            self.controller.headerSize = 36;
        }completion:^(BOOL finished) {
            NSLog(@"Animation is complete");
        }];
    } completion:nil];
}

- (void)setType:(FeedType)type
{
    _type = type;
    
    
    switch (type) {
        case FeedTypeSingle:
            self.textLabel.text = @"Single Exposure Shots";
            //self.messageLabel.text = @"These are your photos, both single shots and double exposed shots. (This notice will go away upon closing)";
            self.messageLabel.text = @"These are single exposed photos waiting before they make it to the public feed. Tap on any of these to etch a second exposure. (This notice will go away upon closing)";
            break;
            
        case FeedTypeGlobal:
            self.textLabel.text = @"Public feed";
            self.messageLabel.text = @"These photos are a combination of friend's photos and the general public. All photos here have been double exposed. (This notice will go away upon closing)";
            break;
            
        case FeedTypeFollowing:
            self.textLabel.text = @"Photos from People you follow";
            self.messageLabel.text = @"Toggle between  single and double exposed photos from people you follow. Tap a single  exposed photo to collaborate. (This notice will go away upon closing)";
            break;
            
        case FeedTypeNotifications:
            self.textLabel.text = @"Notifications";
            self.messageLabel.text = @"All of your activity is collected here to help keep track of who and from where people are interacting with your photos. (This notice will go away upon closing)";
            break;
            
        default:
            self.textLabel.text = @"";
            self.messageLabel.text = @"";
            break;
    }
    
    self.textLabel.text = [self.textLabel.text uppercaseString];
}

@end
