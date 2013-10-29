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

-(IBAction)changeSeg{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"segmentChanged" object:Segment];    
}

@end
