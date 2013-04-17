//
//  TACameraVC.m
//  Tourism App
//
//  Created by Richard Lee on 31/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TACameraVC.h"
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <ImageIO/ImageIO.h>
#import "TAShareVC.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "MyCoreLocation.h"
#import "CustomTabBarItem.h"
#import "CameraOverlayVC.h"
#import "AppDelegate.h"
#import "UIImage+fixOrientation.h"
#import "ImageCropper.h"
#import "UIImage+Resize.h"
#import "SVProgressHUD.h"
#import "NSMutableDictionary+ImageMetadata.h"

@interface TACameraVC ()

@end

@implementation TACameraVC

@synthesize photo, imageReferenceURL, cameraOverlay, cameraUI;
@synthesize locationManager, currentLocation;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	
    if (self) {
		
		CustomTabBarItem *tabItem = [[CustomTabBarItem alloc] initWithTitle:@"" image:nil tag:0];
        
        tabItem.customHighlightedImage = [UIImage imageNamed:@"share_tab_button-on.png"];
        tabItem.customStdImage = [UIImage imageNamed:@"share_tab_button.png"];
		tabItem.imageInsets = UIEdgeInsetsMake(6.0, 0.0, -6.0, 0.0);
		
        self.tabBarItem = tabItem;
        tabItem = nil;
    }
    return self;
}

- (void)viewDidLoad {
	
    [super viewDidLoad];
	
	// Setup nav bar
	[self initNavBar];
    
	// Get user location
	MyCoreLocation *location = [[MyCoreLocation alloc] init];
	self.locationManager = location;
	
	// We are the delegate for the MyCoreLocation object
	[self.locationManager setCaller:self];
}

- (void)viewDidUnload {
	
	self.currentLocation = nil;
	self.locationManager = nil;
	self.imageReferenceURL = nil;
    
    self.cameraUI = nil;
    
    self.cameraOverlay = nil;
	
    self.photo = nil;
	
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



- (void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];
    
	// Start the location managing - tell it to start updating,
	// if it's not already doing so
	[self startLocationManager:nil];
    
    [self showCameraUI:nil];
}

- (void)viewDidDisappear:(BOOL)animated {

    [super viewDidDisappear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {

    [super viewWillDisappear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
#pragma TODO: update to take the user to Settings app if possible
    
    /*
    if (buttonIndex == 1) {
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=WIFI"]];
    }*/
}


#pragma ImageCropperDelegate methods

- (void)imageCropper:(ImageCropper *)cropper didFinishCroppingWithImage:(UIImage *)image {
    
	self.photo = image; 
    BOOL approved = [self newPhotoApproved:nil];
    
    if (approved) {
     
        [self dismissModalViewControllerAnimated:NO];
  
#warning TO DO
//        NSMutableDictionary *metadata = [[NSMutableDictionary alloc] init];
//        [metadata setLocation:self.currentLocation];
        
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library writeImageToSavedPhotosAlbum:image.CGImage
                                     metadata:nil
                              completionBlock:^(NSURL *assetURL, NSError *error) {
                                  
                                  if (!error)
                                      NSLog(@"SAVED TO CAMERA ROLL SUCCESSFULLY");
                                  
                                  NSLog(@"assetURL %@", assetURL);
                              }];
    }
}


- (void)imageCropperDidCancel:(ImageCropper *)cropper {
    
	// Default UIImagePickerDelegate cancel method
    [self imagePickerControllerDidCancel:(UIImagePickerController *)self.modalViewController];
    
    // Go to Feed tab
    [[self appDelegate].tabBarController setSelectedIndex:0];
	
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
}


#pragma mark - Private Methods
- (AppDelegate *)appDelegate {
	
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}


#pragma mark - Private Methods
- (void)updateLocationDidFinish:(CLLocation *)loc {
    
    self.currentLocation = loc;
	
	// Stop the manager updating
	[self.locationManager stopUpdating];
	
	NSLog(@"FOUND LOCATION:%f\%f", self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude);

}


- (void)updateLocationDidFailWithError:(NSError *)error {

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Error"
                                                    message:[error description]
                                                   delegate:nil
                                          cancelButtonTitle:@"Close"
                                          otherButtonTitles:nil, nil];
    [alert show];
}


- (void)startLocationManager:(id)sender {
	
	// Retrieve the user's current location
	// if the location manager is not already updating the user's location
	if (!self.locationManager.updating) {
		
		//[self.loadingSpinner startAnimating];
		
		NSLog(@"LOCATION MANAGER STARTED");
		
		[self.locationManager startUpdating];
	}
}


// For responding to the user tapping Cancel.
- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker {
	
    BOOL showCamera = NO;
    
    if (picker != self.cameraUI) showCamera = YES;
    
    [picker dismissModalViewControllerAnimated:NO];
    
    if (showCamera) [self presentModalViewController:self.cameraUI animated:NO];
}


// For responding to the user accepting a newly-captured picture or movie
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	
	// We have not yet gotten the URL for this Image file
	imageURLProcessed = NO;
	
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *originalImage, *editedImage, *imageToSave;
        
	// Handle a still image capture
	if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0) == kCFCompareEqualTo) {
		
		editedImage = (UIImage *)[info objectForKey:UIImagePickerControllerEditedImage];
		originalImage = (UIImage *)[info objectForKey: UIImagePickerControllerOriginalImage];
		
		if (editedImage) imageToSave = editedImage;
		else imageToSave = originalImage;
		
		// IF the image was selected from the phone's Photo library
		// then we grab the reference URL from the info dictionary and assign it
		// to the imageReferenceURL property
		if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
			
			selectedPhoto = YES;
			imageURLProcessed = YES;
			self.imageReferenceURL = [info objectForKey:UIImagePickerControllerReferenceURL];
            
            self.photo = imageToSave;

            [self newPhotoApproved:nil];

            [self dismissModalViewControllerAnimated:NO];

            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];

		}
		
		// If the user just took a photo using the camera
		if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) { 
			
            NSLog(@"INFO:%@", [info objectForKey:UIImagePickerControllerMediaMetadata]);
            
            // Insert the overlay
            UIImage *resized = [imageToSave resizedImage:CGSizeMake(640.0, 854.0) interpolationQuality:1.0];
            
            ImageCropper *cropper = [[ImageCropper alloc] initWithImage:resized];
            [cropper setDelegate:self];
            
            [picker pushViewController:cropper animated:YES];
            
			selectedPhoto = NO;
			
			imageURLProcessed = YES;
		}
	}
}


