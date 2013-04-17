//
//  TAImageDetailsVC.m
//  Tourism App
//
//  Created by Richard Lee on 27/08/12.
//  Copyright (c) 2012 C2 Media Pty Ltd. All rights reserved.
//

#import "TAImageDetailsVC.h"
#import "AppDelegate.h"
#import "JSONKit.h"
#import "HTTPFetcher.h"
#import "SVProgressHUD.h"
#import "StringHelper.h"
#import "ImageManager.h"
#import "TASimpleListVC.h"
#import "TAGuidesListVC.h"
#import "TAMapVC.h"
#import "TAProfileVC.h"
#import "TACommentsVC.h"
#import "TAImageGridVC.h"
#import "TAUsersVC.h"

@interface TAImageDetailsVC ()

@end

@implementation TAImageDetailsVC

@synthesize scrollView, progressIndicator, avatar, imageCode, usernameByline;
@synthesize usernameBtn, subtitle, mainPhoto, imageData, avatarURL, selectedURL;
@synthesize captionLabel, loveBtn, mapBtn, commentBtn, lovesCountBtn;
@synthesize verifiedView;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
	
    [super viewDidLoad];
	
	// FOR NOW: Add an "add" button to the top-right of the nav bar
	// to let the user add to an existing guide
	UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithTitle:@"add" style:UIBarButtonItemStyleDone target:self action:@selector(addPhotoToGuide:)];
	buttonItem.target = self;
	self.navigationItem.rightBarButtonItem = buttonItem;
	
	
	// Set the initial UI elements using
	// the image metadata that we already have
	[self setUIElements];
	
	// Scroll view
	CGSize newSize = CGSizeMake(self.scrollView.frame.size.width, self.loveBtn.frame.origin.y + self.loveBtn.frame.size.height + 100.0);
	[self.scrollView setContentSize:newSize];
}


#pragma mark - Private Methods
- (AppDelegate *)appDelegate
{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}


- (void)viewDidUnload {
	
	self.usernameByline = nil;
	
	self.lovesCountBtn = nil;
	
	self.avatarURL = nil;
	
	self.selectedURL = nil;
	
	self.imageData = nil;
	
	self.imageCode = nil;
	
    scrollView = nil;
	
    avatar = nil;
	
    mainPhoto = nil;
	
    usernameBtn = nil;
	
    commentBtn = nil;
	
    mapBtn = nil;
	
    loveBtn = nil;
	
    progressIndicator = nil;
	
    subtitle = nil;
	
	lovesCountBtn = nil;
	verifiedView = nil;
    [super viewDidUnload];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)viewWillAppear:(BOOL)animated {

	if (!loading && !imageLoaded) {
	
		[self initMediaAPI];
		
		[self initIsLovedAPI];
		
		[self initIsVouchedAPI];
	}
	
	[super viewWillAppear:animated];
}


#pragma RecommendsDelegate methods

- (void)recommendToUsernames:(NSMutableArray *)usernames {
	
	[self showLoading];
	
	// Retain the usernames that were selected 
	// for this Guide to be recommend to
	[self initRecommendAPI:usernames];
}


#pragma UIActionSheetDelegate methods 

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	// Share on Twitter
	if (buttonIndex == 0) [self showTweetSheet:nil];
	
	// Vouch
	else if (buttonIndex == 1) {
	
		if (isVouched)[self initUnvouchAPI];
		else [self initVouchAPI];
	}
}


#pragma Twitter Framework methods

