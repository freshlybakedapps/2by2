//
//  MainViewController.m
//  TwoByTwo
//
//  Created by Joseph Lin on 9/10/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import "MainViewController.h"


@interface MainViewController ()

@end


@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (IBAction)segmentedControlValueChanged:(UISegmentedControl *)sender
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"segmentChanged" object:@(sender.selectedSegmentIndex)];
}

@end
