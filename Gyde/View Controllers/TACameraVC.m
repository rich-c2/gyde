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
#import "CameraOverlayVC.h"
#import "AppDelegate.h"
#import "UIImage+fixOrientation.h"
#import "ImageCropper.h"
#import "UIImage+Resize.h"
#import "MBProgressHUD.h"
#import "NSMutableDictionary+ImageMetadata.h"

@interface TACameraVC ()

@end

@implementation TACameraVC

@synthesize photo, imageReferenceURL, cameraOverlay, cameraUI;
@synthesize locationManager, currentLocation;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	
    if (self) {
        
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [self startLocationManager:nil];
    self.locationTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(startLocationManager:) userInfo:nil repeats:YES];
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



- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];
    
	// Start the location manager - tell it to start updating,
	// if it's not already doing so
    
	//[self startLocationManager:nil];
    
    [self restartLocationTimer];
    
    self.waitingToSave = NO;
    self.photo = nil;
    self.imageReferenceURL = nil;
    [self showCameraUI:nil];
}

- (void)viewDidDisappear:(BOOL)animated {

    [super viewDidDisappear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {

    [super viewWillDisappear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
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
    BOOL approved = [self newPhotoReady:NO];
    
    if (approved) {
        
        [MBProgressHUD showHUDAddedTo:cropper.view animated:YES];
     
        [self saveToPhotosAlbum:^(BOOL success){
            
            [MBProgressHUD hideAllHUDsForView:cropper.view animated:YES];
        
            TAShareVC *shareVC = [[TAShareVC alloc] initWithNibName:@"TAShareVC" bundle:nil];
            [shareVC setPhoto:self.photo];
            [shareVC setImageReferenceURL:self.imageReferenceURL];
            
            [self.navigationController pushViewController:shareVC animated:YES];
            
            [self dismissModalViewControllerAnimated:NO];
            
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
        }];
    }
    
    else {
    
        self.waitingToSave = YES;
    }
}


- (void)saveToPhotosAlbum:(void(^)(BOOL success))completionBlock {
    
    NSMutableDictionary *metadata = [[NSMutableDictionary alloc] init];
    [metadata setLocation:self.currentLocation];

    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library writeImageToSavedPhotosAlbum:self.photo.CGImage
                                 metadata:metadata
                          completionBlock:^(NSURL *assetURL, NSError *error) {
                              
                              if (!error) {
                                  self.imageReferenceURL = assetURL;
                                  NSLog(@"SAVED TO CAMERA ROLL SUCCESSFULLY");
                                  completionBlock(YES);
                              }
                              else {
                                  completionBlock(NO);
                              }
                              
                              NSLog(@"assetURL %@", assetURL);
                          }];
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
    self.currentLocationDate = [NSDate date];
	
	// Stop the manager updating
	[self.locationManager stopUpdating];
	
	NSLog(@"FOUND LOCATION:%f\%f", self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude);
    
    // A photo has been taken and is waiting
    // to be saved and move onto the Share screen
    if (self.waitingToSave) {
        
        [MBProgressHUD showHUDAddedTo:self.modalViewController.view animated:YES];
        
        [self saveToPhotosAlbum:^(BOOL success){
            
            [MBProgressHUD hideAllHUDsForView:self.modalViewController.view animated:YES];
            
            TAShareVC *shareVC = [[TAShareVC alloc] initWithNibName:@"TAShareVC" bundle:nil];
            [shareVC setPhoto:self.photo];
            [shareVC setImageReferenceURL:self.imageReferenceURL];
            
            [self.navigationController pushViewController:shareVC animated:YES];
            
            [self dismissModalViewControllerAnimated:NO];
            
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
        }];
    }
}


- (void)updateLocationDidFailWithError:(NSError *)error {
    
    if ([error domain] == kCLErrorDomain) {
        
        // Default UIImagePickerDelegate cancel method
        [self imagePickerControllerDidCancel:self.cameraUI];
        
        // Go to Feed tab
        [[self appDelegate].tabBarController setSelectedIndex:0];
    
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location permissions"
                                                        message:@"You must allow Gyde to track your user location in order to submit place photos. Please check your device's Settings."
                                                       delegate:nil
                                              cancelButtonTitle:@"Close"
                                              otherButtonTitles:nil, nil];
        [alert show];
    }
    
    else {

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Error"
                                                        message:[error description]
                                                       delegate:nil
                                              cancelButtonTitle:@"Close"
                                              otherButtonTitles:nil, nil];
        [alert show];
    }
}


