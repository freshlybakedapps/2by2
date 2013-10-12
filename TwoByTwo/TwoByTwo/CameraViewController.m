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
#import "DataManager.h"


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
@property (nonatomic, strong) GPUImageFilter *filter;
@property (nonatomic, strong) GPUImagePicture *sourcePicture;
@property (nonatomic) CameraViewState state;
@property (nonatomic, assign) UIBackgroundTaskIdentifier fileUploadBackgroundTaskId;
@end


@implementation CameraViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.state = CameraViewStateTakePhoto;
    
    self.liveView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    
    if (self.photo) {
        self.filter = [[GPUImageLightenBlendFilter alloc] init];
        [self.filter addTarget:self.liveView];
        
        UIImage *image = [UIImage imageWithContentsOfFile:self.photo.photoPath];
        self.sourcePicture = [[GPUImagePicture alloc] initWithImage:image smoothlyScaleOutput:YES];
        [self.sourcePicture processImage];
        [self.sourcePicture addTarget:self.filter];
        
    }
    else {
        self.filter = [[GPUImageGammaFilter alloc] init];
        [self.filter addTarget:self.liveView];
    }
    
    self.stillCamera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPresetPhoto cameraPosition:AVCaptureDevicePositionBack];
    self.stillCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    [self.stillCamera addTarget:self.filter];
    [self.stillCamera startCameraCapture];

}


#pragma mark -

- (void)setState:(CameraViewState)state
{
    _state = state;
    switch (state) {
        case CameraViewStateTakePhoto:
            self.liveView.hidden = NO;
            self.previewView.hidden = YES;
            [self.topButton setImage:[UIImage imageNamed:@"button-close"] forState:UIControlStateNormal];
            [self.bottomButton setImage:[UIImage imageNamed:@"button-shutter-black"] forState:UIControlStateNormal];
            break;
            
        case CameraViewStateReadyToUpload:
            self.liveView.hidden = YES;
            self.previewView.hidden = NO;
            [self.topButton setImage:[UIImage imageNamed:@"button-back"] forState:UIControlStateNormal];
            [self.bottomButton setImage:[UIImage imageNamed:@"button-upload"] forState:UIControlStateNormal];
            break;
            
        case CameraViewStateUploading:
            self.liveView.hidden = YES;
            self.previewView.hidden = NO;
            [self.topButton setImage:[UIImage imageNamed:@"button-back"] forState:UIControlStateNormal];
            [self.bottomButton setImage:nil forState:UIControlStateNormal];
            self.bottomButton.outerColor = [UIColor appBlackishColor];
            self.bottomButton.innerColor = [UIColor appBlackishColor];
            self.bottomButton.trackColor = [UIColor appDarkGrayColor];
            self.bottomButton.progressColor = [UIColor appRedColor];
            self.bottomButton.trackInset = 4.0;
            self.bottomButton.trackWidth = 2.0;
            self.bottomButton.progress = 0.3;
            break;
            
        case CameraViewStateDone:
            self.liveView.hidden = YES;
            self.previewView.hidden = NO;
            [self.topButton setImage:nil forState:UIControlStateNormal];
            [self.bottomButton setImage:[UIImage imageNamed:@"button-done"] forState:UIControlStateNormal];
            break;
            
        default:
            break;
    }
}


#pragma mark -

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
            self.state = CameraViewStateReadyToUpload;
            [self.stillCamera capturePhotoAsImageProcessedUpToFilter:self.filter withCompletionHandler:^(UIImage *processedImage, NSError *error) {
                self.previewView.image = processedImage;
            }];
        }
            break;
            
        case CameraViewStateReadyToUpload:
        {
            self.state = CameraViewStateUploading;
            
            NSNumber *identifier = @((int)[NSDate timeIntervalSinceReferenceDate]);
            
            NSData *data = UIImageJPEGRepresentation(self.previewView.image, 0.8);
            
            NSString *path = [[DataManager documentsDirectory] path];
            NSString *filename = [NSString stringWithFormat:@"%@.jpg", identifier];
            path = [path stringByAppendingPathComponent:filename];
            
            NSError *error = nil;
            if (![data writeToFile:path options:0 error:nil]) {
                NSLog(@"error: %@", error);
            }
            Photo *photo = [Photo insertObjectInContext:[DataManager sharedInstance].mainContext];
            photo.identifier = identifier;
            photo.photoPath = path;
            [[DataManager sharedInstance] save];
            
            //jt
            [self shouldUploadImage:self.previewView.image];
            
            double delayInSeconds = 1.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                self.state = CameraViewStateDone;
            });
        }
            break;
            
        case CameraViewStateUploading:
            break;
            
        case CameraViewStateDone:
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
            
        default:
            break;
    }
}

- (BOOL)shouldUploadImage:(UIImage *)anImage {
    if (![PFUser currentUser]) {
        return NO;
    }
    
    // JPEG to decrease file size and enable faster uploads & downloads
    NSData *imageData = UIImageJPEGRepresentation(anImage, 0.8f);
    
    if (!imageData) {
        return NO;
    }
    
    PFFile* photoFile = [PFFile fileWithData:imageData];
    
    
    
    // Request a background execution task to allow us to finish uploading the photo even if the app is backgrounded
    self.fileUploadBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
    }];
    
    //NSLog(@"Requested background expiration task with id %d for Sketchio photo upload", self.fileUploadBackgroundTaskId);
    [photoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Photo uploaded successfully");
            [self performSelector:@selector(saveSuccessfully) withObject:nil afterDelay:1];
        } else {
            [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
        }
    }];
    
    
    // create a photo object
    PFObject *photo = [PFObject objectWithClassName:@"Photo"];
    [photo setObject:[PFUser currentUser] forKey:@"user"];
    [photo setObject:photoFile forKey:@"image"];
    
    
    
    // photos are public, but may only be modified by the user who uploaded them
    PFACL *photoACL = [PFACL ACLWithUser:[PFUser currentUser]];
    [photoACL setPublicReadAccess:YES];
    photo.ACL = photoACL;
    
    [photo saveInBackground];
    
    
    return YES;
}

- (void) saveSuccessfully{
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Saved successfully!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}



@end
