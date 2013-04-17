//
//  TAShareVC.m
//  Tourism App
//
//  Created by Richard Lee on 28/08/12.
//  Copyright (c) 2012 C2 Media Pty Ltd. All rights reserved.
//

#import "TAShareVC.h"
#import "AppDelegate.h"
#import "SVProgressHUD.h"
#import "JSONKit.h"
#import "HTTPFetcher.h"
#import "StringHelper.h"
#import "XMLFetcher.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "TAUsersVC.h"
#import "TAPlacesVC.h"
#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>
#import "CustomTabBarItem.h"
#import "TAGuidesListVC.h"
#import "MyMapAnnotation.h"

#define SUBMIT_ALERT_TAG 9000
#define MAIN_CONTENT_HEIGHT 367
#define FACEBOOK_ALERT_TAG 10000

@interface TAShareVC ()

@end

@implementation TAShareVC

@synthesize photo, imageReferenceURL, selectedCity, tagLabel, captionField, photoView;
@synthesize currentLocation, selectedTag, cityLabel, recommendToUsernames, placeData, selectedAccountIdentifier;
@synthesize placeTitleLabel, scrollView, twitterAccounts, savedAccountStore;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
	
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    
    // Remove top padding from caption text view
    //self.captionField.contentInset = UIEdgeInsetsMake(-8,-8,0,0);
    [self.captionField becomeFirstResponder];
    
	
	// Place the photo within the polaroid
	// image view
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
	self.twitterAccounts = nil;
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


#pragma UIActionSheetDelegate methods 

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	/*
		Determine the title of the twitter account
		that was selected from the UIActionSheet
	*/
	
	if (buttonIndex != 0) {
		
		//NSString *btnTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
		NSLog(@"retain count:%i", [self.twitterAccounts count]);
		
		
		// Grab the initial Twitter account to tweet from.
//		ACAccount *twitterAccount = [self.twitterAccounts objectAtIndex:(buttonIndex-1)];
//		
//		self.selectedAccountIdentifier = twitterAccount.identifier;
//		
//		NSString *userID = [[twitterAccount accountProperties] objectForKey:@"user_id"];
//		NSLog(@"ACC ID:%@", userID);
//		
//		[[self appDelegate] setTwitterUsername:twitterAccount.username];
//		[[self appDelegate] setTwitterUserID:userID];
//		[[self appDelegate] setTwitterAccountID:self.selectedAccountIdentifier];
//		
//		// Update the user's profile with the twitter user id
//		[self initUpdateProfileAPI:userID];
	}

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
	
	if (submissionSuccess && alertView.tag == SUBMIT_ALERT_TAG) [self.navigationController popViewControllerAnimated:YES];
    
    else if (alertView.tag == FACEBOOK_ALERT_TAG) [self.navigationController popViewControllerAnimated:YES];
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
}


#pragma TagsDelegate

- (void)tagSelected:(Tag *)tag {
	
	// Set the selected Tag
	[self setSelectedTag:tag]; 
	
	// Set the Tag button's title to that of the Location's
	[self.tagLabel setText:tag.title];
}



#pragma MY METHODS 

- (IBAction)goBack:(id)sender {

	[self.navigationController popViewControllerAnimated:YES];
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

    self.shareOnTwitter = !self.shareOnTwitter;
}