- (BOOL) startCameraControllerFromViewController: (UIViewController*) controller
								   usingDelegate: (id <UIImagePickerControllerDelegate,
												   UINavigationControllerDelegate>) delegate {
	
    if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO) || (delegate == nil) || (controller == nil))
        return NO;
	
    //if (!self.cameraUI) {
	
        UIImagePickerController *camera = [[UIImagePickerController alloc] init];
        camera.sourceType = UIImagePickerControllerSourceTypeCamera;
        camera.showsCameraControls = NO;
        camera.wantsFullScreenLayout = YES;
        camera.navigationBarHidden = YES;
        camera.toolbarHidden = YES;
        
        UIView *overlay = [self createCameraOverlay];
        camera.cameraOverlayView = overlay;
        
        // Displays a control that allows the user to choose picture or
        // movie capture, if both are available:
        camera.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
        
        // Hides the controls for moving & scaling pictures, or for
        // trimming movies. To instead show the controls, use YES.
        camera.allowsEditing = NO;
        camera.delegate = delegate;
        
        self.cameraUI = camera;
    // }
	    
    [controller setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [controller presentModalViewController:self.cameraUI animated:NO];
    
    return YES;
}


// CROP IMAGE
- (UIImage*)imageByCropping:(UIImage *)imageToCrop toRect:(CGRect)rect {
    
    CGRect newRect = CGRectMake(0.0, 76.0, 320.0, 320.0);
    
    //create a context to do our clipping in
    UIGraphicsBeginImageContext(newRect.size);
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    
    //create a rect with the size we want to crop the image to
    //the X and Y here are zero so we start at the beginning of our
    //newly created context
    CGRect clippedRect = CGRectMake(0, 0, newRect.size.width, newRect.size.height);
    CGContextClipToRect( currentContext, clippedRect);
    
    //create a rect equivalent to the full size of the image
    //offset the rect by the X and Y we want to start the crop
    //from in order to cut off anything before them
    CGRect drawRect = CGRectMake(newRect.origin.x * -1,
                                 newRect.origin.y * -1,
                                 imageToCrop.size.width,
                                 imageToCrop.size.height);
    
    //draw the image to our clipped context using our offset rect
    CGContextDrawImage(currentContext, drawRect, imageToCrop.CGImage);
    
    //pull the image from our cropped context
    UIImage *cropped = UIGraphicsGetImageFromCurrentImageContext();
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    
    //Note: this is autoreleased
    return cropped;
}


