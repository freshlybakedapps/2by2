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
#import "AppDelegate.h"
#import "UIImage+Addon.h"
#import <Social/Social.h>
#import "CustomPickerView.h"

typedef NS_ENUM(NSUInteger, CameraViewState) {
    CameraViewStateTakePhoto = 0,
    CameraViewStateReadyToUpload,
    CameraViewStateUploading,
    CameraViewStateDone,
};

static CGFloat const kImageSize = 320.0;


@interface CameraViewController ()
@property (nonatomic, weak) IBOutlet GPUImageView *liveView;
@property (nonatomic, weak) IBOutlet UIImageView *previewView;
@property (nonatomic, weak) IBOutlet UIButton *topLeftButton;
@property (nonatomic, weak) IBOutlet UIButton *topRightButton;
@property (nonatomic, weak) IBOutlet CustomPickerView *blendModePickerView;
@property (nonatomic, weak) IBOutlet UILabel *blendModeLabel;
@property (nonatomic, weak) IBOutlet ProgressButton *bottomButton;
@property (nonatomic, strong) GPUImageStillCamera *stillCamera;
@property (nonatomic, strong) GPUImageFilter *filter;
@property (nonatomic, strong) GPUImagePicture *sourcePicture;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSArray *blendModes;
@property (nonatomic) CameraViewState state;
@property (nonatomic) UIBackgroundTaskIdentifier fileUploadBackgroundTaskId;
@property (nonatomic) BOOL isPostingToFacebook;
@property (nonatomic) BOOL share;
@end


@implementation CameraViewController

+ (instancetype)controller
{
    CameraViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"CameraViewController"];
    return controller;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.locationManager = [CLLocationManager new];
    [self.locationManager startMonitoringSignificantLocationChanges];
    
    self.state = CameraViewStateTakePhoto;
    self.liveView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    self.blendModeLabel.font = [UIFont appFontOfSize:14];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    if (self.photo) {
        
        self.blendModePickerView.dataSource = self.blendModes;
        self.blendModePickerView.hidden = NO;
        self.blendModeLabel.hidden = NO;

        __weak typeof(self) weakSelf = self;
        void (^showErrorAndDismiss)(NSError *, NSString *) = ^(NSError *error, NSString *message) {
            if (!message) message = error.localizedDescription;
            [UIAlertView bk_showAlertViewWithTitle:@"Error" message:message cancelButtonTitle:@"OK" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                [weakSelf dismissViewControllerAnimated:YES completion:nil];
            }];
        };
        
        // Check again to make sure photo is not "in-use"
        PFQuery *query = [PFQuery queryWithClassName:PFPhotoKey];
        [query includeKey:PFUserInUseKey];
        [query getObjectInBackgroundWithId:weakSelf.photo.objectId block:^(PFObject *photo, NSError *error) {
            if(!error) {
                if ([photo.state isEqualToString:@"half"]) {
                    // Set state to 'in-use'
                    [weakSelf setPhotoState:@"in-use" completion:^(BOOL succeeded, NSError *error) {
                        
                        if (succeeded) {
                            [photo.imageHalf getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                                if (!error) {
                                    weakSelf.filter = [[GPUImageLightenBlendFilter alloc] init];
                                    [weakSelf.filter addTarget:weakSelf.liveView];
                                    
                                    UIImage *image = [UIImage imageWithData:data];
                                    weakSelf.sourcePicture = [[GPUImagePicture alloc] initWithImage:image smoothlyScaleOutput:YES];
                                    [weakSelf.sourcePicture processImage];
                                    [weakSelf.sourcePicture addTarget:weakSelf.filter];
                                    
                                    float ratio = 720.0/1280.0;
                                    GPUImageCropFilter *cropFilter = [[GPUImageCropFilter alloc] initWithCropRegion:CGRectMake(0.0, 0.5 * ratio, 1.0, ratio)];
                                    [cropFilter addTarget:weakSelf.filter];

                                    weakSelf.stillCamera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPreset1280x720 cameraPosition:AVCaptureDevicePositionBack];
                                    weakSelf.stillCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
                                    [weakSelf.stillCamera addTarget:cropFilter];
                                    [weakSelf.stillCamera startCameraCapture];
                                }
                                else {
                                    NSLog(@"get image error: %@", error);
                                    showErrorAndDismiss(error, nil);
                                }
                            }];
                        }
                        else {
                            NSLog(@"set photo state error: %@", error);
                            showErrorAndDismiss(error, nil);
                        }
                    }];
                }
                else {
                    // Photo is already in use
                    NSString *message = [NSString stringWithFormat:@"Sorry but this photo is in use by %@", photo.userInUse.username];
                    showErrorAndDismiss(error, message);
                }
            }
            else {
                NSLog(@"get photo state error: %@", error);
                showErrorAndDismiss(error, nil);
            }
        }];
    }
    else {
        self.blendModePickerView.hidden = YES;
        self.blendModeLabel.hidden = YES;
        
        self.filter = [[GPUImageGammaFilter alloc] init];
        [self.filter addTarget:self.liveView];
        
        self.stillCamera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPresetPhoto cameraPosition:AVCaptureDevicePositionBack];
        self.stillCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
        [self.stillCamera addTarget:self.filter];
        [self.stillCamera startCameraCapture];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.filter = nil;
    self.sourcePicture = nil;
    self.stillCamera = nil;
    self.photo = nil;
    [self.locationManager stopMonitoringSignificantLocationChanges];
    [super viewWillDisappear:animated];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


