//
//  CameraViewController.m
//  TwoByTwo
//
//  Created by Joseph Lin on 9/10/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import "CameraViewController.h"
#import "GPUImage.h"


@interface CameraViewController ()
@property (nonatomic, weak) IBOutlet GPUImageView *previewView;
@property (nonatomic, strong) GPUImageStillCamera *stillCamera;
@property (nonatomic, strong) GPUImageSepiaFilter *filter;
@end


@implementation CameraViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.previewView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    
    self.filter = [[GPUImageSepiaFilter alloc] init];
    [self.filter addTarget:self.previewView];
    
    self.stillCamera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPresetPhoto cameraPosition:AVCaptureDevicePositionBack];
    self.stillCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    [self.stillCamera addTarget:self.filter];

    [self.stillCamera startCameraCapture];
}

- (IBAction)closeButtonTapped:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)shutterButtonTapped:(id)sender
{
    [self.stillCamera capturePhotoAsImageProcessedUpToFilter:self.filter withCompletionHandler:^(UIImage *processedImage, NSError *error) {
        
    }];    
}

@end
