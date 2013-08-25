//
//  com_jtubertViewController.h
//  MergeImages
//
//  Created by John Tubert on 7/23/13.
//  Copyright (c) 2013 John Tubert. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Camera.h"


@interface ViewController : UIViewController{
    Camera* camera;
}

- (IBAction)takePhoto:(id)sender;
- (IBAction)loadDemoPhoto:(id)sender;

@property (strong, nonatomic) UIImage *image1;
@property (strong, nonatomic) UIImage *image2;
@property (strong, nonatomic) UIImageView* iview;

@end