#pragma mark - Debug

- (NSString *)randomTestPhoto
{
    NSArray *arr = @[[NSString stringWithFormat:@"http://lorempixel.com/300/300/sports/%u/",arc4random_uniform(10)],
                     [NSString stringWithFormat:@"http://lorempixel.com/300/300/animals/%u/",arc4random_uniform(10)],
                     [NSString stringWithFormat:@"http://lorempixel.com/300/300/business/%u/",arc4random_uniform(10)],
                     [NSString stringWithFormat:@"http://lorempixel.com/300/300/cats/%u/",arc4random_uniform(10)],
                     [NSString stringWithFormat:@"http://lorempixel.com/300/300/city/%u/",arc4random_uniform(10)],
                     [NSString stringWithFormat:@"http://lorempixel.com/300/300/food/%u/",arc4random_uniform(10)],
                     [NSString stringWithFormat:@"http://lorempixel.com/300/300/nightlife/%u/",arc4random_uniform(10)],
                     [NSString stringWithFormat:@"http://lorempixel.com/300/300/fashion/%u/",arc4random_uniform(10)],
                     [NSString stringWithFormat:@"http://lorempixel.com/300/300/people/%u/",arc4random_uniform(10)],
                     [NSString stringWithFormat:@"http://lorempixel.com/300/300/nature/%u/",arc4random_uniform(10)],
                     [NSString stringWithFormat:@"http://lorempixel.com/300/300/technics/%u/",arc4random_uniform(10)],
                     [NSString stringWithFormat:@"http://lorempixel.com/300/300/transport/%u/",arc4random_uniform(10)],
                     [NSString stringWithFormat:@"http://lorempixel.com/300/300/abstract/%u/",arc4random_uniform(10)]];
    int r = arc4random_uniform(arr.count - 1);
    return arr[r];
}


#pragma mark - State