- (IBAction)submitPhoto:(id)sender {
	
	// Check that a Tag and a Location have been assigned
	if (self.selectedTag && self.selectedCity) {
				
		// Create the URL for this request
		NSString *methodName = @"Submit";
        
        NSString *username = [[self appDelegate] loggedInUsername];
        NSString *token = [[self appDelegate] sessionToken];
        NSString *latString = [NSString stringWithFormat:@"%f", self.currentLocation.coordinate.latitude];
        NSString *lonString = [NSString stringWithFormat:@"%f", self.currentLocation.coordinate.longitude];
        NSString *tagString = [NSString stringWithFormat:@"%i", [self.selectedTag.tagID intValue]];
        NSString *cityString = [NSString stringWithFormat:@"%@", self.selectedCity];
        
        NSNumber *randomNum = [self generateRandomNumberWithMax:100000];
        NSString *imageFilename = [NSString stringWithFormat:@"%i.jpg", [randomNum intValue]];
        
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
                
                if ([key isEqualToString:@"address"]) {
                    
                    [params setObject:val forKey:@"place_address"];
                }
                
                if ([key isEqualToString:@"city"]) {
                    
                    [params setObject:val forKey:@"place_city"];
                }
                
                if ([key isEqualToString:@"state"]) {
                    
                    [params setObject:val forKey:@"place_state"];
                }
                
                if ([key isEqualToString:@"country"]) {
                    
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
                
		
		[[GlooRequestManager sharedManager] post:methodName image:self.photo
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
                                         
                                         if (self.shareOnTwitter) {
                                         
                                             NSString *initialText = @"";//[NSString stringWithFormat:@"Via Gyde for iOS: %@", currPhoto.venue.title];
                                             [self sharePhotoOnTwitterWithText:initialText];
                                         }
                                         
                                         if (postToFacebook) {
                                             
                                             // Post a status update to the user's feed via the Graph API, and display an alert view
                                             // with the results or an error.
                                             //NSString *name = [[User userWithUsername:[self appDelegate].loggedInUsername inManagedObjectContext:[self appDelegate].managedObjectContext] fullName];
                                             
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
                                         
                                         NSString *message = @"Your photo was successfully submitted.";
                                         UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Success!"
                                                                                             message:message
                                                                                            delegate:self
                                                                                   cancelButtonTitle:@"OK"
                                                                                   otherButtonTitles:nil];
                                         [alertView setTag:SUBMIT_ALERT_TAG];
                                         [alertView show];
                                         
                                     }
                                     
                                     else {
                                     
                                         NSLog(@"ERROR: %@", json);
                                     }
                                 }
                                      viewForHUD:self.view];
	}
	
	else {
		
		NSString *message = @"Your image cannot be submitted until a city has been assigned and you have selected an acitivity.";
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry!" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
		[alert show];
	}
}


