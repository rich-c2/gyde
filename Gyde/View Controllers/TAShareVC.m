//
//  TAShareVC.m
//  Tourism App
//
//  Created by Richard Lee on 28/08/12.
//  Copyright (c) 2012 C2 Media Pty Ltd. All rights reserved.
//

#import "TAShareVC.h"
#import "AppDelegate.h"
#import "StringHelper.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "TAUsersVC.h"
#import "TAPlacesVC.h"
#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>
#import "TAGuidesListVC.h"
#import "MyMapAnnotation.h"
#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "MBProgressHUD.h"

#define SUBMIT_ALERT_TAG 9000
#define MAIN_CONTENT_HEIGHT 367
#define FACEBOOK_ALERT_TAG 10000
#define GO_BACK_ALERT_TAG 3000
#define NO_TWITTER_ACCOUNT_TAG 4000
#define NO_METADATA_TAG 5000

@interface TAShareVC ()

@end

@implementation TAShareVC

@synthesize photo, imageReferenceURL, selectedCity, tagLabel, captionField, photoView;
@synthesize currentLocation, selectedTag, cityLabel, recommendToUsernames, placeData, selectedAccountIdentifier;
@synthesize placeTitleLabel, scrollView, savedAccountStore;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
	
    [super viewDidLoad];
    
    self.navigationItem.title = @"SUBMIT PLACE";
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"nav-bar-back-button.png"] forState:UIControlStateNormal];
    [backButton setImage:[UIImage imageNamed:@"nav-bar-back-button-on.png"] forState:UIControlStateHighlighted];
    [backButton setFrame:CGRectMake(0, 0, 57, 27)];
    [backButton addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
	self.navigationItem.leftBarButtonItem = backButtonItem;
    
    
    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [saveButton setBackgroundImage:[UIImage imageNamed:@"nav-bar-save-button.png"] forState:UIControlStateNormal];
    [saveButton setBackgroundImage:[UIImage imageNamed:@"nav-bar-save-button-on.png"] forState:UIControlStateHighlighted];
    [saveButton setFrame:CGRectMake(0, 0, 54, 27)];
    [saveButton addTarget:self action:@selector(submitPhoto:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *saveButtonItem = [[UIBarButtonItem alloc] initWithCustomView:saveButton];
    
	self.navigationItem.rightBarButtonItem = saveButtonItem;
    
    
    // Remove top padding from caption text view
    //self.captionField.contentInset = UIEdgeInsetsMake(-8,-8,0,0);
    [self.captionField becomeFirstResponder];
    
	
	// Place the photo within the polaroid image view
	[self.photoView setImage:self.photo];
	
	
	// Set the scroll view's content size to be bigger than it's frame
	[self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, 450.0)];
	
	
	// Determine the 'current location' being used for 
	// the photo being submitted. Either an imageReferenceURL has
	// been provided or the current location has been set by TACameraVC
	// Then trigger the Yahoo API call to get the associated City.
	[self configureCurrentLocation];
    
    // Add single tap gesture recognizer to map view
    // The action will be to take the user to the places list
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self action:@selector(editPlaceButtonTapped:)];
    tgr.numberOfTapsRequired = 1;
    tgr.numberOfTouchesRequired = 1;
    [self.map addGestureRecognizer:tgr];
}


#pragma mark - Private Methods
- (AppDelegate *)appDelegate {
	
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}


- (void)viewDidUnload {
	
	self.selectedCity = nil;
	self.currentLocation = nil;
	self.selectedTag = nil;
	self.recommendToUsernames = nil;
	self.placeData = nil;
    self.guideData = nil;
	
	self.captionField = nil;
	
	self.photo = nil; 
	self.imageReferenceURL = nil;
	
	self.tagLabel = nil;
	
	self.cityLabel = nil;

	self.placeTitleLabel = nil;
	
	self.scrollView = nil;
	
	photoView = nil;
	[super viewDidUnload];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];
}


#pragma GuidesListDelegate methods 

- (void)guideWasSelected:(NSString *)guideID {

    // Store the fact that we need to
    // add this photo to an existing
    // Guide upon photo submission
    addToGuide = YES;
    createNewGuide = NO;
    
    // Store the selected guideID in our
    // guideData dictionary so that it
    // can be used later to pass to the API.
    if (!self.guideData) self.guideData = [NSMutableDictionary dictionary];
    
    [self.guideData setObject:guideID forKey:@"guideID"];
}


- (void)newGuideDetailsWereCreated:(NSMutableDictionary *)guideDetails {

    // Store the fact that we need to
    // add this photo to an new
    // Guide upon photo submission
    addToGuide = NO;
    createNewGuide = YES;
    
    // Store the selected guideID in our
    // guideData dictionary so that it
    // can be used later to pass to the API.
    if (!self.guideData) self.guideData = [NSMutableDictionary dictionary];
    
    self.guideData = guideDetails;
}


#pragma UITextViewDelegate methods 

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
	
	BOOL shouldChangeText = YES;
	
	if ([text isEqualToString:@"\n"]) {
		
		// Hide keyboard
        [self.captionField resignFirstResponder];
	}
	
	return shouldChangeText;
}