- (void)setState:(CameraViewState)state
{
    _state = state;
    self.topRightButton.selected = NO;

    switch (state) {
        case CameraViewStateTakePhoto:
            self.liveView.hidden = NO;
            self.previewView.hidden = YES;
            self.topLeftButton.hidden = NO;
            self.topRightButton.hidden = NO;
            [self.topLeftButton setImage:[UIImage imageNamed:@"button-close"] forState:UIControlStateNormal];
            [self.topRightButton setImage:[UIImage imageNamed:@"selfie"] forState:UIControlStateNormal];
            [self.bottomButton setImage:[UIImage imageNamed:@"button-shutter-black"] forState:UIControlStateNormal];
            self.blendModePickerView.alpha = self.blendModeLabel.alpha = 1.0;
            self.blendModePickerView.userInteractionEnabled = YES;
            break;
            
        case CameraViewStateReadyToUpload:
            self.liveView.hidden = YES;
            self.previewView.hidden = NO;
            self.topLeftButton.hidden = NO;
            self.topRightButton.hidden = NO;
            [self.topLeftButton setImage:[UIImage imageNamed:@"button-back"] forState:UIControlStateNormal];
            [self.topRightButton setImage:[UIImage imageNamed:@"button-facebook-off"] forState:UIControlStateNormal];
            [self.topRightButton setImage:[UIImage imageNamed:@"button-facebook-on"] forState:UIControlStateSelected];
            [self.bottomButton setImage:[UIImage imageNamed:@"button-upload"] forState:UIControlStateNormal];
            self.blendModePickerView.alpha = self.blendModeLabel.alpha = 0.5;
            self.blendModePickerView.userInteractionEnabled = NO;
            break;
            
        case CameraViewStateUploading:
            self.liveView.hidden = YES;
            self.previewView.hidden = NO;
            self.topLeftButton.hidden = YES;
            self.topRightButton.hidden = YES;
            [self.bottomButton setImage:nil forState:UIControlStateNormal];
            self.bottomButton.outerColor = [UIColor appBlackishColor];
            self.bottomButton.innerColor = [UIColor appBlackishColor];
            self.bottomButton.trackColor = [UIColor appDarkGrayColor];
            self.bottomButton.progressColor = [UIColor appRedColor];
            self.bottomButton.trackInset = 4.0;
            self.bottomButton.trackWidth = 2.0;
            self.bottomButton.progress = 0.0;
            self.blendModePickerView.alpha = self.blendModeLabel.alpha = 0.5;
            self.blendModePickerView.userInteractionEnabled = NO;
            break;
            
        case CameraViewStateDone:
            self.liveView.hidden = YES;
            self.previewView.hidden = NO;
            self.topLeftButton.hidden = YES;
            self.topRightButton.hidden = YES;
            [self.bottomButton setImage:[UIImage imageNamed:@"button-done"] forState:UIControlStateNormal];
            self.blendModePickerView.alpha = self.blendModeLabel.alpha = 0.5;
            self.blendModePickerView.userInteractionEnabled = NO;
            break;
            
        default:
            break;
    }
}


#pragma mark - Actions

- (IBAction)topLeftButtonTapped:(id)sender
{
    __weak typeof(self) weakSelf = self;
    switch (self.state) {
        case CameraViewStateTakePhoto:
        {
            [self setPhotoState:@"half" completion:^(BOOL succeeded, NSError *error) {
                if (!succeeded) {
                    NSLog(@"CameraViewStateTakePhoto setPhotoState: %@", error);
                }
                [weakSelf dismissViewControllerAnimated:YES completion:nil];
            }];
        }
            break;
            
        case CameraViewStateReadyToUpload:
            self.state = CameraViewStateTakePhoto;
            break;
            
        default:
            break;
    }
}

- (IBAction)topRightButtonTapped:(id)sender
{
    switch (self.state) {
        case CameraViewStateTakePhoto:
            [self.stillCamera rotateCamera];
            break;
            
        case CameraViewStateReadyToUpload:
            if(self.topRightButton.selected){
                self.topRightButton.selected = NO;
                self.share = NO;
            }else{
                self.topRightButton.selected = YES;
                self.share = YES;
            }
            break;
            
        default:
            break;
    }
}

- (IBAction)bottomButtonTapped:(id)sender
{
    __weak typeof(self) weakSelf = self;

    switch (self.state) {
        case CameraViewStateTakePhoto:
        {
#if TARGET_IPHONE_SIMULATOR
            NSString *URLString = [self randomTestPhoto];
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:URLString]]];
            self.previewView.image = image;
            self.state = CameraViewStateReadyToUpload;
#else
            [self.stillCamera capturePhotoAsImageProcessedUpToFilter:self.filter withCompletionHandler:^(UIImage *processedImage, NSError *error) {
                UIImage* image = [processedImage scaleToSize:CGSizeMake(kImageSize, kImageSize) contentMode:UIViewContentModeScaleAspectFill interpolationQuality:kCGInterpolationHigh];
                weakSelf.previewView.image = image;
                weakSelf.state = CameraViewStateReadyToUpload;
            }];
