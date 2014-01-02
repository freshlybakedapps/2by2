//
//  PDPViewController.m
//  TwoByTwo
//
//  Created by John Tubert on 12/17/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import "PDPViewController.h"
#import "GridViewController.h"

@interface PDPViewController ()

@end

@implementation PDPViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"PDPViewController viewDidLoad");
    
	GridViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"GridViewController"];
    controller.type = FeedTypePDP;
    controller.photoID = self.photoID;
    
    //[self.view insertSubview:controller.view atIndex:0];
    
    [self addChildViewController:controller];
    controller.view.frame = self.view.bounds;
    [self.view insertSubview:controller.view atIndex:0];
    [controller didMoveToParentViewController:self];

    
    
    
    self.navigationItem.title = @"Notification";
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