- (IBAction)showTweetSheet:(id)sender {
	
    //  Create an instance of the Tweet Sheet
    TWTweetComposeViewController *tweetSheet = [[TWTweetComposeViewController alloc] init];
	
    // Sets the completion handler.  Note that we don't know which thread the
    // block will be called on, so we need to ensure that any UI updates occur
    // on the main queue
    tweetSheet.completionHandler = ^(TWTweetComposeViewControllerResult result) {
		
		NSString *resultOutput;
		
        switch(result) {
            case TWTweetComposeViewControllerResultCancelled:
                //  This means the user cancelled without sending the Tweet
				resultOutput = @"Tweet cancelled.";
                break;
            case TWTweetComposeViewControllerResultDone:
				
                //  This means the user hit 'Send'
				resultOutput = @"You successfully shared this photo on Twitter.";
                break;
        }
		
		[self performSelectorOnMainThread:@selector(displayTweetResult:) withObject:resultOutput waitUntilDone:NO];
		
        //  dismiss the Tweet Sheet 
        dispatch_async(dispatch_get_main_queue(), ^{            
            [self dismissViewControllerAnimated:YES completion:^{
                NSLog(@"Tweet Sheet has been dismissed."); 
            }];
        });
    };
	
    //  Set the initial body of the Tweet
    [tweetSheet setInitialText:@"Check out the photo I took on Tourism App:"]; 
	
    //  Adds an image to the Tweet
    if (![tweetSheet addImage:self.mainPhoto.image]) {
        NSLog(@"Unable to add the image!");
    }
	
    //  Add an URL to the Tweet. You can add multiple URLs.
    /*if (![tweetSheet addURL:[NSURL URLWithString:@"http://twitter.com/"]]){
	 NSLog(@"Unable to add the URL!");
	 }*/
	
    //  Presents the Tweet Sheet to the user
    [self presentViewController:tweetSheet animated:NO completion:^{
        NSLog(@"Tweet sheet has been presented.");
    }];
}


- (void)displayTweetResult:(NSString *)output {
	
	UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Twitter" message:output delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
	[av show];
}


#pragma MY-METHODS

- (void)setUIElements {

	NSArray *imageKeys = [self.imageData allKeys];
	
	// AVATAR & USERNAME
	if ([imageKeys containsObject:@"user"]) {
		
		NSDictionary *userDict = [self.imageData objectForKey:@"user"];
		
		NSString *avatarURLString = [NSString stringWithFormat:@"%@%@", FRONT_END_ADDRESS, [userDict objectForKey:@"avatar"]];
		[self initAvatarImage:avatarURLString];
		
		[self.usernameBtn setTitle:[userDict objectForKey:@"username"] forState:UIControlStateNormal];
		
		[self.usernameByline setTitle:[userDict objectForKey:@"username"] forState:UIControlStateNormal];
	}
	

	// LOVES COUNT	
	if ([imageKeys containsObject:@"count"]) { 
		
		NSDictionary *countDict = [self.imageData objectForKey:@"count"];
		lovesCount = [[countDict objectForKey:@"loves"] intValue];
		
		[self updateLovesCount];
	}
	
	
	// CAPTION	
	if ([self.imageData objectForKey:@"caption"]) { 
		
		[self.captionLabel setText:[self.imageData objectForKey:@"caption"]];
	}
	
	
	// CITY/TAG
	if ([self.imageData objectForKey:@"city"] && [self.imageData objectForKey:@"tag"]) { 
		
		NSString *city = [self.imageData objectForKey:@"city"];
		NSString *tag = [self.imageData objectForKey:@"tag"];
		
		[self.subtitle setTitle:[NSString stringWithFormat:@"%@/%@", city, tag] forState:UIControlStateNormal];
	}
	
	// MAIN PHOTO
	if ([imageKeys containsObject:@"paths"]) {
		
		NSDictionary *pathsDict = [self.imageData objectForKey:@"paths"];
		[self initImage:[NSString stringWithFormat:@"%@%@", FRONT_END_ADDRESS, [pathsDict objectForKey:@"zoom"]]];
	}
	
	
	// VERIFIED
	if ([imageKeys containsObject:@"verified"]) {
		
		NSInteger verified = [[self.imageData objectForKey:@"verified"] intValue];
		
		UIColor *bgColor;
		bgColor = ((verified == 1) ? [UIColor greenColor] : [UIColor redColor]);
		
		[self.verifiedView setBackgroundColor:bgColor];
	}
	
}


- (void)initMediaAPI {
	
	NSString *postString = [NSString stringWithFormat:@"code=%@", self.imageCode];
	NSData *postData = [NSData dataWithBytes:[postString UTF8String] length:[postString length]];
	
	// Create the URL that will be used to authenticate this user
	NSString *methodName = @"media";
	NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];
	
	// Initialiase the URL Request
	NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:postData];
	
	mediaFetcher = [[HTTPFetcher alloc] initWithURLRequest:request
												receiver:self action:@selector(receivedMediaResponse:)];
	[mediaFetcher start];
}


