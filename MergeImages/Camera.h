//
//  Camera.h
//  MotorMouth
//
//  Created by John Tubert on 12/22/12.
//  Copyright (c) 2012 John Tubert. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Camera : NSObject <UIActionSheetDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate>{
    UIViewController* vc;
}

- (void) setViewController:(UIViewController*) _vc;
- (void)photoCaptureButtonAction:(id)sender;

@end
