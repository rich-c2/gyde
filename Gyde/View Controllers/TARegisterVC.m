//
//  TARegisterVC.m
//  Tourism App
//
//  Created by Richard Lee on 10/09/12.
//  Copyright (c) 2012 C2 Media Pty Ltd. All rights reserved.
//

#import "TARegisterVC.h"
#import "AppDelegate.h"
#import "SVProgressHUD.h"
#import "JSONKit.h"
#import "HTTPFetcher.h"
#import "Constants.h"
#import "TACitiesListVC.h"

#define MAIN_CONTENT_HEIGHT 244

static NSString *kAccountUsernameSavedKey = @"accountUsernameSavedKey";
static NSString *kSavedUsernameKey = @"savedUsernameKey";
static NSString *kSavedPasswordKey = @"savedPasswordKey";
static NSString *kUserDefaultCityKey = @"userDefaultCityKey";

@interface TARegisterVC ()

@end

@implementation TARegisterVC

@synthesize nameField, emailField;
@synthesize usernameField, passwordField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (!(self = [super initWithCoder:aDecoder])) {
        return nil;
    }
    self.manuallySetScrollViewDelegate = YES;
    return self;
}

- (void)viewDidLoad {
    
    self.manuallySetScrollViewDelegate = YES;
    self.useFullScreenAsScrollViewContentSize = NO;
    
    if (!self.managedObjectContext) self.managedObjectContext = [self appDelegate].managedObjectContext;
	
	// Set up custom nav bar
	[self initNavBar];
	
	// Focus on name field
	[self.nameField becomeFirstResponder];
	
    [super viewDidLoad];
}


#pragma mark - Private Methods
- (AppDelegate *)appDelegate {
	
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}


- (void)viewDidUnload {
	
    nameField = nil;
    emailField = nil;
    usernameField = nil;
    passwordField = nil;
	   
    [super viewDidUnload];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma CitiesDelegate

- (void)locationSelected:(City *)city {
	
    self.citySelected = YES;
	[self.cityLabel setText:[city title]];
}


#pragma mark - UITextField delegations

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField == self.nameField) {
    
        [self.emailField becomeFirstResponder];
        [self.scrollView scrollRectToVisible:self.emailField.frame animated:YES];
    }
    
    else if (textField == self.emailField) {
        
        [self.usernameField becomeFirstResponder];
        [self.scrollView scrollRectToVisible:self.usernameField.frame animated:YES];
    }
    
    else if (textField == self.usernameField) {
        
        [self.passwordField becomeFirstResponder];
        [self.scrollView scrollRectToVisible:self.passwordField.frame animated:YES];
    }
    
	else if (textField == self.passwordField) {
		
		// Hide the keyboard
        [self.view endEditing:YES];
	}
    
    return NO;
}


- (void)initRegisterAPI {
    
    if ([self isEmpty:self.nameField]) {
    
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Registration error"
                    message:@"Please enter your name." delegate:self
            cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        return;
    }
	
    else if ([self isEmpty:self.emailField]) {
        
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Registration error"
                                                     message:@"Please enter your email." delegate:self
                                           cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        return;
    }
    
    else if ([self isEmpty:self.usernameField]) {
        
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Registration error"
                                                     message:@"Please enter a username." delegate:self
                                           cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        return;
    }
    
    else if ([self isEmpty:self.passwordField]) {
        
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Registration error"
                                                     message:@"Please enter a password." delegate:self
                                           cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        return;
    }
    
    else if (!self.citySelected) {
        
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Registration error"
                                                     message:@"Please select a city." delegate:self
                                           cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        return;
    }
    
	[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSDictionary *params = @{ @"name" : self.nameField.text, @"emailaddress" : self.emailField.text, @"username" : self.usernameField.text, @"password" : self.passwordField.text, @"city" : self.cityLabel.text };
    
    [[GlooRequestManager sharedManager] post:@"Register"
                                      params:params
                               dataLoadBlock:^(NSDictionary *json) {}
                             completionBlock:^(NSDictionary *json) {
                                 
                                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                                 
                                 if ([[json objectForKey:@"result"] isEqualToString:@"ok"]) {
                                 
                                     // Pass the token value to the AppDelegate to be stored as
                                     // the session token for all API calls
                                     [[self appDelegate] setToken:[json objectForKey:@"token"]];
                                     
                                     // Store the user data in a dictionary to pass to the delegate
                                     NSDictionary *userData = [json objectForKey:@"user"];
                                         
                                     // Save User to Core Data
                                     [User userWithLoginData:userData inManagedObjectContext:[self appDelegate].managedObjectContext];
                                     
                                     // Save Username/Password to NSUserDefaults
                                     [self saveAccountDetails];
                                     
                                     AppDelegate *appDelegate = [self appDelegate];
                                     
                                     // Store logged-in username
                                     [appDelegate setLoggedInUsername:self.usernameField.text];
                                     
                                     // We are now logged-in: update the iVar
                                     [appDelegate setUserLoggedIn:YES];
                                     
                                     // Show tab bar view controllers
                                     appDelegate.window.rootViewController = appDelegate.tabBarController;
                                     appDelegate.tabBarController.selectedIndex = 0;
                                 }
                                 
                                 else {
                                 
                                     NSString *errorMessage = @"There was an error registering your account. Please try again.";
                                     UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry!"
                                                                                         message:errorMessage
                                                                                        delegate:nil
                                                                               cancelButtonTitle:@"OK"
                                                                               otherButtonTitles:nil];
                                     [alertView show];
                                 }
                                 
                             }
                                  viewForHUD:nil];
}


