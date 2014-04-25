//
//  FeedTitleHeaderView.m
//  TwoByTwo
//
//  Created by Joseph Lin on 1/18/14.
//  Copyright (c) 2014 Joseph Lin. All rights reserved.
//

#import "FeedHeaderView.h"
#import "UserDefaultsManager.h"

static CGFloat const kHeaderHeightWithMessage = 164.0;
static CGFloat const kHeaderHeightWithoutMessage = 80.0;


@interface FeedHeaderView ()
@property (nonatomic, weak) IBOutlet UIView *messageView;
@property (nonatomic, weak) IBOutlet UILabel *messageLabel;
@property (nonatomic, weak) IBOutlet UIButton *messageCloseButton;
@end


@implementation FeedHeaderView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.titleLabel.font = [UIFont appMediumFontOfSize:14];
    self.messageLabel.font = [UIFont appMediumFontOfSize:13];
    self.exposureLabel.font = [UIFont appMediumFontOfSize:12];
}

#pragma mark - IBActions

- (IBAction)feedToggleButtonTapped:(UIButton *)sender
{
    sender.selected = !sender.selected;
    [self.delegate setShowingFeed:sender.selected];
}

- (IBAction)exposureToggleButtonTapped:(UIButton *)sender
{
    sender.selected = !sender.selected;
    [self.delegate setShowingDouble:sender.selected];
    
    if(!sender.selected){
        self.exposureLabel.text = @"SINGLE EXPOSURE";
    }else{
        self.exposureLabel.text = @"DOUBLE EXPOSURE";
    }
}

- (IBAction)messageCloseButtonTapped:(id)sender
{
    [UserDefaultsManager setHeaderMessageDismissed:YES forType:self.type];
    [self.delegate updateHeaderHeight];
}


#pragma mark - Content

- (void)setType:(FeedType)type
{
    _type = type;
    
    switch (type) {
        case FeedTypeSingle:
            self.titleLabel.text = @"Single Exposure Shots";
            self.messageLabel.text = @"These are single exposed photos waiting before they make it to the public feed. Tap on any of these to etch a second exposure. (This notice will go away upon closing)";
            self.exposureLabel.hidden = YES;
            self.exposureToggleButton.hidden = YES;
            break;
            
        case FeedTypeGlobal:
            self.titleLabel.text = @"Public feed";
            self.messageLabel.text = @"These photos are a combination of friend's photos and the general public. All photos here have been double exposed. (This notice will go away upon closing)";
            self.exposureLabel.hidden = YES;
            self.exposureToggleButton.hidden = YES;
            break;
            
        case FeedTypeFollowing:
            self.titleLabel.text = @"Photos from People you follow";
            self.messageLabel.text = @"Toggle between  single and double exposed photos from people you follow. Tap a single  exposed photo to collaborate. (This notice will go away upon closing)";
            self.exposureLabel.hidden = NO;
            self.exposureToggleButton.hidden = NO;
            break;
            
        case FeedTypeNotifications:
            self.titleLabel.text = @"Notifications";
            self.messageLabel.text = @"All of your activity is collected here to help keep track of who and from where people are interacting with your photos. (This notice will go away upon closing)";
            self.exposureLabel.hidden = YES;
            self.exposureToggleButton.hidden = YES;
            break;
        case FeedTypeHashtag:
            self.titleLabel.text = @"#hashtag";
            //self.messageLabel.text = @"All of your activity is collected here to help keep track of who and from where people are interacting with your photos. (This notice will go away upon closing)";
            self.exposureLabel.hidden = NO;
            self.exposureToggleButton.hidden = NO;
            break;
            
        default:
            self.titleLabel.text = @"";
            self.messageLabel.text = @"";
            self.exposureLabel.hidden = YES;
            self.exposureToggleButton.hidden = YES;
            break;
    }
    
    if(self.title){
        self.titleLabel.text = self.title;
    }
    
    self.titleLabel.text = [self.titleLabel.text uppercaseString];
}


#pragma mark -

+ (CGFloat)headerHeightForType:(FeedType)type
{
    BOOL value = [UserDefaultsManager headerMessageDismissedForType:type];
    if (value) {
        return kHeaderHeightWithoutMessage;
    }
    else {
        return kHeaderHeightWithMessage;
    }
}

@end
