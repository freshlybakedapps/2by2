//
//  NotificationCell.m
//  TwoByTwo
//
//  Created by John Tubert on 1/13/14.
//  Copyright (c) 2014 Joseph Lin. All rights reserved.
//

#import "NotificationCell.h"
#import "UIImageView+AFNetworking.h"
#import "NSDate+Addon.h"


@interface NotificationCell ()
@property (nonatomic, weak) IBOutlet UIImageView *avatarImageView;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet UILabel *notificationLabel;
@end

/*
//NOTIFICATION TYPES
// - comment (x)
// - overexposed (x)
// - follow (x)
// - like (x)
// - newUser
// - flag (x)
// - newPhoto

//NOTIFICATON PROPERTIES
// - notificationID (same as user ID)
// - photoID
// - facebookID
// - notificationType
// - byUserID
// - byUsername
// - content
// - locationString
*/

@implementation NotificationCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.avatarImageView.layer.cornerRadius = CGRectGetHeight(self.avatarImageView.frame) * 0.5;
    self.notificationLabel.font = [UIFont appFontOfSize:16];
    self.dateLabel.font = [UIFont appLightFontOfSize:12];
}

- (void)setNotification:(PFObject *)notification
{
    _notification = notification;
    
    NSURL *URL;
    if (notification[@"facebookID"]) {
        URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=normal", notification[@"facebookID"]]];
    }
    
    if ([notification[@"notificationType"] isEqualToString:@"flag"]) {
        [self.avatarImageView setImageWithURL:URL placeholderImage:[UIImage imageNamed:@"flagForNotification"]];
        NSString *flagType = notification[@"content"];
        flagType = [flagType stringByReplacingOccurrencesOfString:@"FlagType" withString:@""];
        self.notificationLabel.text = [NSString stringWithFormat:@"Your photo was flagged as %@", [flagType lowercaseString]];
    }
    else {
        [self.avatarImageView setImageWithURL:URL placeholderImage:[UIImage imageNamed:@"defaultUserImage"]];
        self.notificationLabel.text = notification[@"content" ];
    }
    
    self.dateLabel.text = [notification.createdAt timeAgoString];    
}

@end
