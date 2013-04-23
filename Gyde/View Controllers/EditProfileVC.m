//
//  EditProfileVC.m
//  GiftHype
//
//  Created by Richard Lee on 15/05/12.
//  Copyright (c) 2012 C2 Media Pty Ltd. All rights reserved.
//

#import "EditProfileVC.h"
#import "User.h"
#import "StringHelper.h"
#import "HTTPFetcher.h"
#import "JSONKit.h"
#import "SVProgressHUD.h"
#import "Constants.h"

#define MAIN_CONTENT_HEIGHT 367

static NSString *kUserDefaultCityKey = @"userDefaultCityKey";

@interface EditProfileVC ()

@end

@implementation EditProfileVC

@synthesize managedObjectContext, formScrollView, currentTextField, bioView;
@synthesize emailField, cityBtn;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	
    if (self) {
        
		self.title = @"Edit profile";
    }
    return self;
}

- (void)viewDidLoad {
	
    [super viewDidLoad];
    
    self.bioView.contentInset = UIEdgeInsetsMake(-4, -8, 0, 0);
	
	CGSize newSize = CGSizeMake(self.formScrollView.frame.size.width, 267.0);
	[self.formScrollView setContentSize:newSize];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {

	// Assign this text field as the new 'current' text field
	self.currentTextField = textView;
	
	// Reset the height of the Table's frame
	CGRect newTableFrame = self.formScrollView.frame;
	newTableFrame.size.height = (MAIN_CONTENT_HEIGHT - (KEYBOARD_HEIGHHT - TAB_BAR_HEIGHT));
	[self.formScrollView setFrame:newTableFrame];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {  
	
	BOOL shouldChangeText = YES; 
	
	if ([text isEqualToString:@"\n"]) {  
		
		shouldChangeText = NO;
        
        // Adjust searchTable's frame height
		CGRect newFrame = self.formScrollView.frame;
		newFrame.size.height = MAIN_CONTENT_HEIGHT;
		[self.formScrollView setFrame:newFrame];
		
		// Hide the keyboard
		[textView resignFirstResponder];  
	}  
	
	return shouldChangeText;  
}


#pragma mark - Private Methods
- (AppDelegate *)appDelegate {
	
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}


- (void)viewDidUnload {
	
	self.avatarView = nil;
	
	self.bioView = nil;
	self.managedObjectContext = nil;
	
	self.formScrollView = nil;
    
	self.emailField = nil;
	
	self.currentTextField = nil;
	cityBtn = nil;
	
    [self setNameField:nil];
    [self setCityLabel:nil];
    [super viewDidUnload];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)viewWillAppear:(BOOL)animated {

	[super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
	
	if (!loading && !profileLoaded) {
		
		[self showLoading];
		
		[self fetchProfileDetails];
	}
}


// For responding to the user accepting a newly-captured picture or movie
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    
	// Handle a still image capture
	if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0) == kCFCompareEqualTo) {
		
		UIImage *selectedImage = [info objectForKey: UIImagePickerControllerOriginalImage];
		
		self.avatarView.image = selectedImage;
        
        newAvatarSelected = YES;
	}
    
    [self dismissModalViewControllerAnimated:YES];
}


- (void)textFieldDidBeginEditing:(UITextField *)textField {
	
	// Assign this text field as the new 'current' text field
	self.currentTextField = textField;
	
	// Reset the height of the Table's frame
	CGRect newTableFrame = self.formScrollView.frame;
	newTableFrame.size.height = (MAIN_CONTENT_HEIGHT - (KEYBOARD_HEIGHHT - TAB_BAR_HEIGHT));
	[self.formScrollView setFrame:newTableFrame];
}


#pragma mark - UITextField delegations
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	
	// Submit comment to the API
	if (self.currentTextField == self.bioView) {
		
		// Adjust searchTable's frame height
		CGRect newFrame = self.formScrollView.frame;
		newFrame.size.height = MAIN_CONTENT_HEIGHT;
		[self.formScrollView setFrame:newFrame];
		
		// Hide keyboard
		[self.currentTextField resignFirstResponder];
	}
	
	else {
		
		// Using the text field tag - retrieve the next field in the form 
		// and make it the first responder
		UITextField *nextField = (UITextField *)[self.formScrollView viewWithTag:(textField.tag+1)];
		[nextField becomeFirstResponder];
	}
    
    return YES;
}


