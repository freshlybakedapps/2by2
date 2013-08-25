//
//  com_jtubertViewController.m
//  MergeImages
//
//  Created by John Tubert on 7/23/13.
//  Copyright (c) 2013 John Tubert. All rights reserved.
//

#import "ViewController.h"
#import "UIImage+ResizeAdditions.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize image1,image2, iview;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onImageAdded:) name:@"addImage" object:nil];
    camera = [Camera new];
    [camera setViewController:self];
}

- (IBAction)takePhoto:(id)sender{
    [camera photoCaptureButtonAction:sender];    
    
}

- (IBAction)loadDemoPhoto:(id)sender{
    UIImage* img1 = [UIImage imageNamed:@"DSC_2842.jpg"];
    UIImage* img2 = [UIImage imageNamed:@"DSC_0741.jpg"];    
    UIImage* _img1 =[img1 resizedImage:CGSizeMake(640, 480) interpolationQuality:1.0];
    UIImage* _img2 =[img2 resizedImage:CGSizeMake(640, 480) interpolationQuality:1.0];    
    self.
    iview = [[UIImageView alloc] initWithImage:[self mergeTwoImages:_img1 :_img2]];
    
    self.iview.frame = CGRectMake(0, 50, iview.frame.size.width, iview.frame.size.height);
    [self.view addSubview:iview];
    
    [self.view sendSubviewToBack:self.iview];
}



- (void) onImageAdded:(NSNotification*)notification{
    NSLog(@"onImageAdded %@",self.image1);
    
    if(!self.image1){
        self.image1 = (UIImage*)[notification object];
        [camera photoCaptureButtonAction:nil];
    }else{
        self.image2 = (UIImage*)[notification object];
        self.iview = [[UIImageView alloc] initWithImage:[self mergeTwoImages:self.image1 :self.image2]];
        [self.view addSubview:self.iview];
        
        self.iview.frame = CGRectMake(0, 160, iview.frame.size.width, iview.frame.size.height);
        
        self.image2 = nil;
        self.image1 = nil;
        
        //[self.view sendSubviewToBack:self.iview];

    }
    
    
}

- (UIImage*) mergeTwoImages : (UIImage*) topImage : (UIImage*) bottomImage
{
    
    int width = 320;//bottomImage.size.width/2;
    int height = 320;//bottomImage.size.height/2;
    CGSize newSize = CGSizeMake(width, height);
    //UIGraphicsBeginImageContextWithOptions(newSize, NO, scale);
    UIGraphicsBeginImageContext(newSize);
    
    
    [bottomImage drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    //[topImage drawInRect:CGRectMake(0,0,newSize.width,newSize.height) blendMode:kCGBlendModeLighten alpha:1.0];
    [topImage drawInRect:CGRectMake(0,0,newSize.width,newSize.height) blendMode:kCGBlendModeMultiply alpha:1.0];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