// Example fetcher response handling
- (void)receivedMediaResponse:(HTTPFetcher *)aFetcher {
    
    HTTPFetcher *theJSONFetcher = (HTTPFetcher *)aFetcher;
	
	NSAssert(aFetcher == mediaFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	//NSLog(@"PRINTING MEDIA:%@",[[NSString alloc] initWithData:theJSONFetcher.data encoding:NSASCIIStringEncoding]);
	
	loading = NO;
	
	NSInteger statusCode = [theJSONFetcher statusCode];
	
	if ([theJSONFetcher.data length] > 0 && statusCode == 200) {
		
		// Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		
		// Create a dictionary from the JSON string
		NSDictionary *results = [jsonString objectFromJSONString];
		
		// Build an array from the dictionary for easy access to each entry
		self.imageData = [results objectForKey:@"media"];
		
		NSLog(@"MEDIA imageData:%@", self.imageData);
	}
	
	// Set the UI elements with the new data
	[self setUIElements];
	
	// Stop the loading animation
	[self hideLoading];
	
	mediaFetcher = nil;
}


- (void)showLoading {
	
	[SVProgressHUD showInView:self.view status:nil networkIndicator:YES posY:-1 maskType:SVProgressHUDMaskTypeClear];
}


- (void)hideLoading {
	
	[SVProgressHUD dismissWithSuccess:@"Loaded!"];
}


- (void) imageLoaded:(UIImage*)image withURL:(NSURL*)url {
	
	if ([self.selectedURL isEqual:url]) {
		
		NSLog(@"MAIN IMAGE LOADED:%@", [url description]);
		
		// Hide progress indicator
		[self.progressIndicator setHidden:YES];
		
		[self.mainPhoto setImage:image];
	}

	else if ([self.avatarURL isEqual:url]) {
		
		NSLog(@"AVATAR IMAGE LOADED:%@", [url description]);

		[self.avatar setImage:image];
	}
}


- (void)initAvatarImage:(NSString *)avatarURLString {
	
	if (avatarURLString && !self.avatar.image) {
		
		NSLog(@"LOADING AVATAR IMAGE:%@", avatarURLString);
		
		self.avatarURL = [avatarURLString convertToURL];
		
		UIImage *img = [ImageManager loadImage:self.avatarURL progressIndicator:nil];
		if (img) [self.avatar setImage:img];
    }
}


- (void)initImage:(NSString *)urlString {
	
	if (urlString) {
		
		self.selectedURL = [urlString convertToURL];
		
		NSLog(@"LOADING MAIN IMAGE:%@", urlString);
		
		UIImage* img = [ImageManager loadImage:self.selectedURL progressIndicator:self.progressIndicator];
		if (img) {
			
			// Hide progress indicator
			[self.progressIndicator setHidden:YES];
			[self.mainPhoto setImage:img];
		}
    }
}


- (IBAction)lovesCountButtonTapped:(id)sender {
	
	TASimpleListVC *listVC = [[TASimpleListVC alloc] initWithNibName:@"TASimpleListVC" bundle:nil];
	[listVC setImageCode:self.imageCode];
	[self.navigationController pushViewController:listVC animated:YES];
}


- (IBAction)mapButtonTapped:(id)sender {
	
	NSDictionary *locationData = [self.imageData objectForKey:@"location"];
	
	TAMapVC *mapVC = [[TAMapVC alloc] initWithNibName:@"TAMapVC" bundle:nil];
	[mapVC setLocationData:locationData];
	[mapVC setMapMode:MapModeSingle];
	
	[self.navigationController pushViewController:mapVC animated:YES];
}


- (void)addPhotoToGuide:(id)sender {
	
	NSDictionary *userDict = [self.imageData objectForKey:@"user"];
	NSNumber *tagID = [NSNumber numberWithInt:[[self.imageData objectForKey:@"tag"] intValue]];

	TAGuidesListVC *guidesVC = [[TAGuidesListVC alloc] initWithNibName:@"TAGuidesListVC" bundle:nil];
	[guidesVC setUsername:[userDict objectForKey:@"username"]];
	[guidesVC setGuidesMode:GuidesModeAddTo];
	[guidesVC setSelectedTagID:tagID];
	[guidesVC setSelectedCity:[self.imageData objectForKey:@"city"]];
	[guidesVC setSelectedPhotoID:[self.imageData objectForKey:@"code"]];
	
	[self.navigationController pushViewController:guidesVC animated:YES];
}


- (IBAction)loveButtonTapped:(id)sender {

	if (isLoved) [self initUnloveAPI];
	
	else [self initLoveAPI];
}


- (void)initLoveAPI {
	
	[self.loveBtn setEnabled:NO]; 
	
	// Create API parameters
	NSString *jsonString = [NSString stringWithFormat:@"username=%@&code=%@&token=%@", [self appDelegate].loggedInUsername, self.imageCode, [self appDelegate].sessionToken];	
	NSData *postData = [NSData dataWithBytes:[jsonString UTF8String] length:[jsonString length]];
	
	// Create the URL that will be used to authenticate this user
	NSString *methodName = @"Love";
	NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];
	
	// Initialiase the URL Request
	NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:postData];
	
	loveFetcher = [[HTTPFetcher alloc] initWithURLRequest:request
												 receiver:self action:@selector(receivedLoveResponse:)];
	[loveFetcher start];
}


