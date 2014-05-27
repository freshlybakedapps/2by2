//
//  FeedFooterView.m
//  TwoByTwo
//
//  Created by John Tubert on 1/27/14.
//  Copyright (c) 2014 Joseph Lin. All rights reserved.
//

#import "FeedFooterView.h"
#import "MainViewController.h"
#import "InviteManager.h"


@interface FeedFooterView ()
@property (nonatomic, weak) IBOutlet UIButton *inviteFacebookButton;
@property (nonatomic, weak) IBOutlet UIButton *inviteContanctButton;
@end


@implementation FeedFooterView

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.textLabel.font = [UIFont appMediumFontOfSize:14];
    self.inviteFacebookButton.titleLabel.font = [UIFont appMediumFontOfSize:14];
    self.inviteContanctButton.titleLabel.font = [UIFont appMediumFontOfSize:14];
}

- (IBAction)inviteEmailButtonTapped:(id)sender
{
    [[InviteManager sharedInstance] inviteByEmail];
}

- (IBAction)inviteFacebookButtonTapped:(UIButton *)sender
{
    [[InviteManager sharedInstance] inviteByFacebook];
}

@end