#endif
        }
        break;
            
        case CameraViewStateReadyToUpload:
        {
            self.state = CameraViewStateUploading;
            [self uploadImage:self.previewView.image progress:^(int percentDone) {
                weakSelf.bottomButton.progress = (float)percentDone / 100;
            } completion:^(BOOL succeeded, NSError *error) {
                
                weakSelf.state = CameraViewStateDone;
                
                // Dismiss automatically after 0.5 second
                double delayInSeconds = 0.5;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [weakSelf dismissViewControllerAnimated:YES completion:^{
                    }];
                });
                
                
                if (weakSelf.share == YES) {
                    [weakSelf sharePhotoToFacebook];
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadImagesTable" object:nil];

                NSString *locationFull = [NSString stringWithFormat:@"%f,%f", weakSelf.photo.locationFull.latitude, weakSelf.photo.locationFull.longitude];
                NSString *locationHalf = [NSString stringWithFormat:@"%f,%f", weakSelf.photo.locationHalf.latitude, weakSelf.photo.locationHalf.longitude];
                if (weakSelf.photo) {
                    [PFCloud callFunctionInBackground:@"notifyUser"
                                       withParameters:@{@"photoID":weakSelf.photo.objectId,
                                                        @"user_full_username":weakSelf.photo.userFull.username,
                                                        @"user_full_id":weakSelf.photo.userFull.objectId,
                                                        @"userID":weakSelf.photo.user.objectId,
                                                        @"url":weakSelf.photo.imageFull.url,
                                                        @"locationFull":locationFull,
                                                        @"location":locationHalf}
                                                block:^(NSNumber *result, NSError *error) {
                                                    if (!error) {
                                                        NSLog(@"notifyUser sucessed: %@", result);
                                                        
                                                    }
                                                    else {
                                                        NSLog(@"notifyUser error: %@", error);
                                                    }
                                                }];
                    
                }
                else {
                    [PFCloud callFunctionInBackground:@"newPhotoWasPosted"
                                       withParameters:@{@"username":[PFUser currentUser].username,
                                                        @"userID":[PFUser currentUser].objectId}
                                                block:^(NSNumber *result, NSError *error) {
                                                    if (!error) {
                                                        NSLog(@"newPhotoWasPosted sucessed: %@", result);
                                                        
                                                    }else{
                                                        NSLog(@"newPhotoWasPosted error: %@", error);
                                                    }
                                                }];
                    
                }
            }];
        }
            break;
            
        default:
            break;
    }
}


#pragma mark - Blend Mode

- (NSArray *)blendModes
{
    if (!_blendModes) {
        _blendModes = @[
                        [GPUImageLightenBlendFilter class],
                        [GPUImageDarkenBlendFilter class],
                        [GPUImageColorDodgeBlendFilter class],
                        [GPUImageColorBurnBlendFilter class],
                        [GPUImageSoftLightBlendFilter class],
                        [GPUImageHardLightBlendFilter class],
                        [GPUImageAddBlendFilter class],
                        [GPUImageSubtractBlendFilter class],
                        [GPUImageDivideBlendFilter class],
                        [GPUImageAlphaBlendFilter class],
                        [GPUImageLinearBurnBlendFilter class],
                        [GPUImageMultiplyBlendFilter class],
                        [GPUImageScreenBlendFilter class],
                        [GPUImageOverlayBlendFilter class],
                        ];
    }
    return _blendModes;
}

- (NSString *)blendModeName
{
    Class mode = self.blendModes[self.blendModePickerView.currentItem];
    NSString *name = NSStringFromClass(mode);
    name = [name stringByReplacingOccurrencesOfString:@"GPUImage" withString:@""];
    name = [name stringByReplacingOccurrencesOfString:@"BlendFilter" withString:@""];
    return name;
}

- (void)pickerView:(CustomPickerView *)pickerView didSelectItem:(NSInteger)item
{
    self.blendModeLabel.text = self.blendModeName;
    
    [self.filter removeTarget:self.liveView];
    [self.sourcePicture removeTarget:self.filter];
    [self.stillCamera removeTarget:self.filter];
    
    Class mode = self.blendModes[item];
    self.filter = [[mode alloc] init];
    [self.filter addTarget:self.liveView];
    [self.sourcePicture addTarget:self.filter];
    [self.stillCamera addTarget:self.filter];
}


