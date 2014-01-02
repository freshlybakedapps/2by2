//
//  AboutViewController.m
//  TwoByTwo
//
//  Created by John Tubert on 11/30/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import "AboutViewController.h"
#import "WebViewController.h"


@interface AboutViewController ()
@end


@implementation AboutViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"About";
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    WebViewController *controller = segue.destinationViewController;
    
    if ([segue.identifier isEqualToString:@"AboutSegue"]) {
        controller.page = @"aboutUs";
        controller.title = @"About Us";
    }
    else if ([segue.identifier isEqualToString:@"TermsSegue"]) {
        controller.page = @"Terms";
        controller.title = @"Terms of Service";
    }
    else if ([segue.identifier isEqualToString:@"ContactSegue"]) {
        controller.page = @"contact";
        controller.title = @"Contact Us";
    }
}


@end
