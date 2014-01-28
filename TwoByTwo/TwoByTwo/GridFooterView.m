//
//  GridFooterView.m
//  TwoByTwo
//
//  Created by John Tubert on 1/27/14.
//  Copyright (c) 2014 Joseph Lin. All rights reserved.
//

#import "GridFooterView.h"

@interface GridFooterView ()
@property (nonatomic, weak) IBOutlet UILabel *textLabel;
@end


@implementation GridFooterView

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.textLabel.font = [UIFont appMediumFontOfSize:14];
}

- (void)setCount:(int)count{
    if(count > 0){
        self.textLabel.text = @"";
    }else{
        self.textLabel.text = @"Not much going on here. Take your first photo by tapping below.";
    }
}

/*
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
}
*/


@end