#pragma MKMapViewDelegate methods

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
	
    if ([annotation isKindOfClass:[MKUserLocation class]])
		return nil;
	
	static NSString * const kPinAnnotationIdentifier = @"PinIdentifier";
	
	MKPinAnnotationView* pinView;
	
    if ([annotation isKindOfClass:[MyMapAnnotation class]]) {
		
		// try to dequeue an existing pin view first
        static NSString* annotationIdentifier = @"annotationIdentifier";
        pinView = (MKPinAnnotationView *)
		[self.map dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
		
		if (!pinView) {
			
			pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:kPinAnnotationIdentifier];
			
			[pinView setUserInteractionEnabled:YES];
			[pinView setCanShowCallout:NO];
		}
	}
	
	return pinView;
}


- (void)initSingleLocation {
	
	// Map type
	self.map.mapType = MKMapTypeStandard;
	
	/*Region and Zoom*/
	MKCoordinateRegion region;
	MKCoordinateSpan span;
	span.latitudeDelta = 0.0006;
	span.longitudeDelta = 0.0006;
	
	CLLocationCoordinate2D coordLocation;
	coordLocation.latitude = self.currentLocation.coordinate.latitude;
	coordLocation.longitude = self.currentLocation.coordinate.longitude;
	region.span = span;
	region.center = coordLocation;
	
	[self.map setRegion:region animated:TRUE];
	[self.map regionThatFits:region];
	
	NSString *title = @"Photo location";
	
	MyMapAnnotation *mapAnnotation = [[MyMapAnnotation alloc] initWithCoordinate:coordLocation title:title];
	[self.map addAnnotation:mapAnnotation];
}


#pragma PlacesDelegate methods 

- (void)placeSelected:(NSMutableDictionary *)newPlaceData {

	self.placeData = newPlaceData;
	
	NSLog(@"RECEIVED PLACE DATA:%@", self.placeData);
	
	// Retrieve the lat/lng data from the dictionary and
	// update the map marker, and make the map focus on the new coord
	NSDictionary *locationData = [self.placeData objectForKey:@"location"];
	CLLocationCoordinate2D newCoord;
	newCoord.latitude = [[locationData objectForKey:@"lat"] doubleValue];
	newCoord.longitude = [[locationData objectForKey:@"lng"] doubleValue];
	
	// Update the 'currentLocation' property to reflect the lat/lng values
	// that were part of the place that was selected
	CLLocation *newLocation = [[CLLocation alloc] initWithLatitude:newCoord.latitude longitude:newCoord.longitude];
	self.currentLocation = newLocation;
	
	// Update place title and place address
	self.placeTitleLabel.text = [self.placeData objectForKey:@"name"];
    
    NSArray *locationKeys = [locationData allKeys];
	NSMutableString *formattedAddress = [NSMutableString string];
	
	if ([locationKeys containsObject:@"Address"] && [locationData objectForKey:@"Address"] != [NSNull null])
		[formattedAddress appendString:[locationData objectForKey:@"Address"]];
	
	if ([locationKeys containsObject:@"City"] && [locationData objectForKey:@"City"] != [NSNull null])
		[formattedAddress appendFormat:@" %@", [locationData objectForKey:@"City"]];
	
	if ([locationKeys containsObject:@"State"] && [locationData objectForKey:@"State"] != [NSNull null])
		[formattedAddress appendFormat:@" %@", [locationData objectForKey:@"State"]];
	
	if ([locationKeys containsObject:@"PostalCode"] && [locationData objectForKey:@"PostalCode"] != [NSNull null])
		[formattedAddress appendFormat:@" %@", [locationData objectForKey:@"PostalCode"]];
	
	self.placeAddressLabel.text = formattedAddress;
}


- (void)locationMapped:(NSMutableDictionary *)newPlaceData {
	
	self.placeData = newPlaceData;
	
	// Retrieve the lat/lng data from the dictionary and
	// update the map marker, and make the map focus on the new coord
	NSDictionary *locationData = [self.placeData objectForKey:@"location"];
	CLLocationCoordinate2D newCoord;
	newCoord.latitude = [[locationData objectForKey:@"lat"] doubleValue];
	newCoord.longitude = [[locationData objectForKey:@"lng"] doubleValue];
	
	// Update the 'currentLocation' property to reflect the lat/lng values
	// that were part of the place that was selected
	CLLocation *newLocation = [[CLLocation alloc] initWithLatitude:newCoord.latitude longitude:newCoord.longitude];
	self.currentLocation = newLocation;
	
	// Update place title and place address
	self.placeTitleLabel.text = [self.placeData objectForKey:@"name"];
    
    NSArray *locationKeys = [locationData allKeys];
	NSMutableString *formattedAddress = [NSMutableString string];
	
	if ([locationKeys containsObject:@"address"])
		[formattedAddress appendString:[locationData objectForKey:@"address"]];
	
	if ([locationKeys containsObject:@"city"])
		[formattedAddress appendFormat:@" %@", [locationData objectForKey:@"city"]];
	
	if ([locationKeys containsObject:@"state"])
		[formattedAddress appendFormat:@" %@", [locationData objectForKey:@"state"]];
	
	if ([locationKeys containsObject:@"postalCode"])
		[formattedAddress appendFormat:@" %@", [locationData objectForKey:@"postalCode"]];
	
	self.placeAddressLabel.text = formattedAddress;
}


#pragma mark UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == GO_BACK_ALERT_TAG) {
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setBool:YES forKey:SUBMIT_PLACE_ALERT_KEY_DISPLAYED];
        [defaults synchronize];
    
        if (buttonIndex == 0) {
        
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    
    if (alertView.tag == NO_METADATA_TAG)
        [self.navigationController popViewControllerAnimated:YES];
	
	if (alertView.tag == SUBMIT_ALERT_TAG && !self.shareOnTwitter)
        [self.navigationController popViewControllerAnimated:YES];
    
    if (alertView.tag == NO_TWITTER_ACCOUNT_TAG)
        [self.navigationController popViewControllerAnimated:YES];
    
}