- (UIImage *)cropImage:(UIImage *)imageToCrop {

    CGRect rect = CGRectMake(0, 0, imageToCrop.size.width, 320);
    
    // Create bitmap image from original image data,
    // using rectangle to specify desired crop area
    CGImageRef imageRef = CGImageCreateWithImageInRect([imageToCrop CGImage], rect);
    UIImage *img = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return img;
}


- (UIImage*)imageWithImage:(UIImage*)image
              scaledToSize:(CGSize)newSize;
{
    UIGraphicsBeginImageContext( newSize );
    [image drawInRect:CGRectMake(0,76,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}




#pragma MY METHODS

- (void)initNavBar {
	
	// Hide default nav bar
	self.navigationController.navigationBarHidden = YES;
	
}


- (IBAction)showCameraUI:(id)sender {
	
	[self startCameraControllerFromViewController:self usingDelegate:self];
}


- (BOOL)newPhotoApproved:(id)sender {
	
	// Check that: the image URL has been found (processed), the image URL is NOT nil
	// AND the locationManager is NOT currently updating
	if (imageURLProcessed && !self.locationManager.updating) {
		
		TAShareVC *shareVC = [[TAShareVC alloc] initWithNibName:@"TAShareVC" bundle:nil];
		[shareVC setPhoto:self.photo];
        [shareVC setCurrentLocation:self.currentLocation];
        
		if (selectedPhoto) [shareVC setImageReferenceURL:self.imageReferenceURL];
		else [shareVC setCurrentLocation:self.currentLocation];
		
		[self.navigationController pushViewController:shareVC animated:YES];
		
		// Clear the image view, for next it needs to be used.
		self.photo = nil;
		[self setImageReferenceURL:nil];
        
        return YES;
	}
    
    else {
    
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Trying to locate you!" message:@"We're trying to detect your current location. Make sure location services are enabled for this app." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [av show];
        
        return NO;
    }
}


- (NSDictionary *)getGPSDictionaryForLocation:(CLLocation *)location {
	
    NSMutableDictionary *gps = [NSMutableDictionary dictionary];
	
    // GPS tag version
    [gps setObject:@"2.2.0.0" forKey:(NSString *)kCGImagePropertyGPSVersion];
	
    // Time and date must be provided as strings, not as an NSDate object
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm:ss.SSSSSS"];
	
	// Is timezone really necessary?
    //[formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    //[gps setObject:[formatter stringFromDate:location.timestamp] forKey:(NSString *)kCGImagePropertyGPSTimeStamp];
	
    [formatter setDateFormat:@"yyyy:MM:dd"];
    [gps setObject:[formatter stringFromDate:location.timestamp] forKey:(NSString *)kCGImagePropertyGPSDateStamp];
	
    // LATITUDE
    CGFloat latitude = location.coordinate.latitude;
	
    if (latitude < 0) {
        latitude = -latitude;
        [gps setObject:@"S" forKey:(NSString *)kCGImagePropertyGPSLatitudeRef];
    } 
	
	else [gps setObject:@"N" forKey:(NSString *)kCGImagePropertyGPSLatitudeRef];
	
    [gps setObject:[NSNumber numberWithFloat:latitude] forKey:(NSString *)kCGImagePropertyGPSLatitude];
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////
	
    // LONGITUDE
    CGFloat longitude = location.coordinate.longitude;
	
    if (longitude < 0) {
        longitude = -longitude;
        [gps setObject:@"W" forKey:(NSString *)kCGImagePropertyGPSLongitudeRef];
    } 
	
	else [gps setObject:@"E" forKey:(NSString *)kCGImagePropertyGPSLongitudeRef];
	
    [gps setObject:[NSNumber numberWithFloat:longitude] forKey:(NSString *)kCGImagePropertyGPSLongitude];
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////
	
    // ALTITUDE
    CGFloat altitude = location.altitude;
	
    if (!isnan(altitude)){
		
        if (altitude < 0) {
            altitude = -altitude;
            [gps setObject:@"1" forKey:(NSString *)kCGImagePropertyGPSAltitudeRef];
        } 
		
		else [gps setObject:@"0" forKey:(NSString *)kCGImagePropertyGPSAltitudeRef];
		
        [gps setObject:[NSNumber numberWithFloat:altitude] forKey:(NSString *)kCGImagePropertyGPSAltitude];
    }
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////
	
    // Speed, must be converted from m/s to km/h
    if (location.speed >= 0){
        [gps setObject:@"K" forKey:(NSString *)kCGImagePropertyGPSSpeedRef];
        [gps setObject:[NSNumber numberWithFloat:location.speed*3.6] forKey:(NSString *)kCGImagePropertyGPSSpeed];
    }
	
    // Heading
    if (location.course >= 0){
        [gps setObject:@"T" forKey:(NSString *)kCGImagePropertyGPSTrackRef];
        [gps setObject:[NSNumber numberWithFloat:location.course] forKey:(NSString *)kCGImagePropertyGPSTrack];
    }
	
    return gps;
}


- (void)willLogout {
    
    [self.navigationController popToRootViewControllerAnimated:NO];
}


- (UIView *)createCameraOverlay {

    
    CGRect overlayFrame = CGRectMake(0, 0, 320, 480);
    UIView *overlayContainer = [[UIView alloc] initWithFrame:overlayFrame];
    [overlayContainer setBackgroundColor:[UIColor clearColor]];
    
    
    // This is aligned to the top of the screen and
    // contains the 'photo library' button and cancel button
    CGFloat topToolbarHeight = 76;
    CGFloat topToolbarWidth = 320;
    UIView *topToolbar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, topToolbarWidth, topToolbarHeight)];
    [topToolbar setBackgroundColor:[UIColor blackColor]];
    
    
    UIButton *photoLibraryBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [photoLibraryBtn setFrame:CGRectMake(28, 26, 43, 26)];
    [photoLibraryBtn setImage:[UIImage imageNamed:@"photo-library-button.png"] forState:UIControlStateNormal];
    [photoLibraryBtn addTarget:self action:@selector(photoLibraryButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    [topToolbar addSubview:photoLibraryBtn];
    
    
    UIButton *cancelCameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelCameraBtn setFrame:CGRectMake(254, 25, 43, 27)];
    [cancelCameraBtn setImage:[UIImage imageNamed:@"close-camera-button.png"] forState:UIControlStateNormal];
    [cancelCameraBtn addTarget:self action:@selector(cameraCancelButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [topToolbar addSubview:cancelCameraBtn];
    
    
    [overlayContainer addSubview:topToolbar];    
    
    
    
    // This takes the place of where the default
    // camera tools toolbar would have been
    CGFloat toolbarHeight = 84;
    CGFloat toolbarWidth = 320;
    UIView *toolbar = [[UIView alloc] initWithFrame:CGRectMake(0, (480 - toolbarHeight), toolbarWidth, toolbarHeight)];
    [toolbar setBackgroundColor:[UIColor blackColor]];
    
    
    UIButton *takeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [takeBtn setFrame:CGRectMake(25, 26, 270, 35)];
    [takeBtn setImage:[UIImage imageNamed:@"take-photo-button.png"] forState:UIControlStateNormal];
    [takeBtn setImage:[UIImage imageNamed:@"take-photo-button-on.png"] forState:UIControlStateHighlighted];
    [takeBtn addTarget:self action:@selector(cameraPhotoButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [toolbar addSubview:takeBtn];
    
    [overlayContainer addSubview:toolbar];
    
    
    return overlayContainer;
}


- (void)photoLibraryButtonTapped {

    [self dismissModalViewControllerAnimated:NO];
    
    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
	picker.allowsEditing = YES;
	picker.delegate = self;
	picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.navigationBarHidden = YES;
	
    [self presentModalViewController:picker animated:NO];
}


- (IBAction)cameraPhotoButtonTapped:(id)sender {
    
    UIImagePickerController *camera = (UIImagePickerController *)self.modalViewController;
    
    [camera takePicture];
}


- (IBAction)cameraCancelButtonTapped:(id)sender {
    
    // Default UIImagePickerDelegate cancel method
    [self imagePickerControllerDidCancel:self.cameraUI];
    
    // Go to Feed tab
    [[self appDelegate].tabBarController setSelectedIndex:0];
}


@end
