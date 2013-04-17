//
//  TACameraVC.h
//  Tourism App
//
//  Created by Richard Lee on 31/08/12.
//  Copyright (c) 2012 C2 Media Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreLocation/CoreLocation.h"
#import "ImageCropper.h"

@class MyCoreLocation;

@interface TACameraVC : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, ImageCropperDelegate> {

	MyCoreLocation *locationManager;
	CLLocation *currentLocation;
    
    UIImagePickerController *cameraUI;
    
    UIView *cameraOverlay;
	
	BOOL selectedPhoto;
	
	BOOL imageURLProcessed;
	NSURL *imageReferenceURL;

	UIImage *photo;
}

@property (nonatomic, retain) MyCoreLocation *locationManager;
@property (nonatomic, retain) CLLocation *currentLocation;

@property (nonatomic, retain) UIImagePickerController *cameraUI;

@property (nonatomic, retain) UIView *cameraOverlay;

@property (nonatomic, retain) NSURL *imageReferenceURL;

@property (nonatomic, retain) UIImage *photo;

- (void)willLogout;

@end