#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	
	// Hide keyboard
	[self.captionField resignFirstResponder];
	
	return YES;
}


#pragma RecommendsDelegate methods

- (void)recommendToUsernames:(NSMutableArray *)usernames {
	
	// Retain the usernames that were selected 
	// for this Guide to be recommend to
	self.recommendToUsernames = usernames;
    
    if (self.recommendToUsernames.count > 0) {
    
        NSString *imageName = (self.recommendToUsernames.count > 0) ? @"submit-recommend-button-on.png" : @"submit-recommend-button.png";
        [self.recommendBtn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    }
        
}


#pragma TagsDelegate

- (void)tagSelected:(Tag *)tag {
	
	// Set the selected Tag
	[self setSelectedTag:tag]; 
	
	// Set the Tag button's title to that of the Location's
	[self.tagLabel setText:tag.title];
}



#pragma MY METHODS 

- (void)goBack:(id)sender {
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:SUBMIT_PLACE_ALERT_KEY_DISPLAYED]) {
        UIAlertView *av =  [[UIAlertView alloc] initWithTitle:@"Are you sure?" message:@"You are about to go back without saving this place. Are you sure you want to go back?"
                                                     delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"Cancel", nil];
        av.tag = GO_BACK_ALERT_TAG;
        [av show];
        return;
    }

	[self.navigationController popViewControllerAnimated:YES];
}


- (void)getCity {

    [self initGetCityApi:^(BOOL success) {
       
        if (success) {
        
            self.cityLabel.userInteractionEnabled = NO;
        }
    }];
}


- (IBAction)addToGuideButtonTapped:(id)sender {
    
	TAGuidesListVC *guidesVC = [[TAGuidesListVC alloc] initWithNibName:@"TAGuidesListVC" bundle:nil];
	[guidesVC setUsername:[self appDelegate].loggedInUsername];
	[guidesVC setGuidesMode:GuidesModeAddTo];
	[guidesVC setSelectedTagID:[self.selectedTag tagID]];
	[guidesVC setSelectedCity:self.selectedCity];
    [guidesVC setDelegate:self];
	
	[self.navigationController pushViewController:guidesVC animated:YES];
}


- (IBAction)addToTwitterButtonTapped:(id)sender {
    
    BOOL twitterAvailable = [[TwitterHelper sharedHelper] isTwitterAvailable];
    
    if (!twitterAvailable) {
        
        NSString *message = @"You have no Twitter accounts setup on your phone. Please add one via your Settings app and try again.";
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"No accounts" message:message
                                                    delegate:self
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil, nil];
        [av show];
        return;
    }

    self.shareOnTwitter = !self.shareOnTwitter;
    
    NSString *imageName = (self.shareOnTwitter) ? @"submit-tweet-button-on.png" : @"submit-tweet-button.png";
    UIButton *twitterBtn = (UIButton *)sender;
    [twitterBtn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
}