#pragma CitiesDelegate

- (void)locationSelected:(City *)city {
		
	[self.cityLabel setText:[city title]];
}


- (IBAction)goBack:(id)sender {

	[self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)saveButtonTapped:(id)sender {
	
	// Adjust searchTable's frame height
	CGRect newFrame = self.formScrollView.frame;
	newFrame.size.height = MAIN_CONTENT_HEIGHT;
	[self.formScrollView setFrame:newFrame];
	
	// Hide the keyboard
	[self.currentTextField resignFirstResponder];
	
	// Show loading animation
	[self showLoading];

	// Assemble relevant data from the text fields ////////////////////////////////////
	NSString *name = self.nameField.text;
	NSString *email = self.emailField.text;
	NSString *bio = self.bioView.text;
    NSString *city = self.cityLabel.text;
    
    
    // Set Header and content type of your request.
    NSString *boundary = @"---------------------------14737809831466499882746641449";
	NSString *boundaryString = [NSString stringWithFormat:@"\r\n--%@\r\n",boundary];
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    NSURL *url = [[self appDelegate] createRequestURLWithMethod:@"UpdateProfile" testMode:NO];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
	[request setHTTPMethod:@"POST"];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
		
    // now lets create the body of the request.
	NSMutableData *body = [NSMutableData data];
	[body appendData:[boundaryString dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSMutableDictionary *bodyData = [NSMutableDictionary dictionary];
    
    // Username
	NSString *usernameString = [NSString stringWithFormat:@"%@", [self appDelegate].loggedInUsername];
	[bodyData setObject:usernameString forKey:@"username"];

	// name
	[bodyData setObject:name forKey:@"name"];
	
	// emailaddress
	[bodyData setObject:email forKey:@"emailaddress"];
    
	// bio
	[bodyData setObject:bio forKey:@"bio"];
    
	// city
	[bodyData setObject:city forKey:@"city"];
    
	// Session token
	NSString *token = [[self appDelegate] sessionToken];
	[bodyData setObject:token forKey:@"token"];
    
    
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
    
    
	// AVATAR IMAGE
    if (newAvatarSelected) {
        
        NSNumber *randomNum = [self generateRandomNumberWithMax:100000];
        NSString *imageFilename = [NSString stringWithFormat:@"%i", [randomNum intValue]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"file\"; filename=\"%@.jpg\"\r\n", imageFilename] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[NSData dataWithData:UIImageJPEGRepresentation(self.avatarView.image, 0.7)]];
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
	[request setHTTPBody:body];
	[request setValue:[NSString stringWithFormat:@"%d", [body length]] forHTTPHeaderField:@"Content-Length"];
	
    
	// JSONFetcher
	updateProfileFetcher = [[HTTPFetcher alloc] initWithURLRequest:request
													receiver:self action:@selector(receivedUpdateProfileResponse:)];
	[updateProfileFetcher start];
}


- (NSNumber *)generateRandomNumberWithMax:(int)maxInt {
	
	int value = (arc4random() % maxInt) + 1;
	NSNumber *randomNum = [[NSNumber alloc] initWithInt:value];
	
	return randomNum;
}


// Example fetcher response handling
- (void)receivedUpdateProfileResponse:(HTTPFetcher *)aFetcher {
    
    HTTPFetcher *theJSONFetcher = (HTTPFetcher *)aFetcher;
	
	//NSLog(@"UPDATE PROFILE DETAILS:%@",[[NSString alloc] initWithData:theJSONFetcher.data encoding:NSASCIIStringEncoding]);
    
	NSAssert(aFetcher == updateProfileFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	loading = NO;
    
    BOOL success = NO;
	
	NSInteger statusCode = [theJSONFetcher statusCode];
	
	if ([theJSONFetcher.data length] > 0 && statusCode == 200) {
		
		// Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		
		// Create a dictionary from the JSON string
		NSDictionary *results = [jsonString objectFromJSONString];
		
		// If the request was successful
		if ([[results objectForKey:@"result"] isEqualToString:@"ok"]) {
            
            success = YES;
		
			// A default city has just been selected. Store it.
			if ([self.cityLabel.text length] > 0)
				[[NSUserDefaults standardUserDefaults] setObject:self.cityLabel.text forKey:kUserDefaultCityKey];
		}
	}
	
	// Hide loading view
	[self hideLoading];
    
    NSString *alertTitle;
    NSString *message;
    
    if (!success) {
    
        alertTitle = @"Update profile error";
        message = @"There was an error updating your profile. Please check your network connection and try again.";
    }
    
    else {
        
        alertTitle = @"Update profile success";
        message = @"You successfully updated your profile.";
    }
    
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:alertTitle message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [av show];
	
	updateProfileFetcher = nil;
    
}


- (void)fetchProfileDetails {
	
	NSString *postString = [NSString stringWithFormat:@"username=%@", [self appDelegate].loggedInUsername];
	NSData *postData = [NSData dataWithBytes:[postString UTF8String] length:[postString length]];
	
	// Create the URL that will be used to authenticate this user
	NSString *methodName = @"Profile";
	NSString *urlString = [NSString stringWithFormat:@"%@%@", API_ADDRESS, methodName];
	
	NSURL *url = [urlString convertToURL];
	
	// Initialiase the URL Request
	NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:postData];
	
	// JSONFetcher
	profileFetcher = [[HTTPFetcher alloc] initWithURLRequest:request
											 receiver:self action:@selector(receivedProfileResponse:)];
	[profileFetcher start];
}


// Example fetcher response handling
- (void)receivedProfileResponse:(HTTPFetcher *)aFetcher {
    
    HTTPFetcher *theJSONFetcher = (HTTPFetcher *)aFetcher;
	
	//NSLog(@"DETAILS:%@",[[NSString alloc] initWithData:theJSONFetcher.data encoding:NSASCIIStringEncoding]);
    
	NSAssert(aFetcher == profileFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	loading = NO;
	profileLoaded = YES;
	
	NSInteger statusCode = [theJSONFetcher statusCode];
	
	if ([theJSONFetcher.data length] > 0 && statusCode == 200) {
		
		// Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		
		// Create a dictionary from the JSON string
		NSDictionary *results = [jsonString objectFromJSONString];
		
		// Build an array from the dictionary for easy access to each entry
		NSDictionary *newUserData = [results objectForKey:@"user"];
		
		self.nameField.text = [newUserData objectForKey:@"name"];
		self.emailField.text = [newUserData objectForKey:@"email"];
		
		NSString *bioText = [newUserData objectForKey:@"bio"];
		if (!([bioText isEqual:[NSNull null]]) && [bioText length] > 0)
            self.bioView.text = bioText;
		
		NSString *selectedCity = [newUserData objectForKey:@"city"];
		if (!([selectedCity isEqual:[NSNull null]]) && [selectedCity length] > 0)
            [self.cityLabel setText:selectedCity];
	}
	
	// Hide loading view
	[self hideLoading];
    
	profileFetcher = nil;
    
}


- (void)showLoading {
	
	[SVProgressHUD showInView:self.view status:nil networkIndicator:YES posY:-1 maskType:SVProgressHUDMaskTypeClear];
}


- (void)hideLoading {
	
	[SVProgressHUD dismissWithSuccess:@"Loaded!"];
}


- (void)willLogout {
    
    [self.navigationController popToRootViewControllerAnimated:NO];
}


- (IBAction)selectCityButtonTapped:(id)sender {
	
	TACitiesListVC *citiesListVC = [[TACitiesListVC alloc] initWithNibName:@"TACitiesListVC" bundle:nil];
	[citiesListVC setDelegate:self];
	
	[self.navigationController pushViewController:citiesListVC animated:YES];
}


- (IBAction)photoLibraryButtonTapped:(id)sender {
    
    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
	picker.allowsEditing = YES;
	picker.delegate = self;
	picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.navigationBarHidden = YES;
	
    [self presentModalViewController:picker animated:NO];
}



@end
