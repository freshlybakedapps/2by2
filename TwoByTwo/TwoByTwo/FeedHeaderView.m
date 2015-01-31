//
//  FeedTitleHeaderView.m
//  TwoByTwo
//
//  Created by Joseph Lin on 1/18/14.
//  Copyright (c) 2014 Joseph Lin. All rights reserved.
//

#import "FeedHeaderView.h"
#import "UserDefaultsManager.h"


@interface FeedHeaderView ()
@end


@implementation FeedHeaderView

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.titleLabel.font = [UIFont appMediumFontOfSize:14];
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    [self updateTitleLabel];
}

- (void)updateTitleLabel
{
    if (self.exposureToggleButton) {
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@: ", self.title]
                                                                                           attributes:@{
                                                                                                        NSFontAttributeName : self.titleLabel.font,
                                                                                                        NSForegroundColorAttributeName : [UIColor appRedColor],
                                                                                                        }];
        [attributedText appendAttributedString:[[NSAttributedString alloc] initWithString:(self.exposureToggleButton.selected) ? @"SINGLE EXPOSURES" : @"DOUBLE EXPOSURES"
                                                                               attributes:@{
                                                                                            NSFontAttributeName : self.titleLabel.font,
                                                                                            NSForegroundColorAttributeName : [UIColor appGrayColor],
                                                                                            }]];
        self.titleLabel.attributedText = attributedText;
    }
    else {
        self.titleLabel.text = self.title;
    }
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
    [self.delegate setShowingDouble:!sender.selected];
    [self updateTitleLabel];
}

@end