// Example fetcher response handling
- (void)receivedLoveResponse:(HTTPFetcher *)aFetcher {
    
	HTTPFetcher *theJSONFetcher = (HTTPFetcher *)aFetcher;
	
	NSAssert(aFetcher == loveFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	BOOL success = NO;
	NSInteger statusCode = [theJSONFetcher statusCode];
	
	if ([theJSONFetcher.data length] > 0 && statusCode == 200) {
		
		// Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		
		
		NSLog(@"LOVED RESPONSE:%@", jsonString);
		
		// Create a dictionary from the JSON string
		NSDictionary *results = [jsonString objectFromJSONString];
		
		if ([[results objectForKey:@"result"] isEqualToString:@"ok"]) success = YES;
		
		NSLog(@"jsonString:%@", jsonString);
	}
	
	// The "Love" request was successfull
	// Now update the iVar and UI
	if (success) {
		
		isLoved = YES;
		
		[self updateLovedStatus];
		
		lovesCount++;
		[self updateLovesCount];
	}
	
	// This is to update the correct "ImageView" when viewing a bunch
	// of images within a "Timeline" view controller
	//if (success) [self updateImageViewWithImageID:imageID loveStatus:NO];
	
	loveFetcher = nil;
    
}


- (void)updateLovesCount {
	
	// LOVES
	NSString *countStr;
	
	if (lovesCount == 1) countStr = [NSString stringWithFormat:@"%i love", lovesCount];
	else countStr = [NSString stringWithFormat:@"%i loves", lovesCount];
	
	[self.lovesCountBtn setTitle:countStr forState:UIControlStateNormal];
}


- (void)initUnloveAPI {
	
	[self.loveBtn setEnabled:NO]; 
	
	// Create API parameters
	NSString *jsonString = [NSString stringWithFormat:@"username=%@&code=%@&token=%@", [self appDelegate].loggedInUsername, self.imageCode, [self appDelegate].sessionToken];	
	NSData *postData = [NSData dataWithBytes:[jsonString UTF8String] length:[jsonString length]];
	
	// Create the URL that will be used to authenticate this user
	NSString *methodName = @"UnLove";
	NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];
	
	// Initialiase the URL Request
	NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:postData];
	
	loveFetcher = [[HTTPFetcher alloc] initWithURLRequest:request
													receiver:self action:@selector(receivedUnloveResponse:)];
	[loveFetcher start];
}


