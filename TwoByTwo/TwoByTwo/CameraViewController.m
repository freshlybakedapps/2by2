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
#import "UIImage+UIImageResizing.h"
#import <Social/Social.h>


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
@property (nonatomic, weak) IBOutlet UIButton *rotateCameraButton;
@property (nonatomic, weak) IBOutlet UIButton *blendModeButton;
@property (nonatomic, weak) IBOutlet UIButton *facebookButton;
@property (nonatomic, weak) IBOutlet ProgressButton *bottomButton;
@property (nonatomic, strong) GPUImageStillCamera *stillCamera;
@property (nonatomic, strong) GPUImageFilter *filter;
@property (nonatomic, strong) GPUImagePicture *sourcePicture;
@property (nonatomic) CameraViewState state;
@property (nonatomic) UIBackgroundTaskIdentifier fileUploadBackgroundTaskId;
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
    self.locationManager.delegate = self;
    [self.locationManager startMonitoringSignificantLocationChanges];
    
    self.state = CameraViewStateTakePhoto;
    
    self.sharingFacebook = NO;
    
    self.liveView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    
    if (self.photo) {
        
        self.blendModeButton.hidden = NO;

        __weak typeof(self) weakSelf = self;
        void (^showErrorAndDismiss)(NSError *, NSString *) = ^(NSError *error, NSString *message) {
            if (!message) message = error.localizedDescription;
            [UIAlertView showAlertViewWithTitle:@"Error" message:message cancelButtonTitle:@"OK" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                [weakSelf cleanup];
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
                                    
                                    weakSelf.stillCamera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPresetPhoto cameraPosition:AVCaptureDevicePositionBack];
                                    weakSelf.stillCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
                                    [weakSelf.stillCamera addTarget:weakSelf.filter];
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
        self.blendModeButton.hidden = YES;
        
        self.filter = [[GPUImageGammaFilter alloc] init];
        [self.filter addTarget:self.liveView];
        
        self.stillCamera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPresetPhoto cameraPosition:AVCaptureDevicePositionBack];
        self.stillCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
        [self.stillCamera addTarget:self.filter];
        [self.stillCamera startCameraCapture];

    }
    
    self.watermark = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
    int x = self.previewView.frame.origin.x + self.previewView.frame.size.width - self.watermark.frame.size.width;
    int y = self.previewView.frame.origin.y + self.previewView.frame.size.height - self.watermark.frame.size.height;
    
    self.watermark.frame = CGRectMake(x, y, self.watermark.frame.size.width, self.watermark.frame.size.height);
    
    self.watermark.hidden = YES;
    
    [self.view addSubview:self.watermark];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


#pragma mark - Location

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    NSLog(@"locationManager: %@", locations);
    //[AppDelegate delegate].currentLocation = locations[0];
    
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"locationManager: %@", error);
}


#pragma mark - State

- (void)setState:(CameraViewState)state
{
    _state = state;
    switch (state) {
        case CameraViewStateTakePhoto:
            self.liveView.hidden = NO;
            self.previewView.hidden = YES;
            self.topButton.hidden = NO;
            self.rotateCameraButton.hidden = NO;
            self.facebookButton.hidden = YES;
            
            [self.topButton setImage:[UIImage imageNamed:@"button-close"] forState:UIControlStateNormal];
            [self.bottomButton setImage:[UIImage imageNamed:@"button-shutter-black"] forState:UIControlStateNormal];
            break;
            
        case CameraViewStateReadyToUpload:
            self.liveView.hidden = YES;
            self.previewView.hidden = NO;
            self.topButton.hidden = NO;
            [self.topButton setImage:[UIImage imageNamed:@"button-back"] forState:UIControlStateNormal];
            [self.bottomButton setImage:[UIImage imageNamed:@"button-upload"] forState:UIControlStateNormal];
            self.rotateCameraButton.hidden = YES;
            self.facebookButton.hidden = NO;
            break;
            
        case CameraViewStateUploading:
            self.liveView.hidden = YES;
            self.previewView.hidden = NO;
            self.topButton.hidden = YES;
            self.rotateCameraButton.hidden = YES;
            self.facebookButton.hidden = NO;
            [self.bottomButton setImage:nil forState:UIControlStateNormal];
            self.bottomButton.outerColor = [UIColor appBlackishColor];
            self.bottomButton.innerColor = [UIColor appBlackishColor];
            self.bottomButton.trackColor = [UIColor appDarkGrayColor];
            self.bottomButton.progressColor = [UIColor appRedColor];
            self.bottomButton.trackInset = 4.0;
            self.bottomButton.trackWidth = 2.0;
            self.bottomButton.progress = 0.0;
            break;
            
        case CameraViewStateDone:
            self.liveView.hidden = YES;
            self.previewView.hidden = NO;
            self.topButton.hidden = YES;
            self.rotateCameraButton.hidden = YES;
            self.facebookButton.hidden = NO;
            [self.bottomButton setImage:[UIImage imageNamed:@"button-done"] forState:UIControlStateNormal];
            break;
            
        default:
            break;
    }
}