- (IBAction)submitPhoto:(id)sender {
    
    if (!self.selectedTag) {
    
        NSString *message = @"Please select an acitivity.";
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Can't upload place" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
		[alert show];
        return;
    }
    
    if (!self.selectedCity) {
    
        NSString *message = @"Your city is still be detecting.";
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Can't upload place" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
		[alert show];
        return;
    }
    
    if (!self.placeData) {
    
        NSString *message = @"Please assign a location.";
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Can't upload place" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
		[alert show];
        return;
    }
    
        
    NSDictionary *params = [self getUploadParameters];
    NSNumber *randomNum = [self generateRandomNumberWithMax:100000];
    NSString *imageFilename = [NSString stringWithFormat:@"%i.jpg", [randomNum intValue]];
            
    [[GlooRequestManager sharedManager] post:@"Submit" image:self.photo
                               imageParamKey:@"file" fileName:imageFilename params:params
                               dataLoadBlock:^(NSDictionary *json){}
                             completionBlock:^(NSDictionary *json){
                             
                                 NSString *result = json[@"result"];
                                 
                                 if (![result isEqualToString:@"ok"]) {
                                 
                                     NSLog(@"ERROR: %@", json);
                                     
                                     UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Upload error"
                                                                                  message:@"There was an error processing the upload of your place. Please check your network connection."
                                                                                 delegate:self
                                                                        cancelButtonTitle:@"OK"
                                                                        otherButtonTitles:nil, nil];
                                     [av show];
                                     return;
                                 }
                                 
                                 if ([result isEqualToString:@"ok"]) {
                                     
                                     NSString *message = @"Your photo was successfully submitted.";
                                     UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Success!"
                                                                                         message:message
                                                                                        delegate:self
                                                                               cancelButtonTitle:@"OK"
                                                                               otherButtonTitles:nil];
                                     [alertView setTag:SUBMIT_ALERT_TAG];
                                     [alertView show];
                                     
                                     if (self.shareOnTwitter) {
                                     
                                         NSString *initialText = json[@"media"][@"location"][@"name"];
                                         NSURL *url = [NSURL URLWithString:json[@"media"][@"url"][@"short"]];
                                         [self sharePhotoOnTwitterWithText:initialText url:url];
                                     }
                                     
                                     if (postToFacebook) {
                                         
                                         // Post a status update to the user's feed via the Graph API, and display an alert view
                                         // with the results or an error.                                             
                                         NSString *message = @"Gyde for iOS.";
                                         
                                         NSDictionary *mediaDict = json[@"media"];
                                         NSDictionary *pathsDict = mediaDict[@"paths"];
                                         NSDictionary *urlDict = mediaDict[@"url"];
                                         
                                         NSString *description = mediaDict[@"caption"];
                                         
                                         NSMutableDictionary *postParams = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                                                            [urlDict objectForKey:@"long"], @"link",
                                                                            [NSString stringWithFormat:@"http://want.supergloo.net.au%@", [pathsDict objectForKey:@"squarethumb"]], @"picture",
                                                                            @"Just took this photo on Gyde.", @"name",
                                                                            message, @"caption",
                                                                            description, @"description",
                                                                            nil];
                                         
                                         [self publishPhotoToFacebookFeed:postParams];
                                     }
                                     
                                     if (addToGuide) {
                                         
                                         NSDictionary *mediaDict = json[@"media"];
                                         NSString *guideID = [self.guideData objectForKey:@"guideID"];
                                                                                                                                   
                                         NSDictionary *params = @{ @"username" : [self appDelegate].loggedInUsername, @"token" : [[self appDelegate] sessionToken],
                                         @"imageID" : mediaDict[@"code"], @"guideID" : guideID };
                                                                                                                                                                                
                                         [[GlooRequestManager sharedManager] post:@"addtoguide"
                                                                           params:params
                                                                    dataLoadBlock:^(NSDictionary *json){}
                                                                  completionBlock:^(NSDictionary *json){}
                                                                    viewForHUD:nil];
                                                
                                     }
                                     
                                     if (createNewGuide) {
                                         
                                         NSDictionary *mediaDict = json[@"media"];
                                         [self initAddGuideAPIWithPhoto:mediaDict[@"code"] guideDetails:self.guideData];
                                     }
                                 }
                                 
                                 else {
                                 
                                     NSLog(@"ERROR: %@", json);
                                     
                                     NSString *message = @"There was an error submitting your place. Please check your network connection";
                                     UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Upload error"
                                                                                         message:message
                                                                                        delegate:self
                                                                               cancelButtonTitle:@"OK"
                                                                               otherButtonTitles:nil];
                                     [alertView show];
                                 }
                             }
                                  viewForHUD:self.view];
}


- (void)uploadPhoto {
    
    NSDictionary *params = [self getUploadParameters];
    
    NSNumber *randomNum = [self generateRandomNumberWithMax:100000];
    NSString *imageFilename = [NSString stringWithFormat:@"%i.jpg", [randomNum intValue]];
    NSData* photoImageData = [NSData dataWithData:UIImageJPEGRepresentation(self.photo, 0.7)];
    
    NSURL *url = [NSURL URLWithString:API_ADDRESS];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    NSMutableURLRequest *afRequest = [httpClient multipartFormRequestWithMethod:@"POST"
                                                                           path:@"Submit"
                                                                     parameters:params
                                                      constructingBodyWithBlock:^(id <AFMultipartFormData>formData)
                                      {
                                          [formData appendPartWithFileData:photoImageData
                                                                  mimeType:@"image/jpeg"
                                                                      name:imageFilename];
                                      }
                                      ];
    
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeAnnularDeterminate;
    hud.labelText = @"Uploading";
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:afRequest];
    [operation setUploadProgressBlock:^(NSInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite) {
        
        NSLog(@"Sent %d of %d bytes", totalBytesWritten, totalBytesExpectedToWrite);
        hud.progress = (totalBytesWritten/totalBytesExpectedToWrite) * 100;
    }];
    
    [operation setCompletionBlock:^{
        NSLog(@"%@", operation.responseString); //Gives a very scary warning
        [hud hide:YES];
        
//        NSString *result = json[@"result"];
//        
//        if (![result isEqualToString:@"ok"]) {
//            
//            NSLog(@"ERROR: %@", json);
//            
//            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Upload error"
//                                                         message:@"There was an error processing the upload of your place. Please check your network connection."
//                                                        delegate:self
//                                               cancelButtonTitle:@"OK"
//                                               otherButtonTitles:nil, nil];
//            [av show];
//            return;
//        }
//        
//        if ([result isEqualToString:@"ok"]) {
//            
//            if (self.shareOnTwitter) {
//                
//#warning TO DO: attach place name to "initial text"
//                NSString *initialText = @"";
//                [self sharePhotoOnTwitterWithText:initialText];
//            }
//            
//            if (postToFacebook) {
//                
//                // Post a status update to the user's feed via the Graph API, and display an alert view
//                // with the results or an error.
//                NSString *message = @"Gyde for iOS.";
//                
//                NSDictionary *mediaDict = json[@"media"];
//                NSDictionary *pathsDict = mediaDict[@"paths"];
//                NSDictionary *urlDict = mediaDict[@"url"];
//                
//                NSString *description = mediaDict[@"caption"];
//                
//                NSMutableDictionary *postParams = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
//                                                   [urlDict objectForKey:@"long"], @"link",
//                                                   [NSString stringWithFormat:@"http://want.supergloo.net.au%@", [pathsDict objectForKey:@"squarethumb"]], @"picture",
//                                                   @"Just took this photo on Gyde.", @"name",
//                                                   message, @"caption",
//                                                   description, @"description",
//                                                   nil];
//                
//                [self publishPhotoToFacebookFeed:postParams];
//            }
//            
//            if (addToGuide) {
//                
//                NSDictionary *mediaDict = json[@"media"];
//                NSString *guideID = [self.guideData objectForKey:@"guideID"];
//                
//                NSDictionary *params = @{ @"username" : [self appDelegate].loggedInUsername, @"token" : [[self appDelegate] sessionToken],
//                @"imageID" : mediaDict[@"code"], @"guideID" : guideID };
//                
//                [[GlooRequestManager sharedManager] post:@"addtoguide"
//                                                  params:params
//                                           dataLoadBlock:^(NSDictionary *json){}
//                                         completionBlock:^(NSDictionary *json){}
//                                              viewForHUD:nil];
//                
//            }
//            
//            if (createNewGuide) {
//                
//                NSDictionary *mediaDict = json[@"media"];
//                [self initAddGuideAPIWithPhoto:mediaDict[@"code"] guideDetails:self.guideData];
//            }
//            
//            NSString *message = @"Your photo was successfully submitted.";
//            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Success!"
//                                                                message:message
//                                                               delegate:self
//                                                      cancelButtonTitle:@"OK"
//                                                      otherButtonTitles:nil];
//            [alertView setTag:SUBMIT_ALERT_TAG];
//            [alertView show];
//        }
//        
//        else {
//            
//            NSLog(@"ERROR: %@", json);
//            
//            NSString *message = @"Your photo was successfully submitted.";
//            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Upload error"
//                                                                message:json
//                                                               delegate:self
//                                                      cancelButtonTitle:@"OK"
//                                                      otherButtonTitles:nil];
//            [alertView show];
//        }
    }];
    
    [operation start];
}


