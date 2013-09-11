//
//  CameraViewController.m
//  TwoByTwo
//
//  Created by Joseph Lin on 9/10/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import "CameraViewController.h"


@interface CameraViewController ()
@property (nonatomic, weak) IBOutlet UIView *containerView;
@end


@implementation CameraViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (IBAction)closeButtonTapped:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)shutterButtonTapped:(id)sender
{
}

@end