#pragma mark - Actions

- (void)ShareFacebook:(BOOL)doubleExposed
{
    
    if ([FBSession.activeSession.permissions indexOfObject:@"publish_actions"] == NSNotFound)
    {
        // No permissions found in session, ask for it
        [FBSession.activeSession requestNewPublishPermissions: [NSArray arrayWithObject:@"publish_actions"]
                                              defaultAudience: FBSessionDefaultAudienceFriends
                                            completionHandler: ^(FBSession *session, NSError *error)
         {
             if (!error)
             {
                 // If permissions granted and not already posting then publish the story
                 if (!self.m_postingInProgress)
                 {
                     [self postToWall:doubleExposed];
                 }
             }
         }];
    }
    else
    {
        // If permissions present and not already posting then publish the story
        if (!self.m_postingInProgress)
        {
            [self postToWall:doubleExposed];
        }
    }
    
}

- (UIImage * ) addWatermark{
    self.watermark.hidden = NO;
    UIGraphicsBeginImageContextWithOptions(self.previewView.bounds.size, YES, 0.0f);
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(c, -self.previewView.frame.origin.x, -self.previewView.frame.origin.y);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    self.watermark.hidden = YES;
    return viewImage;
}

- (void) postToWall:(BOOL)doubleExposed{
    
    self.m_postingInProgress = YES;
    
    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
    
    if(doubleExposed){
        [params setObject:@"Photo was overexposed using new iphone app - 2by2" forKey:@"message"];
    }else{
        [params setObject:@"Photo taken with 2by2" forKey:@"message"];
    }
    
    [params setObject:UIImageJPEGRepresentation([self addWatermark],1) forKey:@"picture"];
    
    
    
    [FBRequestConnection startWithGraphPath:@"me/photos"
                                 parameters:params
                                 HTTPMethod:@"POST"
                          completionHandler:^(FBRequestConnection *connection,
                                              id result,
                                              NSError *error)
     {
         if (error)
         {
             //showing an alert for failure
             UIAlertView *alertView = [[UIAlertView alloc]
                                       initWithTitle:@"Post Failed"
                                       message:error.localizedDescription
                                       delegate:nil
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles:nil];
             [alertView show];
         }else{
             self.m_postingInProgress = NO;
             NSLog(@"facebook post sucessfull %@",result);
         }
         
     }];
    
}

- (IBAction)facebookShare:(id)sender
{
    //NSLog(@"facebookShare");
    if(self.sharingFacebook == NO){
        [self.facebookButton setImage:[UIImage imageNamed:@"facebook_Active"] forState:UIControlStateNormal];
        self.sharingFacebook = YES;
        
    }else{
        [self.facebookButton setImage:[UIImage imageNamed:@"facebook"] forState:UIControlStateNormal];
        self.sharingFacebook = NO;
    }
}

- (IBAction)rotateCamera:(id)sender
{
    [self.stillCamera rotateCamera];
}