- (NSDictionary *)getUploadParameters {
    
    NSString *username = [[self appDelegate] loggedInUsername];
    NSString *token = [[self appDelegate] sessionToken];
    NSString *latString = [NSString stringWithFormat:@"%f", self.currentLocation.coordinate.latitude];
    NSString *lonString = [NSString stringWithFormat:@"%f", self.currentLocation.coordinate.longitude];
    NSString *tagString = [NSString stringWithFormat:@"%i", [self.selectedTag.tagID intValue]];
    NSString *cityString = [NSString stringWithFormat:@"%@", self.selectedCity];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.captionField.text, @"caption", username, @"username",
                                   token, @"token", latString, @"latitude", lonString, @"longitude",
                                   tagString, @"tag", cityString, @"city", @"image", @"type", nil];
    
    if (self.placeData) {
        
        if ([self.placeData.allKeys containsObject:@"name"]) {
            
            if ([self.placeData objectForKey:@"name"] != nil)
                [params setObject:[self.placeData objectForKey:@"name"] forKey:@"place_title"];
        }
        
        NSDictionary *locationData = [self.placeData objectForKey:@"location"];
        NSArray *keys = locationData.allKeys;
        
        for (NSString *key in keys) {
            
            if ([locationData objectForKey:key] == nil)
                continue;
            
            NSString *val = [locationData objectForKey:key];
            
            if ([key isEqualToString:@"Address"]) {
                
                [params setObject:val forKey:@"place_address"];
            }
            
            if ([key isEqualToString:@"City"]) {
                
                [params setObject:val forKey:@"place_city"];
            }
            
            if ([key isEqualToString:@"State"]) {
                
                [params setObject:val forKey:@"place_state"];
            }
            
            if ([key isEqualToString:@"Country"]) {
                
                [params setObject:val forKey:@"place_country"];
            }
            
            if ([key isEqualToString:@"postalCode"]) {
                
                [params setObject:val forKey:@"place_postcode"];
            }
        }
        
        if ([self.placeData.allKeys containsObject:@"verified"]) {
            
            if ([self.placeData objectForKey:@"verified"] != nil)
                [params setObject:[self.placeData objectForKey:@"verified"] forKey:@"verified"];
        }
    }
    
    if ([self.recommendToUsernames count] > 0) {
        
        NSString *recType = [NSString stringWithFormat:@"%i", 0];
        [params setObject:recType forKey:@"rectype"];
        
        NSString *usernames = [NSString stringWithFormat:@"%@", [self.recommendToUsernames componentsJoinedByString:@","]];
        [params setObject:usernames forKey:@"rec_usernames"];
    }
    
    return params;
}


/* 
	selectTagButtonTapped();
	This function will take the user to a new screen
	where he/she can select a 'tag' for the image about
	to be published. 
 */
- (IBAction)selectTagButtonTapped:(id)sender {
	
	TASimpleListVC *tagListVC = [[TASimpleListVC alloc] initWithNibName:@"TASimpleListVC" bundle:nil];
	[tagListVC setListMode:ListModeTags];
	[tagListVC setManagedObjectContext:[self appDelegate].managedObjectContext];
	[tagListVC setDelegate:self];
	
	[self.navigationController pushViewController:tagListVC animated:YES];
}


- (NSNumber *)generateRandomNumberWithMax:(int)maxInt {
	
	int value = (arc4random() % maxInt) + 1;
	NSNumber *randomNum = [[NSNumber alloc] initWithInt:value];
	
	return randomNum;
}