// Example fetcher response handling
- (void)receivedRegisterResponse:(HTTPFetcher *)aFetcher {
    
    HTTPFetcher *theJSONFetcher = (HTTPFetcher *)aFetcher;
	
	//NSLog(@"REGO DETAILS:%@",[[NSString alloc] initWithData:theJSONFetcher.data encoding:NSASCIIStringEncoding]);
    
	NSAssert(aFetcher == registerFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	BOOL registrationSuccess = NO;
	
	//NSDictionary *userData;
	
	if ([theJSONFetcher.data length] > 0) {
		
		// Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		
		// Create a dictionary from the JSON string
		NSDictionary *results = [jsonString objectFromJSONString];
        NSDictionary *userData;
		
		for (int i = 0; i < [[results allKeys] count]; i++) {
			
			NSString *key = [[results allKeys] objectAtIndex:i];
			NSString *value = [results objectForKey:key];
			
			if ([key isEqualToString:@"result"]) registrationSuccess = (([value isEqualToString:@"ok"]) ? YES : NO);
			
			// Pass the token value to the AppDelegate to be stored as 
			// the session token for all API calls
			else if ([key isEqualToString:@"token"]) [[self appDelegate] setToken:[results objectForKey:key]];
			
			// Store the user data in a dictionary to pass to the delegate
			else if ([key isEqualToString:@"user"] && registrationSuccess) {
                
                userData = [results objectForKey:key];
                
                // Save User to Core Data
                [User userWithLoginData:userData inManagedObjectContext:[self appDelegate].managedObjectContext];
            }
		}
		
		NSLog(@"REGISTRATION RESULTS:%@", results);
	}
	
	// Registration details were given the tick of approval by the API
	// tell the delegate to animate this form out and store 
	// the username that was entered by the user
	if (registrationSuccess) {
		
		// Save Username/Password to NSUserDefaults
		[self saveAccountDetails];
		
		AppDelegate *appDelegate = [self appDelegate];
		
		// Store logged-in username
		[appDelegate setLoggedInUsername:self.usernameField.text];
		
		// We are now logged-in: update the iVar
		[appDelegate setUserLoggedIn:YES];
		
		// Show tab bar view controllers
        appDelegate.window.rootViewController = appDelegate.tabBarController;
        appDelegate.tabBarController.selectedIndex = 0;
	}
	
	else {
		
		NSString *errorMessage = @"There was an error registering your account. Please try again.";
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry!"
															message:errorMessage
														   delegate:nil
												  cancelButtonTitle:@"OK"
												  otherButtonTitles:nil];
		[alertView show];
	}
	
	[self hideLoading];
	
	registerFetcher = nil;
    
}


- (void)saveAccountDetails {
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	// Save a flag to say that the accountID has been saved
	[defaults setBool:YES forKey:kAccountUsernameSavedKey];
	
	// Save the username that's currently been entered by the user
	// into the NSUserDefaults
	NSString *saveUsername = self.usernameField.text;
	[defaults setObject:saveUsername forKey:kSavedUsernameKey];
	
	// Save the password that's currently been entered by the user
	// into the NSUserDefaults
	NSString *savePassword = self.passwordField.text;
	[defaults setObject:savePassword forKey:kSavedPasswordKey];
}


- (void)showLoading {
	
	[SVProgressHUD showInView:self.view status:nil networkIndicator:YES posY:-1 maskType:SVProgressHUDMaskTypeClear];
}


- (void)hideLoading {
	
	[SVProgressHUD dismissWithSuccess:@"Loaded!"];
}


- (void)initNavBar {

	self.title = @"REGISTER";
	self.navigationController.navigationBarHidden = NO;
    
    UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [saveBtn setImage:[UIImage imageNamed:@"nav-bar-save-button.png"] forState:UIControlStateNormal];
    [saveBtn setFrame:CGRectMake(0, 0, 54, 27)];
    [saveBtn addTarget:self action:@selector(registerButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *saveButtonItem = [[UIBarButtonItem alloc] initWithCustomView:saveBtn];
    
	self.navigationItem.rightBarButtonItem = saveButtonItem;
}


- (IBAction)goBack:(id)sender {

	[self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)goToCitiesList:(id)sender {

    TACitiesListVC *citiesListVC = [[TACitiesListVC alloc] initWithNibName:@"TACitiesListVC" bundle:nil];
    [citiesListVC setDelegate:self];
    [citiesListVC setManagedObjectContext:self.managedObjectContext];
    
    [self.navigationController pushViewController:citiesListVC animated:YES];
}


- (IBAction)registerButtonTapped:(id)sender {
    
    // Register the user
    [self initRegisterAPI];
}


- (BOOL)isEmpty:(UITextField *)textField {

    return (textField.text.length == 0);
}


@end
