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
@end


@implementation GridTitleHeaderView

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.textLabel.font = [UIFont appMediumFontOfSize:14];
}

- (void)setType:(FeedType)type
{
    _type = type;
    
    switch (type) {
        case FeedTypeSingle:
            self.textLabel.text = @"Single Exposure Shots";
            break;
            
        case FeedTypeGlobal:
            self.textLabel.text = @"Public feed";
            break;
            
        case FeedTypeFollowing:
            self.textLabel.text = @"Photos from People you follow";
            break;
            
        case FeedTypeNotifications:
            self.textLabel.text = @"Notifications";
            break;
            
        default:
            self.textLabel.text = @"";
            break;
    }
    
    self.textLabel.text = [self.textLabel.text uppercaseString];
}

@end