- (void)initGetCityApi:(void(^)(BOOL success))completionBlock {

    NSString *latString = [NSString stringWithFormat:@"%f", self.currentLocation.coordinate.latitude];
    NSString *lngString = [NSString stringWithFormat:@"%f", self.currentLocation.coordinate.longitude];
    NSDictionary *params = @{ @"lat" : latString, @"lng" : lngString };
    
    [[GlooRequestManager sharedManager] post:@"getcity"
                                      params:params
                               dataLoadBlock:^(NSDictionary *json) {}
                             completionBlock:^(NSDictionary *json) {
                                 
                                 if ([json[@"result"] isEqualToString:@"ok"]) {
                                 
                                     self.selectedCity = json[@"city"];
                                     [self.cityLabel setText:self.selectedCity];
                                     
                                     completionBlock(YES);
                                 }
                                 
                                 else {
                                 
                                     completionBlock(NO);
                                 }
                             }
                                  viewForHUD:nil];
}


- (IBAction)recommendButtonTapped:(id)sender {
	
	TAUsersVC *usersVC = [[TAUsersVC alloc] initWithNibName:@"TAUsersVC" bundle:nil];
	[usersVC setUsersMode:UsersModeRecommendTo];
	[usersVC setSelectedUsername:[self appDelegate].loggedInUsername];
	[usersVC setDelegate:self];
    
    if (self.recommendToUsernames) {
        [usersVC setSelectedUsers:self.recommendToUsernames];
    }
	
	[self.navigationController pushViewController:usersVC animated:YES];
}


- (void)configureCurrentLocation {
		
    ALAssetsLibrary *assetslibrary = [[ALAssetsLibrary alloc] init];
    __block double latitude;
    __block double longitude;
    
    [assetslibrary assetForURL:self.imageReferenceURL resultBlock:^(ALAsset *asset) {
        
//        NSDictionary *metadata = asset.defaultRepresentation.metadata;
//        NSLog(@"IMAGE METADATA:%@", metadata);
        
        CLLocation *loc = ((CLLocation*)[asset valueForProperty:ALAssetPropertyLocation]);
        
        // Detect if location metadata was attached to the asset
        if (loc == nil) {
        
            NSString *message = @"There was an error retrieving the location of the image. Please make sure location services are enabled for this app in your phone's Settings";
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error retrieving location" message:message
                                                           delegate:self cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil, nil];
            alert.tag = NO_METADATA_TAG;
            [alert show];
            return;
        }
        
        else {
        
            CLLocationCoordinate2D c = loc.coordinate;
            longitude = (double)c.longitude;
            latitude  = (double)c.latitude;
            
            // Make lat/lon easier to reference
            double lat = latitude;
            double lon = longitude;
            
            CLLocation *newCurrentLocation = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
            self.currentLocation = newCurrentLocation;
            
            [self initGetCityApi:^(BOOL success){
            
                if (!success) {
                    
                    self.cityLabel.text = @"Could not detect city. Tap to retry.";
                
                    // Add single tap gesture recognizer 
                    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc]
                                                   initWithTarget:self action:@selector(getCity)];
                    tgr.numberOfTapsRequired = 1;
                    tgr.numberOfTouchesRequired = 1;
                    [self.cityLabel addGestureRecognizer:tgr];
                }
            }];
            
            // Place the current location
            // coordiantes on the map view
            [self initSingleLocation];
        }
        
    } failureBlock:^(NSError *error) {
        
        NSLog(@"error:%@", error);
        
        NSString *errorMessage = @"Could not detect your city.";
        [self.cityLabel setText:errorMessage];
        
        NSString *message = @"There was an error retrieving the location of the image. Please make sure location services are enabled for this app in your phone's Settings";
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error retrieving location" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];			
    }];
}


- (IBAction)editPlaceButtonTapped:(id)sender {
	
	NSNumber *lat = [NSNumber numberWithDouble:self.currentLocation.coordinate.latitude];
	NSNumber *lng = [NSNumber numberWithDouble:self.currentLocation.coordinate.longitude];

	TAPlacesVC *placesVC = [[TAPlacesVC alloc] initWithNibName:@"TAPlacesVC" bundle:nil];
	[placesVC setLatitude:lat];
	[placesVC setLongitude:lng];
	[placesVC setDelegate:self];
	
	[self.navigationController pushViewController:placesVC animated:YES];
}


- (void)initTwitterRequest {
	
	
	// Create an account type that ensures Twitter accounts are retrieved.
	ACAccountType *accountType = [self.savedAccountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
	
	// Request access from the user to use their Twitter accounts.
	[self.savedAccountStore requestAccessToAccountsWithType:accountType withCompletionHandler:^(BOOL granted, NSError *error) {
		if(granted) {
			
			// Get the list of Twitter accounts.
			ACAccount *account = [self.savedAccountStore accountWithIdentifier:self.selectedAccountIdentifier];
			
			if (account) {
				
				// Build a twitter request
				TWRequest *postRequest = [[TWRequest alloc] initWithURL:[NSURL URLWithString:@"https://upload.twitter.com/1/statuses/update_with_media.json"] parameters:nil requestMethod:TWRequestMethodPOST];
				
				//add text
				[postRequest addMultiPartData:[@"Check out this photo I took!" dataUsingEncoding:NSUTF8StringEncoding] withName:@"status" type:@"multipart/form-data"];
				
				//add image
				[postRequest addMultiPartData:UIImageJPEGRepresentation(self.photo, 0.7) withName:@"media" type:@"multipart/form-data"];
				
				NSData *val = [[NSString stringWithFormat:@"true"] dataUsingEncoding:NSUTF8StringEncoding];
				[postRequest addMultiPartData:val withName:@"display_coordinates" type:@"multipart/form-data"];
				
				[postRequest addMultiPartData:[[NSString stringWithFormat:@"%f", self.currentLocation.coordinate.latitude] dataUsingEncoding:NSUTF8StringEncoding] withName:@"lat" type:@"multipart/form-data"];
				
				[postRequest addMultiPartData:[[NSString stringWithFormat:@"%f", self.currentLocation.coordinate.longitude] dataUsingEncoding:NSUTF8StringEncoding] withName:@"long" type:@"multipart/form-data"];
				
				
				// Set the account used to post the tweet.
				[postRequest setAccount:account];
				
				// Block handler to manage the response
				[postRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
					
					if ([urlResponse statusCode] == 200) {
						
						// The response from Twitter is in JSON format
						// Move the response into a dictionary and print
						NSError *error;        
						NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&error];
						NSLog(@"Twitter response: %@", dict);                           
					}
					
					else
						NSLog(@"Twitter error, HTTP response: %i", [urlResponse statusCode]);
				}];
			}
		}	
	}];

	
}



