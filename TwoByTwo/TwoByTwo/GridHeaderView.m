//
//  GridHeaderView.m
//  TwoByTwo
//
//  Created by Joseph Lin on 11/17/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import "GridHeaderView.h"
#import "EverythingElseViewController.h"


@implementation GridHeaderView

- (void)tintColorDidChange
{
    self.textLabel.textColor = self.tintColor;
}

- (IBAction)showEverythingElse:(id)sender{
    EverythingElseViewController *controller = [EverythingElseViewController controller];    
    [self.controller presentViewController:controller animated:YES completion:nil];
}

@end
