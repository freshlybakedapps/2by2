//
//  WebViewController.h
//  TwoByTwo
//
//  Created by John Tubert on 12/2/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic, weak) IBOutlet UIWebView *webview;
@property (nonatomic, weak) NSString* page;

@end
