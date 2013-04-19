//
//  TAForgottenPasswordVC.m
//  Tourism App
//
//  Created by Richard Lee on 10/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TAForgottenPasswordVC.h"
#import "AppDelegate.h"
#import "JSONKit.h"
#import "HTTPFetcher.h"
#import "SVProgressHUD.h"

@interface TAForgottenPasswordVC ()

@end

@implementation TAForgottenPasswordVC

@synthesize usernameField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


#pragma mark - Private Methods
- (AppDelegate *)appDelegate {
	
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}


- (void)viewDidLoad {
	
    [super viewDidLoad];
    
	[self initNavBar];
}

- (void)viewDidUnload {
    
    usernameField = nil;
	
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
	if (textField == self.usernameField) {
		
		// Hide the keyboard
        [textField resignFirstResponder];
		
		// Start the "SendPassword" API
		[self initSendPasswordAPI];
	}
    
    return YES;
}


#pragma MY METHODS 

- (void)initNavBar {
	
	self.title = @"FORGOTTEN PASSWORD";
	self.navigationController.navigationBarHidden = NO;
	
}


- (IBAction)goBack:(id)sender {
	
	[self.navigationController popViewControllerAnimated:YES];
}


- (void)initSendPasswordAPI {
	
	[self showLoading];
	
	NSString *jsonString = [NSString stringWithFormat:@"username=%@", self.usernameField.text];
	
	// Convert string to data for transmission
    NSData *jsonData = [jsonString dataUsingEncoding:NSASCIIStringEncoding];
    
    // Create the URL that will be used to authenticate this user
	NSString *methodName = @"SendPassword";
	NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];
    
    // Initialiase the URL Request
    NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:jsonData];
    	
	// JSONFetcher
    sendPasswordfetcher = [[HTTPFetcher alloc] initWithURLRequest:request
											 receiver:self
											   action:@selector(receivedSendPasswordResponse:)];
    [sendPasswordfetcher start];
}


// Example fetcher response handling
- (void)receivedSendPasswordResponse:(HTTPFetcher *)aFetcher {
    
    HTTPFetcher *theJSONFetcher = (HTTPFetcher *)aFetcher;
	
	NSAssert(aFetcher == sendPasswordfetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	BOOL success = NO;
	
	if ([theJSONFetcher.data length] > 0) {
		
		// Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		
		// Create a dictionary from the JSON string
		NSDictionary *results = [jsonString objectFromJSONString];
		
		for (int i = 0; i < [[results allKeys] count]; i++) {
			
			NSString *key = [[results allKeys] objectAtIndex:i];
			NSString *value = [results objectForKey:key];
			
			if ([key isEqualToString:@"result"]) success = (([value isEqualToString:@"ok"]) ? YES : NO);
		}
		
		NSLog(@"FORGOTTEN PASSWORD RESULTS:%@", results);
	}
	
	// Hide loading animation 
	[self hideLoading];
	
	
	NSString *title;
	NSString *message;
	
	// The email address was successfully submitted.
	// Now show the login form.
	if (success) {
		
		title = @"Success!";
		message = @"Please check your email for details on how to change your password.";
	}
	
	else {
		
		title = @"Sorry!";
		message = @"There was an error submitting your email address. Please try again.";
	}
	
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
														message:message
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
	[alertView show];
	
	sendPasswordfetcher = nil;
    
	// Pop back to the root of this navigation controller
	[self.navigationController popToRootViewControllerAnimated:YES];
}


- (void)showLoading {
	
	[SVProgressHUD showInView:self.view status:nil networkIndicator:YES posY:-1 maskType:SVProgressHUDMaskTypeClear];
}


- (void)hideLoading {
	
	[SVProgressHUD dismissWithSuccess:@"Loaded!"];
}

@end