- (IBAction)topButtonTapped:(id)sender
{
    switch (self.state) {
        case CameraViewStateTakePhoto:
        {
            __weak typeof(self) weakSelf = self;
            [self setPhotoState:@"half" completion:^(BOOL succeeded, NSError *error) {
                if (!succeeded) {
                    NSLog(@"CameraViewStateTakePhoto setPhotoState: %@", error);
                }
                [weakSelf cleanup];
                [weakSelf dismissViewControllerAnimated:YES completion:nil];
            }];
        }
            break;
            
        case CameraViewStateReadyToUpload:
            NSLog(@"CameraViewStateReadyToUpload");
            self.state = CameraViewStateTakePhoto;
            break;
            
        case CameraViewStateUploading:
        case CameraViewStateDone:
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
            NSString *model = [[UIDevice currentDevice] model];
            if (YES == [model isEqualToString:@"iPhone Simulator"]) {
                //UIImage* smallImage = [UIImage imageNamed:@"logo"];
                NSString* url = @"http://thecatapi.com/api/images/get?format=src&type=png&size=med";
                UIImage *smallImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]];
                self.previewView.image = smallImage;
                self.state = CameraViewStateReadyToUpload;
            }else{
                [self.stillCamera capturePhotoAsImageProcessedUpToFilter:self.filter withCompletionHandler:^(UIImage *processedImage, NSError *error) {
                    UIImage* smallImage = [processedImage scaleToSize:CGSizeMake(300, 300) contentMode:UIViewContentModeScaleAspectFill interpolationQuality:kCGInterpolationHigh];
                    weakSelf.previewView.image = smallImage;
                    weakSelf.state = CameraViewStateReadyToUpload;
                }];
            }
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
                    [weakSelf cleanup];
                    
                    [weakSelf dismissViewControllerAnimated:YES completion:^{
                       //
                    }];
                });
                
                NSString *location = [NSString stringWithFormat:@"%f,%f",weakSelf.photo.locationFull.latitude,weakSelf.photo.locationFull.longitude];
                
                if(weakSelf.sharingFacebook == YES){
                    if(weakSelf.photo){
                        [weakSelf ShareFacebook:YES];
                    }else{
                        [weakSelf ShareFacebook:NO];
                    }
                }
                
                

                
                if(weakSelf.photo){
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadImagesTable" object:nil];
                    
                    @try {
                        [PFCloud callFunctionInBackground:@"notifyUser"
                                           withParameters:@{@"photoID":weakSelf.photo.objectId,@"user_full_username":weakSelf.photo.userFull.username,@"user_full_id":weakSelf.photo.userFull.objectId,@"userID":weakSelf.photo.user.objectId,@"url":weakSelf.photo.imageFull.url,@"locationFull":location}
                                                    block:^(NSNumber *result, NSError *error) {
                                                        if (!error) {
                                                            NSLog(@"The user was notified sucessfully: %@", result);
                                                            
                                                        }else{
                                                            NSLog(@"error: %@", error);
                                                        }
                                                    }];

                    }
                    @catch (NSException *exception) {
                        NSLog(@"notifyUser error: %@",exception.description);
                        [UIAlertView showAlertViewWithTitle:@"Error" message:exception.description cancelButtonTitle:@"OK" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                            
                        }];
                    }
                    
                }
            }];
        }
            break;
            
        case CameraViewStateUploading:
            break;
            
        case CameraViewStateDone:
            [self cleanup];
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
            
        default:
            break;
    }
}

- (IBAction)blendModeButtonTapped:(id)sender
{
    //Refernce:
    // Quartz 2D Programming Guide -> Bitmap Images and Image Masks -> Using Blend Modes with Images
    // https://developer.apple.com/library/ios/documentation/graphicsimaging/conceptual/drawingwithquartz2d/dq_images/dq_images.html
    // https://github.com/BradLarson/GPUImage
    
    NSArray *blendModes = @[
                            [GPUImageMultiplyBlendFilter class],
                            [GPUImageScreenBlendFilter class],
                            [GPUImageOverlayBlendFilter class],
                            [GPUImageLightenBlendFilter class],
                            [GPUImageDarkenBlendFilter class],
                            [GPUImageColorDodgeBlendFilter class],
                            [GPUImageColorBurnBlendFilter class],
                            [GPUImageSoftLightBlendFilter class],
                            [GPUImageHardLightBlendFilter class],
                            [GPUImageDifferenceBlendFilter class],
                            [GPUImageExclusionBlendFilter class],

                            [GPUImageAddBlendFilter class],
                            [GPUImageSubtractBlendFilter class],
                            [GPUImageDivideBlendFilter class],
                            [GPUImageAlphaBlendFilter class],
                            [GPUImageLinearBurnBlendFilter class],
                            ];
    
    NSUInteger current = [blendModes indexOfObject:[self.filter class]];
    NSUInteger next = (current + 1) % blendModes.count;
    Class nextMode = blendModes[next];
    
    NSString *name = NSStringFromClass(nextMode);
    name = [name stringByReplacingOccurrencesOfString:@"GPUImage" withString:@""];
    name = [name stringByReplacingOccurrencesOfString:@"BlendFilter" withString:@""];
    [self.blendModeButton setTitle:name forState:UIControlStateNormal];

    [self.filter removeTarget:self.liveView];
    [self.sourcePicture removeTarget:self.filter];
    [self.stillCamera removeTarget:self.filter];

    self.filter = [[nextMode alloc] init];
    [self.filter addTarget:self.liveView];
    [self.sourcePicture addTarget:self.filter];
    [self.stillCamera addTarget:self.filter];
}


#pragma mark -

- (void)cleanup
{
    self.filter = nil;
    self.sourcePicture = nil;
    self.stillCamera = nil;
    self.photo = nil;
    [self.locationManager stopMonitoringSignificantLocationChanges];
}

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
                
                NSString *name = NSStringFromClass([self.filter class]);
                name = [name stringByReplacingOccurrencesOfString:@"GPUImage" withString:@""];
                name = [name stringByReplacingOccurrencesOfString:@"BlendFilter" withString:@""];
                
                //store the filter we are using
                weakSelf.photo[@"filter"] = name;       
                
                
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

@end
