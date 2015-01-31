//
//  NotificationHeaderView.m
//  TwoByTwo
//
//  Created by Joseph Lin on 5/27/14.
//  Copyright (c) 2014 Joseph Lin. All rights reserved.
//

#import "NotificationHeaderView.h"


@implementation NotificationHeaderView

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.titleLabel.font = [UIFont appMediumFontOfSize:14];
}

@end