// Example fetcher response handling
- (void)receivedUnloveResponse:(HTTPFetcher *)aFetcher {
    
	HTTPFetcher *theJSONFetcher = (HTTPFetcher *)aFetcher;
	
	NSAssert(aFetcher == loveFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	BOOL success = NO;
	NSInteger statusCode = [theJSONFetcher statusCode];
	
	if ([theJSONFetcher.data length] > 0 && statusCode == 200) {
		
		// Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		
		// Create a dictionary from the JSON string
		NSDictionary *results = [jsonString objectFromJSONString];
		
		if ([[results objectForKey:@"result"] isEqualToString:@"ok"]) success = YES;
		
		NSLog(@"jsonString:%@", jsonString);
	}

	// The "UnLove" request was successfull
	// Now update the iVar and UI
	if (success) {
	
		isLoved = NO;
		
		[self updateLovedStatus];
		
		lovesCount--;
		[self updateLovesCount];
	}
	
	// This is to update the correct "ImageView" when viewing a bunch
	// of images within a "Timeline" view controller
	//if (success) [self updateImageViewWithImageID:imageID loveStatus:NO];
	
	loveFetcher = nil;
    
}


- (void)initIsLovedAPI {
	
	[self.loveBtn setEnabled:NO]; 
	
	NSString *jsonString = [NSString stringWithFormat:@"username=%@&code=%@", [self appDelegate].loggedInUsername, self.imageCode];	
	NSData *postData = [NSData dataWithBytes:[jsonString UTF8String] length:[jsonString length]];
	
	// Create the URL that will be used to authenticate this user
	NSString *methodName = @"isLoved";
	NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];
	
	// Initialiase the URL Request
	NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:postData];
	
	isLovedFetcher = [[HTTPFetcher alloc] initWithURLRequest:request
												  receiver:self action:@selector(receivedIsLovedResponse:)];
	[isLovedFetcher start];
}


// Example fetcher response handling
- (void)receivedIsLovedResponse:(HTTPFetcher *)aFetcher {
    
    HTTPFetcher *theJSONFetcher = (HTTPFetcher *)aFetcher;
    
	NSAssert(aFetcher == isLovedFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	NSInteger statusCode = [theJSONFetcher statusCode];
	
	if ([theJSONFetcher.data length] > 0 && statusCode == 200) {
		
		// Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		
		// Create a dictionary from the JSON string
		NSDictionary *results = [jsonString objectFromJSONString];
		
		if ([[results objectForKey:@"loved"] isEqualToString:@"true"]) isLoved = YES;
		
		NSLog(@"jsonString:%@", jsonString);
	}
	
	// Loved status
	[self updateLovedStatus];
	
	isLovedFetcher = nil;
    
}


/*	This function is called once an isLovedResponse is received from
 the API. It uses the value of the lovesImage iVar to then set 
 the title of loveButton button. The loveButton is then enable for interaction */
- (void)updateLovedStatus {
	
	NSString *status = [NSString stringWithFormat:@"%@", ((isLoved) ? @"loved" : @"love")];
	
	// Update love button title
	[self.loveBtn setTitle:status forState:UIControlStateNormal];
	
	// update the background colour of the button
	UIColor *newColor;
	if (isLoved) newColor = [UIColor redColor];
	else newColor = [UIColor lightGrayColor];
	
	[self.loveBtn setBackgroundColor:newColor];
	
	// Re-enable the button
	[self.loveBtn setEnabled:YES];
}


// TESTED!
- (void)initVouchAPI {
	
	NSString *jsonString = [NSString stringWithFormat:@"username=%@&code=%@&token=%@", [self appDelegate].loggedInUsername, self.imageCode, [[self appDelegate] sessionToken]];	
	NSData *postData = [NSData dataWithBytes:[jsonString UTF8String] length:[jsonString length]];
	
	// Create the URL that will be used to authenticate this user
	NSString *methodName = @"Vouch";
	NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];
	
	// Initialiase the URL Request
	NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:postData];
	
	vouchFetcher = [[HTTPFetcher alloc] initWithURLRequest:request
													receiver:self action:@selector(receivedVouchResponse:)];
	[vouchFetcher start];
}


