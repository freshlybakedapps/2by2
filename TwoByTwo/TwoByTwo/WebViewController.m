//
//  WebViewController.m
//  TwoByTwo
//
//  Created by John Tubert on 12/2/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import "WebViewController.h"


@interface WebViewController ()
@property (nonatomic, weak) IBOutlet UIWebView *webview;
@end


@implementation WebViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[UINavigationBar appearance] setTitleTextAttributes:@{
                                                           NSForegroundColorAttributeName:[UIColor appGrayColor],
                                                           NSFontAttributeName:[UIFont appMediumFontOfSize:14],
                                                           }];

    
    NSString *path = [[NSBundle mainBundle] pathForResource:self.page ofType:@"html"];
    [self.webview loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:path isDirectory:NO]]];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([request.URL.scheme isEqual:@"mailto"]) {
        [[UIApplication sharedApplication] openURL:request.URL];
        return NO;
    }
    return YES;
}

@end