// Convenience method to perform some action that requires the "publish_actions" permissions.
- (void) performPublishAction:(void (^)(void)) action {
    
    // we defer request for permission to post to the moment of post, then we check for the permission
    if ([FBSession.activeSession.permissions indexOfObject:@"publish_actions"] == NSNotFound) {
        
        // if we don't already have the permission, then we request it now
        [FBSession.activeSession reauthorizeWithPublishPermissions:[NSArray arrayWithObject:@"publish_actions"]
                                                   defaultAudience:FBSessionDefaultAudienceFriends
                                                 completionHandler:^(FBSession *session, NSError *error) {
                                                     if (!error) {
                                                         action();
                                                     }
                                                     //For this example, ignore errors (such as if user cancels).
                                                 }];
    } else {
        action();
    }
    
}


// UIAlertView helper for post buttons
- (void)showAlert:(NSString *)message result:(id)result
            error:(NSError *)error {
    
    NSString *alertMsg;
    NSString *alertTitle;
    if (error) {
        alertMsg = error.localizedDescription;
        alertTitle = @"Error";
    } else {
        NSDictionary *resultDict = (NSDictionary *)result;
        alertMsg = [NSString stringWithFormat:@"Successfully posted '%@'.\nPost ID: %@",
                    message, [resultDict valueForKey:@"id"]];
        alertTitle = @"Success";
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:alertTitle
                                                        message:alertMsg
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView setTag:FACEBOOK_ALERT_TAG];
    [alertView show];
}


//
// Currently this method is triggered during the
// the receivedSubmitResponse method - if the photo
// submission to the API was successful.
// It accepts a dictionary of parameters needed to publish
// to the FB user's wall feed. An alert view is displayed upon
// completion of the request.
- (void)publishPhotoToFacebookFeed:(NSMutableDictionary *)postParams {
    
    [FBRequestConnection
     startWithGraphPath:@"me/feed"
     parameters:postParams
     HTTPMethod:@"POST"
     completionHandler:^(FBRequestConnection *connection,
                         id result,
                         NSError *error) {
//         NSString *alertText;
//         if (error) {
//             alertText = [NSString stringWithFormat:
//                          @"error: domain = %@, code = %d",
//                          error.domain, error.code];
//         } else {
//             alertText = [NSString stringWithFormat:
//                          @"Posted action, id: %@",
//                          [result objectForKey:@"id"]];
//         }
         // Show the result in an alert
//         [[[UIAlertView alloc] initWithTitle:@"Result"
//                                     message:alertText
//                                    delegate:self
//                           cancelButtonTitle:@"OK!"
//                           otherButtonTitles:nil]
//          show];
     }];
}


//
// Currently this method is fired once the user
// taps the 'Tweet' button. It's objective is to
// determine whether the current FBSession is 'open'
// If the session is not open it calls 'openSessionWithAllowLoginUI'
// which allows the user to log into FB and/or grant permissions to
// this app.
- (IBAction)checkFacebookSession:(id)sender {
    
    postToFacebook = !postToFacebook;
    
    NSString *imageName = (postToFacebook) ? @"submit-facebook-button-on.png" : @"submit-facebook-button.png";
    UIButton *fbBtn = (UIButton *)sender;
    [fbBtn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    
    if (!postToFacebook)
        return;

    if (!FBSession.activeSession.isOpen) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(facebookSessionAvailable) name:@"facebook_session_available" object:nil];
        [[FacebookHelper sharedHelper] openSessionWithAllowLoginUI:YES];
    }
    else [self checkFacebookPublishPermissions];
}

- (void)facebookSessionAvailable {
    
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"facebook_session_available" object:nil];
	if (FBSession.activeSession.isOpen) {
        
        [self checkFacebookPublishPermissions];
    }
}

- (void)checkFacebookPublishPermissions {
    
    // Ask for publish_actions permissions in context
    if ([FBSession.activeSession.permissions
         indexOfObject:@"publish_actions"] == NSNotFound) {
        
        // No permissions found in session, ask for it
        [FBSession.activeSession
         requestNewPublishPermissions:
         [NSArray arrayWithObject:@"publish_actions"]
         defaultAudience:FBSessionDefaultAudienceFriends
         completionHandler:^(FBSession *session, NSError *error) {
             if (!error) { }
         }];
    }
}