// Example fetcher response handling
- (void)receivedVouchResponse:(HTTPFetcher *)aFetcher {
    
	HTTPFetcher *theJSONFetcher = (HTTPFetcher *)aFetcher;
	
	NSAssert(aFetcher == vouchFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	BOOL success = NO;
	NSInteger statusCode = [theJSONFetcher statusCode];
	
	if ([theJSONFetcher.data length] > 0 && statusCode == 200) {
		
		// Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		
		// Create a dictionary from the JSON string
		NSDictionary *results = [jsonString objectFromJSONString];
		
		if ([[results objectForKey:@"result"] isEqualToString:@"ok"]) success = YES;
		
		NSLog(@"VOUCH jsonString:%@", jsonString);
	}
	
	// The "Vouch" request was successfull
	// Now update the iVar and UI
	if (success) {
		
		isVouched = YES;
		
		//[self updateLovedStatus];
	}
	
	// This is to update the correct "ImageView" when viewing a bunch
	// of images within a "Timeline" view controller
	//if (success) [self updateImageViewWithImageID:imageID loveStatus:NO];
	
	vouchFetcher = nil;
    
}


// TESTED!
- (void)initUnvouchAPI {
	
	NSString *jsonString = [NSString stringWithFormat:@"username=%@&code=%@&token=%@", [self appDelegate].loggedInUsername, self.imageCode, [[self appDelegate] sessionToken]];	
	NSData *postData = [NSData dataWithBytes:[jsonString UTF8String] length:[jsonString length]];
	
	// Create the URL that will be used to authenticate this user
	NSString *methodName = @"Unvouch";
	NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];
	
	// Initialiase the URL Request
	NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:postData];
	
	vouchFetcher = [[HTTPFetcher alloc] initWithURLRequest:request
												  receiver:self action:@selector(receivedUnvouchResponse:)];
	[vouchFetcher start];
}


// Example fetcher response handling
- (void)receivedUnvouchResponse:(HTTPFetcher *)aFetcher {
    
	HTTPFetcher *theJSONFetcher = (HTTPFetcher *)aFetcher;
	
	NSAssert(aFetcher == vouchFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	BOOL success = NO;
	NSInteger statusCode = [theJSONFetcher statusCode];
	
	if ([theJSONFetcher.data length] > 0 && statusCode == 200) {
		
		// Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		
		// Create a dictionary from the JSON string
		NSDictionary *results = [jsonString objectFromJSONString];
		
		if ([[results objectForKey:@"result"] isEqualToString:@"ok"]) success = YES;
		
		NSLog(@"UNVOUCH jsonString:%@", jsonString);
	}
	
	// The "Unvouch" request was successfull
	// Now update the iVar and UI
	if (success) {
		
		isVouched = NO;
		
		//[self updateLovedStatus];
	}
	
	// This is to update the correct "ImageView" when viewing a bunch
	// of images within a "Timeline" view controller
	//if (success) [self updateImageViewWithImageID:imageID loveStatus:NO];
	
	vouchFetcher = nil;
}


// TESTED!
- (void)initIsVouchedAPI {
	
	NSString *jsonString = [NSString stringWithFormat:@"username=%@&code=%@", [self appDelegate].loggedInUsername, self.imageCode];	
	NSData *postData = [NSData dataWithBytes:[jsonString UTF8String] length:[jsonString length]];
	
	// Create the URL that will be used to authenticate this user
	NSString *methodName = @"isvouched";
	NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];
	
	// Initialiase the URL Request
	NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:postData];
	
	isVouchedFetcher = [[HTTPFetcher alloc] initWithURLRequest:request
												  receiver:self action:@selector(receivedIsVouchedResponse:)];
	[isVouchedFetcher start];
}