- (void)startLocationManager:(id)sender {
	
	// Retrieve the user's current location
	// if the location manager is not already updating the user's location
	if (!self.locationManager.updating) {
		
		[self.locationManager startUpdating];
	}
}


- (void)didBecomeActive:(id)sender {
    
    [self restartLocationTimer];

    NSLog(@"UIApplicationWillEnterForegroundNotification");
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
			
			self.imageReferenceURL = [info objectForKey:UIImagePickerControllerReferenceURL];            
            self.photo = imageToSave;

            BOOL approved = [self newPhotoReady:YES];
            
            if (approved) {
            
                TAShareVC *shareVC = [[TAShareVC alloc] initWithNibName:@"TAShareVC" bundle:nil];
                [shareVC setPhoto:self.photo];
                [shareVC setImageReferenceURL:self.imageReferenceURL];
                
                [self.navigationController pushViewController:shareVC animated:YES];
                
                [self dismissModalViewControllerAnimated:NO];
                
                [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
            }
		}
		
		// If the user just took a photo using the camera
		if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            
            // Check that a current location has been found
            if ([self isValidCurrentLocation]) {
            
                [self.locationTimer invalidate];
                self.locationTimer = nil;
            }
			
            //NSLog(@"INFO:%@", [info objectForKey:UIImagePickerControllerMediaMetadata]);
            
            // Insert the overlay
            UIImage *resized = [imageToSave resizedImage:CGSizeMake(640.0, 854.0) interpolationQuality:1.0];
            
            ImageCropper *cropper = [[ImageCropper alloc] initWithImage:resized];
            [cropper setDelegate:self];
            
            [picker pushViewController:cropper animated:YES];			
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


- (BOOL)newPhotoReady:(BOOL)fromCameraRoll {
    
    if (!fromCameraRoll) {
        
        if (self.locationManager.updating) {
    
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Trying to locate you!"
                                                         message:@"We're trying to detect your current location. Make sure location services are enabled for this app."
                                                        delegate:self cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil, nil];
            [av show];
            
            return NO;
        }
        
//        BOOL validCurrentLocation = [self isValidCurrentLocation];
//        
//        if (!validCurrentLocation) {
//            
//            [self startLocationManager:nil];
//        
//            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Trying to locate you!"
//                                                         message:@"We're trying to detect your current location. Make sure location services are enabled for this app."
//                                                        delegate:self cancelButtonTitle:@"OK"
//                                               otherButtonTitles:nil, nil];
//            [av show];
//            return NO;
//        }
    }
    
	return YES;
}


- (void)willLogout {
    
    [self.navigationController popToRootViewControllerAnimated:NO];
}


- (UIView *)createCameraOverlay {

    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    CGRect overlayFrame = CGRectMake(0, 0, screenWidth, screenHeight);
    UIView *overlayContainer = [[UIView alloc] initWithFrame:overlayFrame];
    [overlayContainer setBackgroundColor:[UIColor clearColor]];
    
    
    CGFloat cropAreaHeight = 328.0;
    
    // This is aligned to the top of the screen and
    // contains the 'photo library' button and cancel button
    CGFloat topToolbarHeight = 76;
    CGFloat topToolbarWidth = screenWidth;
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
    CGFloat toolbarHeight = screenHeight - (topToolbarHeight + cropAreaHeight);
    CGFloat toolbarWidth = screenWidth;
    UIView *toolbar = [[UIView alloc] initWithFrame:CGRectMake(0, (screenHeight - toolbarHeight), toolbarWidth, toolbarHeight)];
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


- (BOOL)isValidCurrentLocation {
    
    NSTimeInterval seconds = [[NSDate date] timeIntervalSinceDate:self.currentLocationDate];
    
    return ((seconds >= 10) ? NO : YES);
}

- (void)restartLocationTimer {

    if (!self.locationTimer || ![self.locationTimer isValid]) {
        
        [self startLocationManager:nil];
        self.locationTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(startLocationManager:) userInfo:nil repeats:YES];
    }
    
}



@end
