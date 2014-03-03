//
//  FeedFooterView.m
//  TwoByTwo
//
//  Created by John Tubert on 1/27/14.
//  Copyright (c) 2014 Joseph Lin. All rights reserved.
//

#import "FeedFooterView.h"

@interface FeedFooterView ()
@property (nonatomic, weak) IBOutlet UILabel *textLabel;
@end


@implementation FeedFooterView

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.textLabel.font = [UIFont appMediumFontOfSize:14];
}


- (void)setType:(FeedType)type
{
    _type = type;
    
    
    switch (type) {
            
        case FeedTypeYou:
            if(!self.showingDouble){
                self.textLabel.text = @"Not much going on here yet. Take a photo by tapping below.";
            }else{
                self.textLabel.text = @"Not much going on here yet. Go to any single exposed photo and tap on it to create a double exposure";
            }
            break;
        case FeedTypeFollowing:
            self.textLabel.text = @"Nothing to show here yet, swing by later.";
            break;
        case FeedTypeFriend:
            if(!self.showingDouble){
                self.textLabel.text = @"This person doesn't have any single exposed photos.";
            }else{
                self.textLabel.text = @"This person doesn't have any double exposed photos.";
            }
            break;
        case FeedTypeSingle:
            self.textLabel.text = @"Single exposed photos ran out, swing by later.";
            break;
        case FeedTypeGlobal:
            self.textLabel.text = @"Nothing to show here yet, swing by later.";
            break;
        default:
            self.textLabel.text = @"";
            break;
    }
}



@end
