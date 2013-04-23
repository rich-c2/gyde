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
#import <Twitter/Twitter.h>

#define SHARE_VIEW_TAG 9999

@interface TACreateGuideVC ()

@end

@implementation TACreateGuideVC

@synthesize imageCode, titleField, guideTagID, guideCity, recommendToUsernames;
@synthesize tagLabel, cityLabel, descriptionField;

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
    
    self.title = @"GUIDE";
    
    UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [saveBtn setBackgroundImage:[UIImage imageNamed:@"follow-button.png"] forState:UIControlStateNormal];
    [saveBtn setBackgroundImage:[UIImage imageNamed:@"follow-button-on.png"] forState:UIControlStateNormal];
    [saveBtn setTitle:@"SAVE" forState:UIControlStateNormal];
    [saveBtn setFrame:CGRectMake(0, 0, 69, 27)];
    [saveBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:10]];
    [saveBtn addTarget:self action:@selector(submitButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *saveButtonItem = [[UIBarButtonItem alloc] initWithCustomView:saveBtn];
    
	self.navigationItem.rightBarButtonItem = saveButtonItem;
	
	// Set the city label
	self.cityLabel.text = self.guideCity;
    
    if (self.delegate) {
    
        UIView *shareView = [self.view viewWithTag:SHARE_VIEW_TAG];
        shareView.hidden = YES;
    }
        
	
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

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
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
}

// The submit button was tapped by the user
// This will trigger the "addguide" API call
- (void)submitButtonTapped:(id)sender {
    
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
                                 
                                 if ([json[@"result"] isEqualToString:@"ok"]) {
                                 
                                     NSDictionary *guideData = [json objectForKey:@"guide"];
                                     NSString *message = @"Your guide was successfully saved.";
                                     
                                     UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Success!"
                                                                                  message:message
                                                                                 delegate:self
                                                                        cancelButtonTitle:@"OK"
                                                                        otherButtonTitles:nil, nil];
                                     [av show];
                                     
                                     
                                     if (self.shareOnTwitter) {
                                         
#warning TO DO: adjust urlPath so it doesn't need to have prefix attached
                                         NSString *initialText = [NSString stringWithFormat:@"%@ %@%@", json[@"guide"][@"title"], FRONT_END_ADDRESS, json[@"guide"][@"urlpath"]];
                                         [self sharePhotoOnTwitterWithText:initialText];
                                     }
                                     
                                     if (self.addToFacebook) {
                                         
                                         // Post a status update to the user's feed via the Graph API, and display an alert view
                                         // with the results or an error.
                                         NSDictionary *guideDict = json[@"guide"];
                                         
                                         NSString *thumbURL = [NSString stringWithFormat:@"%@%@", FRONT_END_ADDRESS, guideDict[@"thumb"]];
#warning TO DO: adjust urlPath so it doesn't need to have prefix attached
                                         NSString *guideUrl = [NSString stringWithFormat:@"%@%@", FRONT_END_ADDRESS, guideDict[@"urlpath"]];
                                         NSString *description = guideDict[@"description"];
                                         NSString *name = guideDict[@"title"];
                                         NSString *message = @"Gyde for iOS.";
                                         
                                         NSMutableDictionary *postParams = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                                                            guideUrl, @"link",
                                                                            thumbURL, @"picture",
                                                                            name, @"name",
                                                                            message, @"caption",
                                                                            description, @"description",
                                                                            nil];
                                         
                                         [self publishPhotoToFacebookFeed:postParams];
                                     }
                                     
                                     
                                     
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
                                 
                             } viewForHUD:self.view];
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


- (void)sharePhotoOnTwitterWithText:(NSString *)initialText {
    
    NSString *tweetText = [NSString stringWithFormat:@"Via Gyde for iOS:%@", initialText];
    
    //Check for Social Framework availability (iOS 6)
    if(NSClassFromString(@"SLComposeViewController") != nil){
        
        if([SLComposeViewController instanceMethodForSelector:@selector(isAvailableForServiceType)] != nil)
        {
            if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
            {
                NSLog(@"service available");
                SLComposeViewController *composeViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
                [composeViewController setInitialText:tweetText];
                //[composeViewController addImage:self.photoView.image];
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
            [av show];
        }
    }
    
    else{
        
        // For TWTweetComposeViewController (iOS 5)
        if ([TWTweetComposeViewController canSendTweet]) {
            TWTweetComposeViewController *tweetVC = [[TWTweetComposeViewController alloc] init];
            //[tweetVC addImage:self.photoView.image];
            [tweetVC setInitialText:tweetText];
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
    
    self.addToFacebook = !self.addToFacebook;
    
    if (!self.addToFacebook)
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


@end