- (NSMutableURLRequest *)createSubmitRequest:(NSURL *)requestURL {
	
	NSMutableURLRequest *request =(NSMutableURLRequest*)[NSMutableURLRequest requestWithURL:requestURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
	[request setHTTPMethod:@"POST"];	
	
	/*
	 Set Header and content type of your request.
	 */
	NSString *boundary = @"---------------------------14737809831466499882746641449";
	NSString *boundaryString = [NSString stringWithFormat:@"\r\n--%@\r\n",boundary];
	NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
	[request addValue:contentType forHTTPHeaderField: @"Content-Type"];
	
	
	/*
	 now lets create the body of the request.
	 */
	NSMutableData *body = [NSMutableData data];
	[body appendData:[boundaryString dataUsingEncoding:NSUTF8StringEncoding]];
	
	
	NSMutableDictionary *bodyData = [NSMutableDictionary dictionary];
	
	// Caption
	[bodyData setObject:self.captionField.text forKey:@"caption"];
	
	// Username
	NSString *username = [[self appDelegate] loggedInUsername];
	[bodyData setObject:username forKey:@"username"];
	
	// Session token
	NSString *token = [[self appDelegate] sessionToken];
	[bodyData setObject:token forKey:@"token"];
	
	// Latitude
	NSString *latString = [NSString stringWithFormat:@"%f", self.currentLocation.coordinate.latitude];
	[bodyData setObject:latString forKey:@"latitude"];
	
	// Longitude
	NSString *lonString = [NSString stringWithFormat:@"%f", self.currentLocation.coordinate.longitude];
	[bodyData setObject:lonString forKey:@"longitude"];
	
	
	// RECOMMEND?
	if ([self.recommendToUsernames count] > 0) {
		
		NSString *recType = [NSString stringWithFormat:@"%i", 0];
		[bodyData setObject:recType forKey:@"rectype"];
		
		NSString *usernames = [NSString stringWithFormat:@"%@", [self.recommendToUsernames componentsJoinedByString:@","]];
		[bodyData setObject:usernames forKey:@"rec_usernames"];
	}
	
	
	if (self.placeData) {
	
		NSDictionary *locationData = [self.placeData objectForKey:@"location"];
	
		NSString *placeTitle = [self.placeData objectForKey:@"name"];
		[bodyData setObject:placeTitle forKey:@"place_title"];
		
		NSString *address = [locationData objectForKey:@"address"];
		[bodyData setObject:address forKey:@"place_address"];
		
		NSString *city = [locationData objectForKey:@"city"];
		[bodyData setObject:city forKey:@"place_city"];
		
		NSString *state = [locationData objectForKey:@"state"];
		[bodyData setObject:state forKey:@"place_state"];
		
		NSString *country = [locationData objectForKey:@"country"];
		[bodyData setObject:country forKey:@"place_country"];
		
		NSString *postalCode = [locationData objectForKey:@"postalCode"];
		[bodyData setObject:postalCode forKey:@"place_postcode"];
		
		NSString *verified = [self.placeData objectForKey:@"verified"];
		[bodyData setObject:verified forKey:@"verified"];
	}
	
	
	// Tag
	NSString *tagString = [NSString stringWithFormat:@"%i", [self.selectedTag.tagID intValue]];
	[bodyData setObject:tagString forKey:@"tag"];
	
	// City
	NSString *cityString = [NSString stringWithFormat:@"%@", self.selectedCity];
	[bodyData setObject:cityString forKey:@"city"];
	
	// Type
	[bodyData setObject:@"image" forKey:@"type"];
	
	
	// Loop through the keys of the dictionary of body data
	// and add to the body of the request with the data properly formatted
	NSArray *keys = [bodyData allKeys];
	
	for (int i = 0; i < [keys count]; i++) {
		
		NSString *key = [keys objectAtIndex:i];
		NSString *val = [bodyData objectForKey:key];
	
		NSString *formattedStr = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n%@", key, val];
	
		[body appendData:[formattedStr dataUsingEncoding:NSUTF8StringEncoding]];
		[body appendData:[boundaryString dataUsingEncoding:NSUTF8StringEncoding]];
	} 
	
	
	// IMAGE
	NSNumber *randomNum = [self generateRandomNumberWithMax:100000];
	NSString *imageFilename = [NSString stringWithFormat:@"%i", [randomNum intValue]];
	[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"file\"; filename=\"%@.jpg\"\r\n", imageFilename] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithString:@"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[NSData dataWithData:UIImageJPEGRepresentation(self.photo, 0.7)]];
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	
	[request setHTTPBody:body];
	[request setValue:[NSString stringWithFormat:@"%d", [body length]] forHTTPHeaderField:@"Content-Length"]; 
	
	return request;
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


- (IBAction)shareButtonTapped:(id)sender {
    
	/* 
		Retrieve the stored Twitter accounts 
		on this phone and detect whether any 
		of them have had access granted to this user
		to be used 
	*/
    
	ACAccountStore *accountStore = [[ACAccountStore alloc] init];
	self.savedAccountStore = accountStore;
	
	// Create an account type that ensures Twitter accounts are retrieved.
	ACAccountType *accountType = [self.savedAccountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
	
	self.twitterAccounts = [NSMutableArray array];
	
	// Request access from the user to use their Twitter accounts.
	[self.savedAccountStore requestAccessToAccountsWithType:accountType withCompletionHandler:^(BOOL granted, NSError *error) {
		if(granted) {
	
			// Get the list of Twitter accounts.
			self.twitterAccounts = [self.savedAccountStore accountsWithAccountType:accountType];
			
			if ([self.twitterAccounts count] > 0) {
                
				[self performSelectorOnMainThread:@selector(presentTwitterAccountsSheet:) withObject:self.twitterAccounts waitUntilDone:NO];
			}
            
            else {
            
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"No accounts" message:@"You need to setup a Twitter account in your Twitter app in order to use this functionality." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [av show];
            }
		}	
	}];
}


- (void)presentTwitterAccountsSheet:(NSArray *) accountsArray {
	
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose an option" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"Cancel" otherButtonTitles:nil];
	
	for (ACAccount *account in self.twitterAccounts) {
		
		NSString *accountTitle = account.accountDescription;
		[actionSheet addButtonWithTitle:accountTitle];
	}
	
	[actionSheet showFromTabBar:self.parentViewController.tabBarController.tabBar];
}


- (NSNumber *)generateRandomNumberWithMax:(int)maxInt {
	
	int value = (arc4random() % maxInt) + 1;
	NSNumber *randomNum = [[NSNumber alloc] initWithInt:value];
	
	return randomNum;
}


- (void)startReverseGeocoding {

    if (!self.reverseGeocoder)
        self.reverseGeocoder = [[CLGeocoder alloc] init];
    
    [self.reverseGeocoder reverseGeocodeLocation:self.currentLocation
                               completionHandler:^(NSArray *placemarks, NSError *error) {
                                   
                                   if (!error) {
                                       
                                       //Get nearby address
                                       CLPlacemark *placemark = [placemarks objectAtIndex:0];
                                       
                                       if (placemark.subLocality)
                                           self.selectedCity = placemark.subLocality;
                                       else if (placemark.locality)
                                           self.selectedCity = placemark.locality;
                                       
                                       if (self.selectedCity)
                                           [self.cityLabel setText:self.selectedCity];
                                       else {
                                           
                                           UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Location error" message:@"There was an error calculating your current city. Please check your network connection." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                           [av show];
                                       }
                                   }
                                   
                                   else {
                                       
                                       UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Location error" message:@"There was an error calculating your current city. Please check your network connection." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                       [av show];
                                   }
                                   
                               }];
}


- (void)retrieveLocationData {
	
	// Create JSON call to retrieve dummy City values
	NSString *methodName = @"geocode";
	NSString *yahooURL = @"http://where.yahooapis.com/";
	NSString *yahooAPIKey = @"UvRWaq30";
	
	NSString *urlString = [NSString stringWithFormat:@"%@%@?q=%f,%f&gflags=R&appid=%@", yahooURL, methodName, self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude, yahooAPIKey];
	//NSLog(@"YAHOO URL:%@", urlString);
	
	NSURL *url = [urlString convertToURL];
	
	// Create the request.
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
														   cachePolicy:NSURLRequestUseProtocolCachePolicy
													   timeoutInterval:45.0];
	[request setValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
	[request setHTTPMethod:@"GET"];
    
    if (cityFetcher) {
        
		[cityFetcher cancel];
		cityFetcher = nil;
	}
	
	// XML Fetcher
	cityFetcher = [[XMLFetcher alloc] initWithURLRequest:request xPathQuery:@"//ResultSet" receiver:self action:@selector(receivedYahooResponse:)];
	[cityFetcher start];
}


// Example fetcher response handling
- (void)receivedYahooResponse:(XMLFetcher *)aFetcher {
    
    if (![aFetcher isEqual:cityFetcher])
        return;
	
	BOOL requestSuccess = NO;
	BOOL errorDected = NO;
	
	//NSLog(@"PRINTING YAHOO DATA:%@",[[NSString alloc] initWithData:theXMLFetcher.data encoding:NSASCIIStringEncoding]);
	
	// IF STATUS CODE WAS OKAY (200)
	if ([cityFetcher statusCode] == 200) {
		
		// XML Data was returned from the API successfully
		if (([cityFetcher.data length] > 0) && ([cityFetcher.results count] > 0)) {
			
			requestSuccess = YES;
			
			XPathResultNode *versionsNode = [cityFetcher.results lastObject];
			
			// loop through the children of the <registration> node
			for (XPathResultNode *child in versionsNode.childNodes) {
				
				if ([[child name] isEqualToString:@"ErrorMessage"]) {
					
					errorDected = ([[child contentString] isEqualToString:@"No error"] ? NO : YES);
				}
				
				else if ([[child name] isEqualToString:@"Result"]) {
					
					for (XPathResultNode *childNode in child.childNodes) {
						
						if ([[childNode name] isEqualToString:@"city"] && [[childNode contentString] length] > 0) { 
							
							self.selectedCity = [childNode contentString];
						}
					}
				}
			}
		}
	}
	
	if (requestSuccess && !errorDected && [self.selectedCity length] > 0) {
		
		[self.cityLabel setText:[NSString stringWithFormat:@"We have detected that you are in %@.", self.selectedCity]];
	}
	else {
    
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Location error" message:@"There was an error calculating your current city. Please check your network connection." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [av show];
    }
	   
    cityFetcher = nil;
	
}


- (IBAction)recommendButtonTapped:(id)sender {
	
	TAUsersVC *usersVC = [[TAUsersVC alloc] initWithNibName:@"TAUsersVC" bundle:nil];
	[usersVC setUsersMode:UsersModeRecommendTo];
	[usersVC setSelectedUsername:[self appDelegate].loggedInUsername];
	[usersVC setDelegate:self];
	
	[self.navigationController pushViewController:usersVC animated:YES];
}


- (void)configureCurrentLocation {

	if (self.imageReferenceURL != nil) {
		
		ALAssetsLibrary *assetslibrary = [[ALAssetsLibrary alloc] init];
		__block double latitude;
		__block double longitude;
		
		NSLog(@"referenceURL:%@", self.imageReferenceURL);
		
		[assetslibrary assetForURL:self.imageReferenceURL resultBlock:^(ALAsset *asset) {
			
            NSDictionary *metadata = asset.defaultRepresentation.metadata;
            NSLog(@"IMAGE METADATA:%@", metadata);
			CLLocation *loc = ((CLLocation*)[asset valueForProperty:ALAssetPropertyLocation]);
			CLLocationCoordinate2D c = loc.coordinate;
			longitude = (double)c.longitude;
			latitude  = (double)c.latitude;
			
			// Make lat/lon easier to reference
			double lat = latitude;
			double lon = longitude;
			
			CLLocation *newCurrentLocation = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
			self.currentLocation = newCurrentLocation;
			
			NSLog(@"RETRIEVE LOCATION DATA");
			[self startReverseGeocoding];
            
			// Place the current location
			// coordiantes on the map view
			[self initSingleLocation];
			
		} failureBlock:^(NSError *error) {
			
			NSLog(@"error:%@", error);
			
			NSString *errorMessage = @"Could not detect your city.";
			[self.cityLabel setText:errorMessage];
			
			NSString *message = @"There was an error retrieving the location of the image. Please make sure location services are enabled for this app in your phone's Settings";
			
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error retrieving location" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
			[alert show];			
		}];
	}
	
	else {
		
		NSLog(@"RETRIEVE LOCATION DATA NOW");
		[self startReverseGeocoding];
        
        // Place the current location
        // coordiantes on the map view
        [self initSingleLocation];
	}
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


- (void)initUpdateProfileAPI:(NSString *)twt_userid {
	
	NSString *postString = [NSString stringWithFormat:@"username=%@&twt_userid=%@&token=%@", [self appDelegate].loggedInUsername, twt_userid, [self appDelegate].sessionToken];
	
	NSData *postData = [NSData dataWithBytes:[postString UTF8String] length:[postString length]];
	
	// Create the URL that will be used to authenticate this user
	NSString *methodName = @"UpdateProfile";
	NSString *urlString = [NSString stringWithFormat:@"%@%@", API_ADDRESS, methodName];
	
	// Print the URL to the console
	NSLog(@"URL:%@", urlString);
	
	NSURL *url = [urlString convertToURL];
	
	// Initialiase the URL Request
	NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:postData];
	
	// HTTPFetcher
	updateProfileFetcher = [[HTTPFetcher alloc] initWithURLRequest:request
														  receiver:self action:@selector(receivedUpdateProfileResponse:)];
	[updateProfileFetcher start];
	
	////////////////////////////////////////////////////////////////////////////////
}


// Example fetcher response handling
- (void)receivedUpdateProfileResponse:(HTTPFetcher *)aFetcher {
    
    HTTPFetcher *theJSONFetcher = (HTTPFetcher *)aFetcher;
	
	//NSLog(@"UPDATE PROFILE DETAILS:%@",[[NSString alloc] initWithData:theJSONFetcher.data encoding:NSASCIIStringEncoding]);
    
	NSAssert(aFetcher == updateProfileFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	NSInteger statusCode = [theJSONFetcher statusCode];
	
	if ([theJSONFetcher.data length] > 0 && statusCode == 200) {
		
		// Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		
		// Create a dictionary from the JSON string
		NSDictionary *results = [jsonString objectFromJSONString];
	}
	
	updateProfileFetcher = nil;
 }


- (void)verifyTwitterCredentials:(ACAccount *)twitterAccount {

	//NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:@"richC2", @"username", @"chevy78!rfl", @"password", nil];
	
	// Send off a account/verify_credentials request
	TWRequest *verifyRequest = [[TWRequest alloc] initWithURL:[NSURL URLWithString:@"https://api.twitter.com/1.1/account/verify_credentials.json"] parameters:nil requestMethod:TWRequestMethodGET];
	
	// Set the account used to post the tweet.
	[verifyRequest setAccount:twitterAccount];
	
	// Block handler to manage the response
	[verifyRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
		
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


// Post Photo button handler; will attempt to invoke the native
// share dialog and, if that's unavailable, will post directly
/*- (IBAction)postPhotoClick:(UIButton *)sender {
 
    // Just use the icon image from the application itself.  A real app would have a more
    // useful way to get an image.
    UIImage *img = [UIImage imageNamed:@"Icon@2x.png"];
    
    // if it is available to us, we will post using the native dialog
    BOOL displayedNativeDialog = [FBNativeDialogs presentShareDialogModallyFrom:self
                                                                    initialText:nil
                                                                          image:img
                                                                            url:nil
                                                                        handler:nil];
    if (!displayedNativeDialog) {
        [self performPublishAction:^{
            
            [FBRequestConnection startForUploadPhoto:img
                                   completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                       [self showAlert:@"Photo Post" result:result error:error];
                                   }];
        }];
    }
}*/

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
         NSString *alertText;
         if (error) {
             alertText = [NSString stringWithFormat:
                          @"error: domain = %@, code = %d",
                          error.domain, error.code];
         } else {
             alertText = [NSString stringWithFormat:
                          @"Posted action, id: %@",
                          [result objectForKey:@"id"]];
         }
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
    
    postToFacebook = YES;

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

- (IBAction)initFacebookLogin:(id)sender {

    // get the app delegate so that we can access the session property
    AppDelegate *appDelegate = [self appDelegate];
    
    // this button's job is to flip-flop the session from open to closed
    if (appDelegate.session.isOpen) {
        
        // if a user logs out explicitly, we delete any cached token information, and next
        // time they run the applicaiton they will be presented with log in UX again; most
        // users will simply close the app or switch away, without logging out; this will
        // cause the implicit cached-token login to occur on next launch of the application
        [appDelegate.session closeAndClearTokenInformation];
        
    } else {
        
        if (appDelegate.session.state != FBSessionStateCreated) {
            // Create a new, logged out session.
            appDelegate.session = [[FBSession alloc] init];
        }
        
        // if the session isn't open, let's open it now and present the login UX to the user
        [appDelegate.session openWithCompletionHandler:^(FBSession *session,
                                                         FBSessionState status,
                                                         NSError *error) {
            [self displayLoginResult];
        }];
    }
}


- (void)displayLoginResult {

    // get the app delegate, so that we can reference the session property
    AppDelegate *appDelegate = [self appDelegate];
    
    NSString *title;
    NSString *message;
    
    if (appDelegate.session.isOpen) {
        
        title = @"You are logged-in";
        message = @"You successfully established a FB session.";
    }
    else {
        
        title = @"You are NOT logged-in";
        message = @"Something went wrong with FB.";
    }
    
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [av show];
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
	
	//NSString *postString = [NSString stringWithFormat:@"username=%@&title=%@&city=%@&tag=%i&imageIDs=%@&private=%i&token=%@%@", username, title, city, tagID, imageIDs, privateInt, [self appDelegate].sessionToken, usernames];
	
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

- (void)sharePhotoOnTwitterWithText:(NSString *)initialText {

    //Check for Social Framework availability (iOS 6)
    if(NSClassFromString(@"SLComposeViewController") != nil){
        
        if([SLComposeViewController instanceMethodForSelector:@selector(isAvailableForServiceType)] != nil)
        {
            if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
            {
                NSLog(@"service available");
                SLComposeViewController *composeViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
                [composeViewController setInitialText:initialText];
                [composeViewController addImage:self.photoView.image];
                [self presentViewController:composeViewController animated:YES completion:nil];
            }
            else
            {
                NSLog(@"service not available!");
            }
        }
    }
    
    else{
        
        // For TWTweetComposeViewController (iOS 5)
        if ([TWTweetComposeViewController canSendTweet]) {
            TWTweetComposeViewController *tweetVC = [[TWTweetComposeViewController alloc] init];
            [tweetVC addImage:self.photoView.image];
            [tweetVC setInitialText:initialText];
            [self presentModalViewController:tweetVC animated:YES];
        }
        
        else {
            
            NSString *message = @"You have no Twitter accounts setup on your phone. Please add one via your Settings app and try again.";
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"No accounts" message:message
                                                        delegate:self
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil, nil];
            [av show];
        }
    }

}

@end