#pragma mark - API

- (void)setPhotoState:(NSString *)state completion:(PFBooleanResultBlock)completion
{
    if (self.photo) {
        self.photo.state = state;
        self.photo.userInUse = [PFUser currentUser];
        [self.photo saveInBackgroundWithBlock:completion];
    }
    else {
        completion(NO, nil);
    }
}

- (void)uploadImage:(UIImage *)image progress:(PFProgressBlock)progress completion:(PFBooleanResultBlock)completion
{
    __weak typeof(self) weakSelf = self;

    if (![PFUser currentUser]) {
        completion(NO, nil);
    }
    
    NSData *imageData = UIImageJPEGRepresentation(image, 0.8);
    if (!imageData) {
        completion(NO, nil);
    }
    

    // Request a background execution task to allow us to finish uploading the photo even if the app is backgrounded
    self.fileUploadBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
        weakSelf.fileUploadBackgroundTaskId = UIBackgroundTaskInvalid;
    }];
    
    PFFile *photoFile = [PFFile fileWithData:imageData];
    [photoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        PFBooleanResultBlock backgroundTaskCompletion = ^(BOOL succeeded, NSError *error) {
            [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
            weakSelf.fileUploadBackgroundTaskId = UIBackgroundTaskInvalid;
            completion(succeeded, error);
        };

        if (succeeded) {
            CLLocation *location = self.locationManager.location;
            PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude];
            
            if (weakSelf.photo) {
                weakSelf.photo.locationFull = geoPoint;
                weakSelf.photo.imageFull = photoFile;
                weakSelf.photo.userFull = [PFUser currentUser];
                weakSelf.photo.state = @"full";
                weakSelf.photo[@"filter"] = self.blendModeName;
                [weakSelf.photo saveInBackgroundWithBlock:backgroundTaskCompletion];
            }
            else {
                PFObject *photo = [PFObject objectWithClassName:@"Photo"];
                photo.locationHalf = geoPoint;
                photo.imageHalf = photoFile;
                photo.user = [PFUser currentUser];
                photo.state = @"half";
                [photo saveInBackgroundWithBlock:backgroundTaskCompletion];
            }
        }
        else {
            backgroundTaskCompletion(NO, error);
        }
    } progressBlock:progress];
}

- (void)sharePhotoToFacebook
{
    
    if (self.isPostingToFacebook) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    void (^post)(void) = ^{
        weakSelf.isPostingToFacebook = YES;
        
        NSString *message = (weakSelf.photo) ? @"This was made using 2by2" : @"Photo taken with 2by2";
        NSString *watermark = (weakSelf.photo)
        ? [NSString stringWithFormat:@"%@/%@:2BY2", [self.photo.user.username uppercaseString], [[PFUser currentUser].username uppercaseString]]
        : [NSString stringWithFormat:@"%@:2BY2", [[PFUser currentUser].username uppercaseString]];
        UIImage *picture = [weakSelf.previewView.image imageWithWatermark:watermark];
        
        NSDictionary *params = @{
                                 @"message" : message,
                                 @"picture" : UIImageJPEGRepresentation(picture, 0.8),
                                 };
        [FBRequestConnection startWithGraphPath:@"me/photos"
                                     parameters:params
                                     HTTPMethod:@"POST"
                              completionHandler:^(FBRequestConnection *connection, id result, NSError *error)
         {
             weakSelf.isPostingToFacebook = NO;
             
             if (error) {
                 //showing an alert for failure
                 [[[UIAlertView alloc] initWithTitle:@"Post Failed" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
             }
             else {
                 NSLog(@"facebook post sucessfull %@", result);
             }
         }];
    };
    
    if ([FBSession.activeSession.permissions containsObject:@"publish_actions"]) {
        // No permissions found in session, ask for it
        [FBSession.activeSession requestNewPublishPermissions:@[@"publish_actions"]
                                              defaultAudience:FBSessionDefaultAudienceFriends
                                            completionHandler:^(FBSession *session, NSError *error) {
                                                if (!error) {
                                                    post();
                                                }
                                            }];
    }
    else {
        post();
    }
}

@end
