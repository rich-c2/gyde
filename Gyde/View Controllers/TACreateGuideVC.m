//
//  TACreateGuideVC.m
//  Tourism App
//
//  Created by Richard Lee on 27/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TACreateGuideVC.h"
#import "SVProgressHUD.h"
#import "JSONKit.h"
#import "HTTPFetcher.h"
#import "SVProgressHUD.h"
#import "AppDelegate.h"
#import "TAUsersVC.h"

@interface TACreateGuideVC ()

@end

@implementation TACreateGuideVC

@synthesize imageCode, titleField, guideTagID, guideCity, recommendToUsernames;
@synthesize tagLabel, cityLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	
    if (self) {
        
    }
    return self;
}


#pragma mark - Private Methods
- (AppDelegate *)appDelegate {
	
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)viewDidLoad {
	
    [super viewDidLoad];
	
	// Set the city label
	self.cityLabel.text = self.guideCity;
	
	// Set the tag label
	Tag *tag = [Tag tagWithID:[self.guideTagID intValue] inManagedObjectContext:[self appDelegate].managedObjectContext];
	self.tagLabel.text = tag.title;
}

- (void)viewDidUnload {
	
	self.titleField = nil;
    self.descriptionField = nil;
	
	self.imageCode = nil;
	self.recommendToUsernames = nil;
	
	self.guideTagID = nil; 
	self.guideCity = nil;
	
    self.cityLabel = nil;
    self.tagLabel = nil;
	
	[super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma RecommendsDelegate methods

- (void)recommendToUsernames:(NSMutableArray *)usernames {

	// Retain the usernames that were selected 
	// for this Guide to be recommend to
	self.recommendToUsernames = usernames;
}


#pragma mark - UITextField delegations
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    // If the current text field is the guide title - remove the keyboard
	if (textField == self.titleField)
		[self.descriptionField becomeFirstResponder];
    
    else if (textField == self.descriptionField)
        [self.descriptionField resignFirstResponder];
    
    return YES;
}


#pragma MY METHODS

- (IBAction)goBack:(id)sender {

    [self.navigationController popViewControllerAnimated:YES];
}


// The submit button was tapped by the user
// This will trigger the "addguide" API call
- (IBAction)submitButtonTapped:(id)sender {
    
    if (self.delegate) {
    
        NSString *title = self.titleField.text;
        NSNumber *private = [NSNumber numberWithInt:0];
        NSString *description = self.descriptionField.text;
        
        NSMutableDictionary *guideData = [NSMutableDictionary dictionaryWithObjectsAndKeys:title, @"title", description, @"description", private, @"private", nil];
        
        [self.delegate newGuideDetailsWereCreated:guideData];
        
        UIViewController *vc = (UIViewController *)self.delegate;
        [self.navigationController popToViewController:vc animated:YES];
    }
    
    else {
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];

        // init the "addguide" API call
        [self initAddGuideAPI];
    }
}


- (void)initAddGuideAPI {
	
	NSString *username = [self appDelegate].loggedInUsername;
	NSString *title = self.titleField.text;
	NSString *city = self.guideCity;
	NSString *tagID = [NSString stringWithFormat:@"%d", [self.guideTagID intValue]];
	NSString *imageIDs = self.imageCode;
	NSString *usernames = @"";
    NSString *desc = self.descriptionField.text;
	
	if ([self.recommendToUsernames count] > 0)
		usernames = [NSString stringWithFormat:@"&rec_usernames=%@", [self.recommendToUsernames componentsJoinedByString:@","]];	
	
	// Create the URL that will be used to authenticate this user    
    NSDictionary *params = @{ @"username" : username, @"title" : title, @"city" : city, @"tag" : tagID, @"description" : desc, @"imageIDs" : imageIDs, @"private" : @"0", @"token" : [self appDelegate].sessionToken, @"rec_usernames" : usernames };
    
    [[GlooRequestManager sharedManager] post:@"addguide" params:params
                               dataLoadBlock:^(NSDictionary *json) {}
                             completionBlock:^(NSDictionary *json) {
                             
                                 [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                                 
                                 if ([[json objectForKey:@"result"] isEqualToString:@"ok"]) {
                                 
                                     NSDictionary *guideData = [json objectForKey:@"guide"];
                                     NSString *message = @"Your guide was successfully saved.";
                                     
                                     UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Success!"
                                                                                  message:message
                                                                                 delegate:self
                                                                        cancelButtonTitle:@"OK"
                                                                        otherButtonTitles:nil, nil];
                                     [av show];
                                     
                                     if ([self.recommendToUsernames count] > 0) {
                                                                                  
                                         NSString *usernames = [self.recommendToUsernames componentsJoinedByString:@","];
                                         NSDictionary *recParams = @{ @"type" : @"guide", @"username" : username, @"code" : [guideData objectForKey:@"guideID"], @"usernames" : usernames, @"token" : [self appDelegate].sessionToken };
                                         
                                         [[GlooRequestManager sharedManager] post:@"recommend"
                                                                           params:recParams
                                                                    dataLoadBlock:^(NSDictionary *json) {}
                                                                  completionBlock:^(NSDictionary *json) {
                                                                  
                                                                      NSLog(@"DONE:%@", json);
                                                                  }
                                                                       viewForHUD:nil];
                                     }
                                     
                                     [self.navigationController popToRootViewControllerAnimated:YES];
                                 }
                                 
                                 else {
                                 
                                     NSString *message = @"There was an error saving your guide.";
                                     UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Sorry!"
                                                                                  message:message
                                                                                 delegate:self
                                                                        cancelButtonTitle:@"OK"
                                                                        otherButtonTitles:nil, nil];
                                     [av show];
                                 }
                                 
                             } viewForHUD:nil];
}


- (void)initRecommendAPI:(NSString *)guideID {
	
	NSString *username = [self appDelegate].loggedInUsername;
	NSString *usernames = [self.recommendToUsernames componentsJoinedByString:@","];
	
	NSString *postString = [NSString stringWithFormat:@"type=guide&username=%@&code=%@&usernames=%@&token=%@", username, guideID, usernames, [self appDelegate].sessionToken];
	
	NSLog(@"ADD GUIDE DATA:%@", postString);
	
	NSData *postData = [NSData dataWithBytes:[postString UTF8String] length:[postString length]];
	
	// Create the URL that will be used to authenticate this user
	NSString *methodName = @"recommend";
	NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];
	
	// Initialiase the URL Request
	NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:postData];
	
	// HTTPFetcher
	recommendFetcher = [[HTTPFetcher alloc] initWithURLRequest:request
											 receiver:self
											   action:@selector(receivedRecommendResponse:)];
	[recommendFetcher start];
}


- (IBAction)recommendButtonTapped:(id)sender {

	TAUsersVC *usersVC = [[TAUsersVC alloc] initWithNibName:@"TAUsersVC" bundle:nil];
	[usersVC setUsersMode:UsersModeRecommendTo];
	[usersVC setSelectedUsername:[self appDelegate].loggedInUsername];
	[usersVC setDelegate:self];
	
	[self.navigationController pushViewController:usersVC animated:YES];
}


- (NSNumber *)generateRandomNumberWithMax:(int)maxInt {
	
	int value = (arc4random() % maxInt) + 1;
	NSNumber *randomNum = [[NSNumber alloc] initWithInt:value];
	
	return randomNum;
	
}

@end
