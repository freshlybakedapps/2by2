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
@property (nonatomic, weak) IBOutlet GPUImageView *liveView;
@property (nonatomic, weak) IBOutlet UIImageView *previewView;
@property (nonatomic, weak) IBOutlet UIButton *topButton;
@property (nonatomic, strong) GPUImageStillCamera *stillCamera;
@property (nonatomic, strong) GPUImageLightenBlendFilter *filter;
@property (nonatomic, strong) GPUImagePicture *sourcePicture;
@end


@implementation CameraViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.liveView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    
    self.filter = [[GPUImageLightenBlendFilter alloc] init];
    [self.filter addTarget:self.liveView];
    
    if (self.sourceImage) {
        self.sourcePicture = [[GPUImagePicture alloc] initWithImage:self.sourceImage smoothlyScaleOutput:YES];
        [self.sourcePicture processImage];
        [self.sourcePicture addTarget:self.filter];
    }
    
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
