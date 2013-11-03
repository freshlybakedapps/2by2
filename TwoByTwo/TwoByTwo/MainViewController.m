//
//  MainViewController.m
//  TwoByTwo
//
//  Created by Joseph Lin on 9/10/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import "MainViewController.h"
#import "FeedViewController.h"
#import "GridViewController.h"


@interface MainViewController ()
@property (nonatomic, strong) UIViewController *childViewController;
@end


@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self showControllerWithType:0];
}

- (IBAction)segmentedControlValueChanged:(UISegmentedControl *)sender
{
    [self showControllerWithType:sender.selectedSegmentIndex];
}

- (void)showControllerWithType:(FeedType)type
{
    if (self.childViewController) {
        [self.childViewController willMoveToParentViewController:nil];
        [self.childViewController.view removeFromSuperview];
        [self.childViewController removeFromParentViewController];
    }
    
    switch (type) {
//        case FeedTypeGlobal:
//        case FeedTypeSingle:
        case FeedTypeYou:
        {
            FeedViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"FeedViewController"];
            controller.currentSection = type;
            self.childViewController = controller;
            break;
        }
        default:
        {
            GridViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"GridViewController"];
            controller.type = type;
            self.childViewController = controller;
            break;
        }
    }
    
    [self addChildViewController:self.childViewController];
    self.childViewController.view.frame = self.view.bounds;
    [self.view insertSubview:self.childViewController.view atIndex:0];
    [self.childViewController didMoveToParentViewController:self];
}

@end