- (void)initAddGuideAPIWithPhoto:(NSString *)photoID guideDetails:(NSMutableDictionary *)guideDetails {
	
	NSString *username = [self appDelegate].loggedInUsername;
	NSString *title = [guideDetails objectForKey:@"title"];
	NSString *city = self.selectedCity;
	NSString *tagID = [NSString stringWithFormat:@"%d", [[self.selectedTag tagID] intValue]];
	NSString *imageIDs = photoID;
	NSString *usernames = @"";
    NSString *privateInt = [guideDetails objectForKey:@"private"];
    NSString *description = [guideDetails objectForKey:@"description"];
	
	if ([self.recommendToUsernames count] > 0)
		usernames = [NSString stringWithFormat:@"&rec_usernames=%@", [self.recommendToUsernames componentsJoinedByString:@","]];
		
    NSDictionary *params;
    if ([self.recommendToUsernames count] > 0)
        params = @{ @"username" : username, @"title" : title, @"description" : description, @"city" : city, @"tag" : tagID, @"imageIDs" :  imageIDs, @"private" : privateInt, @"token" : [self appDelegate].sessionToken, @"rec_usernames" : usernames };
    else
        params = @{ @"username" : username, @"title" : title, @"description" : description, @"city" : city, @"tag" : tagID, @"imageIDs" :  imageIDs, @"private" : privateInt, @"token" : [self appDelegate].sessionToken };
    
    
    [[GlooRequestManager sharedManager] post:@"addguide"
                                      params:params
                               dataLoadBlock:^(NSDictionary *json){}
                             completionBlock:^(NSDictionary *json){
                             
                                 if ([json[@"result"] isEqualToString:@"ok"]) {
                                     
                                     NSLog(@"GUIDE SUCCESSFULLY CREATED!");
                                 }
                                 
                                 else {
                                 
                                     NSLog(@"GUIDE CREATION UNSUCCESSFUL!");
                                 }
                             }
                                  viewForHUD:nil];

}

- (void)sharePhotoOnTwitterWithText:(NSString *)initialText url:(NSURL *)url {
    
    NSString *tweetText = [NSString stringWithFormat:@"Gyde for iOS: %@", initialText];

    //Check for Social Framework availability (iOS 6)
    if(NSClassFromString(@"SLComposeViewController") != nil){
        
        if([SLComposeViewController instanceMethodForSelector:@selector(isAvailableForServiceType)] != nil)
        {
            if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
            {
                SLComposeViewController *composeViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
                [composeViewController setInitialText:tweetText];
                [composeViewController addImage:self.photoView.image];
                [composeViewController addURL:url];
                
                // Sets the completion handler.  Note that we don't know which thread the
                // block will be called on, so we need to ensure that any UI updates occur on the main queue
                composeViewController.completionHandler = ^(SLComposeViewControllerResult result) {
                    switch(result) {
                            //  This means the user cancelled without sending the Tweet
                        case SLComposeViewControllerResultCancelled:
                            break;
                            //  This means the user hit 'Send'
                        case SLComposeViewControllerResultDone:
                            break;
                    }
                    
                    //  dismiss the Tweet Sheet
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self dismissViewControllerAnimated:NO completion:^{
                            NSLog(@"Tweet Sheet has been dismissed.");
                            [self.navigationController popViewControllerAnimated:YES];
                        }];
                    });
                };
                
                // Present
                [self presentViewController:composeViewController animated:YES completion:nil];
            }
            else
            {
                NSString *message = @"You have no Twitter accounts setup on your phone. Please add one via your Settings app and try again.";
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"No accounts" message:message
                                                            delegate:self
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil, nil];
                [av show];
            }
        }
        
        else {
            
            NSString *message = @"You have no Twitter accounts setup on your phone. Please add one via your Settings app and try again.";
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"No accounts" message:message
                                                        delegate:self
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil, nil];
            [av setTag:NO_TWITTER_ACCOUNT_TAG];
            [av show];
        }
    }
    
    else{
        
        // For TWTweetComposeViewController (iOS 5)
        if ([TWTweetComposeViewController canSendTweet]) {
            
            TWTweetComposeViewController *tweetVC = [[TWTweetComposeViewController alloc] init];
            [tweetVC addImage:self.photoView.image];
            [tweetVC setInitialText:tweetText];
            [tweetVC addURL:url];
            
            // Sets the completion handler.  Note that we don't know which thread the
            // block will be called on, so we need to ensure that any UI updates occur on the main queue
            tweetVC.completionHandler = ^(TWTweetComposeViewControllerResult result) {
                
                switch(result) {
                        //  This means the user cancelled without sending the Tweet
                    case TWTweetComposeViewControllerResultCancelled:
                        break;
                        //  This means the user hit 'Send'
                    case TWTweetComposeViewControllerResultDone:
                        break;
                }
                
                //  dismiss the Tweet Sheet
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self dismissViewControllerAnimated:NO completion:^{
                        NSLog(@"Tweet Sheet has been dismissed.");
                        [self.navigationController popViewControllerAnimated:YES];
                    }];
                });
            };

            // Present
            [self presentViewController:tweetVC animated:YES completion:nil];
        }
        
        else {
            
            NSString *message = @"You have no Twitter accounts setup on your phone. Please add one via your Settings app and try again.";
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"No accounts" message:message
                                                        delegate:self
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil, nil];
            [av setTag:NO_TWITTER_ACCOUNT_TAG];
            [av show];
        }
    }

}

@end