// Example fetcher response handling
- (void)receivedIsVouchedResponse:(HTTPFetcher *)aFetcher {
    
    HTTPFetcher *theJSONFetcher = (HTTPFetcher *)aFetcher;
    
	NSAssert(aFetcher == isVouchedFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	NSInteger statusCode = [theJSONFetcher statusCode];
	
	if ([theJSONFetcher.data length] > 0 && statusCode == 200) {
		
		// Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		
		// Create a dictionary from the JSON string
		NSDictionary *results = [jsonString objectFromJSONString];
		
		if ([[results objectForKey:@"vouched"] isEqualToString:@"true"]) isVouched = YES;
		
		NSLog(@"ISVOUCHED jsonString:%@", jsonString);
	}
	
	// Loved status
	//[self updateLovedStatus];
	
	isVouchedFetcher = nil;
    
}


- (IBAction)usernameButtonTapped:(id)sender {
	
	NSDictionary *userDict = [self.imageData objectForKey:@"user"];
	
	TAProfileVC *profileVC = [[TAProfileVC alloc] initWithNibName:@"TAProfileVC" bundle:nil];
	[profileVC setUsername:[userDict objectForKey:@"username"]];
	
	[self.navigationController pushViewController:profileVC animated:YES];
}


- (IBAction)optionsButtonTapped:(id)sender {
	
	NSString *vouchStatus = ((isVouched) ? @"Unvouch" : @"Vouch");

	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose an option" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Share on Twitter", vouchStatus, nil];
	
	[actionSheet showInView:[self view]];
	[actionSheet showFromTabBar:self.parentViewController.tabBarController.tabBar];
}


- (IBAction)viewComments:(id)sender {

	TACommentsVC *commentsVC = [[TACommentsVC alloc] initWithNibName:@"TACommentsVC" bundle:nil];
	[commentsVC setImageCode:self.imageCode];
	[self.navigationController pushViewController:commentsVC animated:YES];
}


- (IBAction)cityTagTapped:(id)sender {
	
	NSNumber *tagID = [NSNumber numberWithInt:[[self.imageData objectForKey:@"tag"] intValue]];
	
	TAImageGridVC *imageGridVC = [[TAImageGridVC alloc] initWithNibName:@"TAImageGridVC" bundle:nil];
	[imageGridVC setImagesMode:ImagesModeCityTag];
	[imageGridVC setTagID:tagID];
	[imageGridVC setCity:[self.imageData objectForKey:@"city"]];
	
	[self.navigationController pushViewController:imageGridVC animated:YES];
}


- (IBAction)initFollowersList:(id)sender {

	TAUsersVC *usersVC = [[TAUsersVC alloc] initWithNibName:@"TAUsersVC" bundle:nil];
	[usersVC setUsersMode:UsersModeRecommendTo];
	[usersVC setSelectedUsername:[self appDelegate].loggedInUsername];
	[usersVC setDelegate:self];
	
	[self.navigationController pushViewController:usersVC animated:YES];
}


- (void)initRecommendAPI:(NSMutableArray *)usernames {
	
	NSString *usernamesStr = [NSString stringWithFormat:@"%@", [usernames componentsJoinedByString:@","]];

	NSString *postString = [NSString stringWithFormat:@"token=%@&username=%@&code=%@&usernames=%@", [[self appDelegate] sessionToken], [self appDelegate].loggedInUsername, self.imageCode, usernamesStr];
	
	NSData *postData = [NSData dataWithBytes:[postString UTF8String] length:[postString length]];
	
	// Create the URL that will be used to authenticate this user
	NSString *methodName = @"Recommend";	
	NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];
	
	// Initialiase the URL Request
	NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:postData];
	
	// JSONFetcher
	recommendFetcher = [[HTTPFetcher alloc] initWithURLRequest:request
												   receiver:self
													 action:@selector(receivedRecommendResponse:)];
	[recommendFetcher start];
	
}


// Example fetcher response handling
- (void)receivedRecommendResponse:(HTTPFetcher *)aFetcher {
    
	HTTPFetcher *theJSONFetcher = (HTTPFetcher *)aFetcher;
	
	NSAssert(aFetcher == recommendFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	NSInteger statusCode = [theJSONFetcher statusCode];
	
	if ([theJSONFetcher.data length] > 0 && statusCode == 200) {
		
		// Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		
		// Create a dictionary from the JSON string
		//NSDictionary *results = [jsonString JSONValue];
		
		//if ([[results objectForKey:@"result"] isEqualToString:@"ok"]) success = YES;
		
		NSLog(@"jsonString RECOMMEND:%@", jsonString);
	}
	
	recommendFetcher = nil;
    
}


@end
