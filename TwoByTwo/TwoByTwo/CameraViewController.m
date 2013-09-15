//
//  CameraViewController.m
//  TwoByTwo
//
//  Created by Joseph Lin on 9/10/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import "CameraViewController.h"
#import <AVFoundation/AVFoundation.h>


@interface CameraViewController ()
@property (nonatomic, weak) IBOutlet UIView *previewView;
@end


@implementation CameraViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    NSError *error = nil;
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    
    AVCaptureStillImageOutput *output = [[AVCaptureStillImageOutput alloc] init];
    output.outputSettings = @{AVVideoCodecKey:AVVideoCodecJPEG};

    
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    [session beginConfiguration];
    session.sessionPreset = AVCaptureSessionPresetPhoto;
    [session addInput:input];
    [session addOutput:output];
    [session commitConfiguration];


    AVCaptureVideoPreviewLayer *previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:session];
    previewLayer.frame = self.previewView.bounds;
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.previewView.layer addSublayer:previewLayer];

    [session startRunning];
}

- (IBAction)closeButtonTapped:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)shutterButtonTapped:(id)sender
{
}

@end
