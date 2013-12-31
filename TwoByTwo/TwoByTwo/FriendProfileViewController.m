//
//  FriendProfileViewController.m
//  TwoByTwo
//
//  Created by John Tubert on 12/11/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import "FriendProfileViewController.h"
#import "GridViewController.h"
#import "MainViewController.h"

@interface FriendProfileViewController ()

@end

@implementation FriendProfileViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	
    GridViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"GridViewController"];
    controller.type = FeedTypeFriend;
    controller.user = self.friend;
    //[self.view insertSubview:controller.view atIndex:0];
    
    [self addChildViewController:controller];
    controller.view.frame = self.view.bounds;
    [self.view insertSubview:controller.view atIndex:0];
    [controller didMoveToParentViewController:self];
    
    
    
    self.navigationItem.title = [NSString stringWithFormat:@"%@'s Profile",self.friendName];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close"
                                                                             style:UIBarButtonItemStyleBordered
                                                                            target:self
                                                                            action:@selector(close:)];
}

-(void)close:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{ NSLog(@"controller dismissed"); }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
