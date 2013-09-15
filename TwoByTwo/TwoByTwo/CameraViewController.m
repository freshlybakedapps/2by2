//
//  CameraViewController.m
//  TwoByTwo
//
//  Created by Joseph Lin on 9/10/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import "CameraViewController.h"
#import "GPUImage.h"
#import "ProgressButton.h"

typedef NS_ENUM(NSUInteger, CameraViewState) {
    CameraViewStateTakePhoto = 0,
    CameraViewStateReadyToUpload,
    CameraViewStateUploading,
    CameraViewStateDone,
};



@interface CameraViewController ()
@property (nonatomic, weak) IBOutlet GPUImageView *liveView;
@property (nonatomic, weak) IBOutlet UIImageView *previewView;
@property (nonatomic, weak) IBOutlet UIButton *topButton;
@property (nonatomic, weak) IBOutlet ProgressButton *bottomButton;
@property (nonatomic, strong) GPUImageStillCamera *stillCamera;
@property (nonatomic, strong) GPUImageLightenBlendFilter *filter;
@property (nonatomic, strong) GPUImagePicture *sourcePicture;
@property (nonatomic) CameraViewState state;
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

- (void)setState:(CameraViewState)state
{
    _state = state;
    switch (state) {
        case CameraViewStateTakePhoto:
            [self.topButton setImage:[UIImage imageNamed:@"button-close"] forState:UIControlStateNormal];
            [self.bottomButton setImage:[UIImage imageNamed:@"button-shutter-black"] forState:UIControlStateNormal];
            break;
            
        case CameraViewStateReadyToUpload:
            [self.topButton setImage:[UIImage imageNamed:@"button-back"] forState:UIControlStateNormal];
            [self.bottomButton setImage:[UIImage imageNamed:@"button-upload"] forState:UIControlStateNormal];
            break;
            
        case CameraViewStateUploading:
            [self.topButton setImage:[UIImage imageNamed:@"button-back"] forState:UIControlStateNormal];
            [self.bottomButton setImage:nil forState:UIControlStateNormal];
            self.bottomButton.outerColor = [UIColor appBlackishColor];
            self.bottomButton.innerColor = [UIColor appBlackishColor];
            self.bottomButton.trackColor = [UIColor appDarkGrayColor];
            self.bottomButton.progressColor = [UIColor appRedColor];
            break;
            
        case CameraViewStateDone:
            [self.topButton setImage:nil forState:UIControlStateNormal];
            [self.bottomButton setImage:[UIImage imageNamed:@"button-done"] forState:UIControlStateNormal];
            break;
            
        default:
            break;
    }
}

- (IBAction)topButtonTapped:(id)sender
{
    switch (self.state) {
        case CameraViewStateTakePhoto:
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
            
        case CameraViewStateReadyToUpload:
            self.state = CameraViewStateTakePhoto;
            break;
            
        case CameraViewStateUploading:
            self.state = CameraViewStateReadyToUpload;
            break;
            
        case CameraViewStateDone:
        default:
            break;
    }
}

- (IBAction)bottomButtonTapped:(id)sender
{
    switch (self.state) {
        case CameraViewStateTakePhoto:
        {
            self.liveView.hidden = YES;
            self.previewView.hidden = NO;
            self.state = CameraViewStateReadyToUpload;
            [self.stillCamera capturePhotoAsImageProcessedUpToFilter:self.filter withCompletionHandler:^(UIImage *processedImage, NSError *error) {
                self.previewView.image = processedImage;
            }];
        }
            break;
            
        case CameraViewStateReadyToUpload:
            self.state = CameraViewStateUploading;
            break;
            
        case CameraViewStateUploading:
            self.state = CameraViewStateDone;
            break;
            
        case CameraViewStateDone:
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
            
        default:
            break;
    }
}

@end
