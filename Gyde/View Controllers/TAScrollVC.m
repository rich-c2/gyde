//
//  TAScrollVC.m
//  Tourism App
//
//  Created by Richard Lee on 18/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TAScrollVC.h"
#import "SVProgressHUD.h"
#import "HTTPFetcher.h"
#import "JSONKit.h"
#import "TAMapVC.h"
#import "TAUsersVC.h"
#import "TAProfileVC.h"
#import <MessageUI/MessageUI.h>
#import "TAPhotoDetails.h"
#import "TAGuidesListVC.h"
#import "TAImageGridVC.h"


#define IMAGE_WIDTH 320
#define IMAGE_HEIGHT 290
#define IMAGE_PADDING 0
#define IMAGE_VIEW_TAG 7000
#define SCREEN_WIDTH 320

@interface TAScrollVC ()

@end

@implementation TAScrollVC

@synthesize photosMode, photosScrollView, photos, loveBtn;
@synthesize mainView, selectedPhotoID;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
	
    [super viewDidLoad];
	
	[self initNavBar];
	
	// The fetch size for each API call
    fetchSize = 20;
	
    // Add single tap gesture recognizer to map view
    // The action will be goToMapDetails:
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self action:@selector(showNav:)];
    tgr.numberOfTapsRequired = 1;
    tgr.numberOfTouchesRequired = 1;
    [self.photosScrollView addGestureRecognizer:tgr];
}

- (void)showNav:(id)sender {

    BOOL hide = self.navigationController.navigationBarHidden;
    
    [self.navigationController setNavigationBarHidden:!hide animated:YES];
}


#pragma mark - Private Methods
- (AppDelegate *)appDelegate {
	
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)viewDidUnload {
	
	self.selectedPhotoID = nil;
	self.photosScrollView = nil;
	self.photos = nil;
	self.managedObjectContext = nil;
	self.mainView = nil;
    self.loveBtn = nil;
	
	[super viewDidUnload];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewWillAppear:(BOOL)animated {

	[super viewWillAppear:animated];
	
    /*
     
     Initiate and populate the
     horizontal scroll view with
     the Photo objects provided
     in the self.photos array. */
    
	if (!photosLoaded) {
        
        if (!self.photos) self.photos = [NSMutableArray array];
        
        switch (self.photosMode) {
                
            case PhotosModeLovedPhotos:
                [self showLoading];
                [self initLovedAPI];
                break;
                
            case PhotosModeMyPhotos:
                [self showLoading];
                [self initUploadsAPI];
                break;
                
            case PhotosModeSinglePhoto:
                [self showLoading];
                [self initMediaAPI];
                break;
                
            default:
                
                [self populateTimeline];
                break;
        }
	}
}

- (void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}


#pragma ModalMapDelegate methods 

- (void)mapCloseButtonWasTapped {

    [self dismissModalViewControllerAnimated:YES];
}


#pragma PhotoDetailsDelegate methods 

- (void)usernameButtonTapped {

	Photo *currPhoto = [self.photos objectAtIndex:scrollIndex];
	
	TAProfileVC *profileVC = [[TAProfileVC alloc] initWithNibName:@"TAProfileVC" bundle:nil];
	[profileVC setUsername:[currPhoto whoTook].username];
	
	[self.navigationController pushViewController:profileVC animated:YES];
}


- (void)loveButtonTapped:(NSString *)imageID {
    
    NSManagedObjectContext *context;
    if (self.managedObjectContext) context = self.managedObjectContext;
    else context = [self appDelegate].managedObjectContext;
	
	Photo *currPhoto = [self.photos objectAtIndex:scrollIndex];
    
    User *user = [User userWithUsername:[self appDelegate].loggedInUsername inManagedObjectContext:context];
	
	if ([user.lovedPhotos containsObject:currPhoto]) {
        
        [currPhoto removeLovedByObject:user];
		[currPhoto setLovesCount:[NSNumber numberWithInt:([currPhoto.lovesCount intValue]-1)]];
		[self initUnloveAPI:[currPhoto photoID]];
    }
	
	else {
        
        [currPhoto addLovedByObject:user];
		[currPhoto setLovesCount:[NSNumber numberWithInt:([currPhoto.lovesCount intValue]+1)]];
        [self initLoveAPI:[currPhoto photoID]];
    }
    
}


- (void)mapButtonTapped:(NSString *)imageID {
    
    Photo *photo = [self.photos objectAtIndex:scrollIndex];
	NSDictionary *locationData = [NSDictionary dictionaryWithObjectsAndKeys:[photo latitude], @"latitude", [photo longitude], @"longitude", nil];
	
	TAMapVC *mapVC = [[TAMapVC alloc] initWithNibName:@"TAMapVC" bundle:nil];
	[mapVC setLocationData:locationData];
	[mapVC setMapMode:MapModeSingle];
    [mapVC setPhoto:photo];
    [mapVC setDelegate:self];
    
    UINavigationController *navC = [[UINavigationController alloc] initWithRootViewController:mapVC];
	
	[self.navigationController presentModalViewController:navC animated:YES];
}


- (void)tweetButtonTapped:(NSString *)imageID {
    
    Photo *currPhoto = [self.photos objectAtIndex:scrollIndex];
        
    NSInteger imageViewTag = IMAGE_VIEW_TAG + scrollIndex;
    TAPhotoFrame *imageView = (TAPhotoFrame *)[self.photosScrollView viewWithTag:imageViewTag];
    
    NSString *initialText = [NSString stringWithFormat:@"Via Gyde for iOS: %@", currPhoto.venue.title];
    
    //Check for Social Framework availability (iOS 6)
    if(NSClassFromString(@"SLComposeViewController") != nil){
        
        if([SLComposeViewController instanceMethodForSelector:@selector(isAvailableForServiceType)] != nil)
        {
            if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
            {
                NSLog(@"service available");
                SLComposeViewController *composeViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
                [composeViewController setInitialText:initialText];
                [composeViewController addImage:imageView.imageView.image];
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
            [tweetVC addImage:imageView.imageView.image];
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


- (void)facebookButtonTapped:(NSString *)imageID {
    
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(facebookSessionAvailable) name:@"facebook_session_available" object:nil];
	[[FacebookHelper sharedHelper] openSessionWithAllowLoginUI:YES];
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
             if (!error) {
                 // If permissions granted, publish the story
                 [self postToFeed];
             }
         }];
    } else {
        // If permissions present, publish the story
        [self postToFeed];
    }
}

//
// This method posts a 'link' story to the
// logged-in user's Facebook feed.
// The 'link'/status includes a small thumbnail image,
// caption, description and 'link'.
- (void)postToFeed {
    
    NSString *caption;
    NSString *description;
    NSString *link;
    
    Photo *currPhoto = [self.photos objectAtIndex:scrollIndex];
    description =  currPhoto.caption;
    link = currPhoto.url;
    caption = @"Gyde for iOS.";
    
    
    NSMutableDictionary *postParams = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                       link, @"link",
                                       currPhoto.thumbURL, @"picture",
                                       currPhoto.venue.title, @"name",
                                       caption, @"caption",
                                       description, @"description", nil];
    
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
         [[[UIAlertView alloc] initWithTitle:@"Result"
                                     message:alertText
                                    delegate:self
                           cancelButtonTitle:@"OK!"
                           otherButtonTitles:nil]
          show];
     }];
}


- (void)recommendButtonTapped {
    
	TAUsersVC *usersVC = [[TAUsersVC alloc] initWithNibName:@"TAUsersVC" bundle:nil];
	[usersVC setUsersMode:UsersModeRecommendTo];
	[usersVC setSelectedUsername:[self appDelegate].loggedInUsername];
	[usersVC setDelegate:self];
	
	[self.navigationController pushViewController:usersVC animated:YES];
}


- (void)flagButtonTapped:(NSString *)imageID {
	
	[self initFlagAPI:imageID];
}


- (void)addPhotoToGuide:(NSString *)imageID {
	
	Photo *currPhoto = [self.photos objectAtIndex:scrollIndex];
    
	TAGuidesListVC *guidesVC = [[TAGuidesListVC alloc] initWithNibName:@"TAGuidesListVC" bundle:nil];
	[guidesVC setUsername:[self appDelegate].loggedInUsername];
	[guidesVC setGuidesMode:GuidesModeAddTo];
	[guidesVC setSelectedTagID:[currPhoto.tag tagID]];
	[guidesVC setSelectedCity:[currPhoto.city title]];
	[guidesVC setSelectedPhotoID:[currPhoto photoID]];
	
	[self.navigationController pushViewController:guidesVC animated:YES];
}


- (void)tagButtonTapped:(NSNumber *)tagID {
    
    Photo *currPhoto = [self.photos objectAtIndex:scrollIndex];
	
	TAImageGridVC *imageGridVC = [[TAImageGridVC alloc] initWithNibName:@"TAImageGridVC" bundle:nil];
	[imageGridVC setImagesMode:ImagesModeCityTag];
	[imageGridVC setTagID:tagID];
	[imageGridVC setCity:[currPhoto.city title]];
	
	[self.navigationController pushViewController:imageGridVC animated:YES];
}


// TAPHOTODETAILS METHODS END //////////////////////////////////////////////////


- (void)disableScroll {

	[self.photosScrollView setScrollEnabled:NO];
}


- (void)enableScroll {
	
	[self.photosScrollView setScrollEnabled:YES];
}



#pragma mark MFMailComposeViewControllerDelegate

// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {	
    
    // Notifies users about errors associated with the interface
    switch (result) {
            
        case MFMailComposeResultCancelled:
            NSLog(@"Result: canceled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Result: saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Result: sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Result: failed");
            break;
        default:
            NSLog(@"Result: not sent");
            break;
    }
    
    [self dismissModalViewControllerAnimated:YES];
}


#pragma PullButtonDelegate methods 

- (void)buttonTouched {
	
	NSLog(@"GOTCHA'");
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
    [tweetSheet setInitialText:@"Check out this photo on Tourism App:"]; 
	
	
	NSInteger imageViewTag = IMAGE_VIEW_TAG + scrollIndex;
	TAPhotoFrame *photoFrame = (TAPhotoFrame *)[self.photosScrollView viewWithTag:imageViewTag];
	
    //  Adds an image to the Tweet
    if (![tweetSheet addImage:[photoFrame.imageView image]]) {
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


#pragma UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	
	// Need to detect if the scroll point has reached a new 
	// image. If so - start downloading this image, if it needs
	// to be downloaded or retrieved.
	NSInteger newIndex = ((int)scrollView.contentOffset.x / (IMAGE_WIDTH));
	
	if (newIndex != scrollIndex) {
		
		scrollIndex = newIndex;
		
		// Use the index and convert it to a tag using the IMAGES_TAG as
		// the base. Use the tag to access the relevant ImageView
		// and initialise image download
		NSInteger imageViewTag = IMAGE_VIEW_TAG + scrollIndex;
		TAPhotoFrame *imageView = (TAPhotoFrame *)[self.photosScrollView viewWithTag:imageViewTag];
		[imageView initImage];
	}
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	
}


#pragma RecommendsDelegate methods

- (void)recommendToUsernames:(NSMutableArray *)usernames {
	
	[self showLoading];
	
	Photo *currPhoto = [self.photos objectAtIndex:scrollIndex];
	
	// Retain the usernames that were selected 
	// for this Guide to be recommend to
	[self initRecommendAPI:usernames forImage:[currPhoto photoID]];
}


- (void)initRecommendAPI:(NSMutableArray *)usernames forImage:(NSString *)imageID {
	
	NSString *usernamesStr = [NSString stringWithFormat:@"%@", [usernames componentsJoinedByString:@","]];
	
	NSString *postString = [NSString stringWithFormat:@"token=%@&username=%@&code=%@&usernames=%@", [[self appDelegate] sessionToken], [self appDelegate].loggedInUsername, imageID, usernamesStr];
	
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
	}
	
	[self hideLoading];
	
	recommendFetcher = nil;
    
}


#pragma MY METHODS

- (void)initNavBar {
    
    self.title = @"PLACES";
    self.navigationController.navigationBarHidden = NO;
}


- (IBAction)closeButtonTapped:(id)sender {

	// Detect and fetch the current photo frame that is the
	// user is viewing and tell it that the close button has been tapped
	NSInteger imageViewTag = IMAGE_VIEW_TAG + scrollIndex;
	TAPhotoFrame *photoFrame = (TAPhotoFrame *)[self.photosScrollView viewWithTag:imageViewTag];
	
	[photoFrame closeButtonWasTapped];
}


/*
 This function is responsible for 
 iterating through the self.images on hand, creating
 the necessary ImageViews and then position them
 in the timelineScrollView
 */
- (void)populateTimeline {
	
	CGFloat xPos = 0.0;
	CGFloat yPos = 0.0;
	CGFloat sViewContentHeight = yPos;
	CGFloat selectedXPos = 0.0;
    
    NSManagedObjectContext *context;
    if (self.managedObjectContext) context = self.managedObjectContext;
    else context = [self appDelegate].managedObjectContext;
    
    User *currentUser = [User userWithUsername:[self appDelegate].loggedInUsername inManagedObjectContext:context];
	
	for (int i = 0; i < [self.photos count]; i++) {
		
		Photo *photo = [self.photos objectAtIndex:i];
		
		CGRect viewFrame = CGRectMake(xPos, yPos, IMAGE_WIDTH, 380.0);
		
		BOOL loved = (([currentUser.lovedPhotos containsObject:photo]) ? YES : NO);        
        
        NSString *placeTitle = [photo.venue title];
        if ([placeTitle length] == 0) placeTitle = @"[untitled]";
        
#pragma TODO - need to add the time elapsed since the photo was published
		
		TAPhotoDetails *photoView = [[TAPhotoDetails alloc] initWithFrame:viewFrame forPhoto:photo loved:loved];
		
		[photoView setDelegate:self];
		[photoView setTag:(IMAGE_VIEW_TAG + i)];
        
        
        // If no image has been selected AND
        // this is the first photo being loaded
        // then initiate the image download
        if (i == 0 && [self.selectedPhotoID length] == 0) 
            [photoView initImage];
        
		
		if ([[photo photoID] isEqualToString:self.selectedPhotoID]) {
			
			selectedXPos = xPos;
            
            [photoView initImage];
		}
		
		[self.photosScrollView addSubview:photoView];
		
		xPos += (IMAGE_WIDTH + IMAGE_PADDING);
		sViewContentHeight = yPos;
	}
	
	CGFloat newHeight = self.view.bounds.size.height;
	CGFloat newWidth = xPos;
	
	// Update the scroll view's content height
	[self.photosScrollView setContentSize:CGSizeMake(newWidth, newHeight)];
	
	// Focus on selected Photo if there is one
	if ([self.selectedPhotoID length] > 0) {
		
		CGPoint newOffset = CGPointMake(selectedXPos, 0.0);
		[self.photosScrollView setContentOffset:newOffset];
	}
	
	photosLoaded = YES;
}


- (void)showLoading {
	
	[SVProgressHUD showInView:self.view status:nil networkIndicator:YES posY:-1 maskType:SVProgressHUDMaskTypeClear];
}


- (void)hideLoading {
	
	[SVProgressHUD dismissWithSuccess:@"Loaded!"];
}


/*
 Iterates through the self.images array,  
 converts all the Dictionary values to
 Photos (NSManagedObjects) and stores
 them in self.photos array
 */
- (void)updatePhotosArray:(NSArray *)imagesArray {
	
	NSManagedObjectContext *context;
    if (self.managedObjectContext) context = self.managedObjectContext;
    else context = [self appDelegate].managedObjectContext;
    
    User *currentUser = [User userWithUsername:[self appDelegate].loggedInUsername inManagedObjectContext:context];
	
	for (NSDictionary *image in imagesArray) {
		
		Photo *photo = [Photo photoWithPhotoData:image inManagedObjectContext:context];
		if (photo) [self.photos addObject:photo];
		
		// Add image code to lovedIDs if it "isLoved"
		NSString *isLoved = [image objectForKey:@"isLoved"];

		if ([isLoved isEqualToString:@"true"])
			[currentUser addLovedPhotosObject:photo];
	}
}


- (void) imageLoaded:(UIImage*)image withURL:(NSURL*)url {
	
    NSArray *photoFrames = [self.photosScrollView subviews];
    SEL selector = @selector(imageLoaded:withURL:);
	
    for (int i = 0; i < [photoFrames count]; i++) {
		
		TAPhotoFrame *photo = [photoFrames objectAtIndex: i];
		
        if ([photo respondsToSelector:selector])
			[photo performSelector:selector withObject:image withObject:url];
		
//        [photo release];
		photo = nil;
    }
	
//    [photoFrames release];
}


- (void)initLoveAPI:(NSString *)photoID {

	NSString *jsonString = [NSString stringWithFormat:@"username=%@&code=%@&token=%@", [self appDelegate].loggedInUsername, photoID, [self appDelegate].sessionToken];
	
	NSLog(@"newJSON:%@", jsonString);
	
	// Convert string to data for transmission
	NSData *jsonData = [NSData dataWithBytes:[jsonString UTF8String] length:[jsonString length]];
	
	// Create the URL that will be used to authenticate this user
	NSString *methodName = [NSString stringWithFormat:@"Love"];
	NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];
	
	NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:jsonData];
	
	// JSONFetcher
	loveFetcher = [[HTTPFetcher alloc] initWithURLRequest:request
												 receiver:self action:@selector(receivedLoveResponse:)];
	[loveFetcher start];
}


- (void)initUnloveAPI:(NSString *)photoID {
	
	NSString *jsonString = [NSString stringWithFormat:@"username=%@&code=%@&token=%@", [self appDelegate].loggedInUsername, photoID, [self appDelegate].sessionToken];
	
	NSLog(@"newJSON:%@", jsonString);
	
	// Convert string to data for transmission
	NSData *jsonData = [NSData dataWithBytes:[jsonString UTF8String] length:[jsonString length]];
	
	// Create the URL that will be used to authenticate this user
	NSString *methodName = [NSString stringWithFormat:@"Unlove"];
	NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];
	
	NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:jsonData];
	
	// HTTPFetcher
	loveFetcher = [[HTTPFetcher alloc] initWithURLRequest:request
												 receiver:self action:@selector(receivedUnLoveResponse:)];
	[loveFetcher start];
}


// Example fetcher response handling
- (void)receivedLoveResponse:(HTTPFetcher *)aFetcher {
    
    HTTPFetcher *theJSONFetcher = (HTTPFetcher *)aFetcher;
	
	NSAssert(aFetcher == loveFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	BOOL success;
	NSString *imageID;
	NSString *newLovesCount;
	
	if ([theJSONFetcher.data length] > 0) {
		
		// Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		
		// Create a dictionary from the JSON string
		NSDictionary *results = [jsonString objectFromJSONString];
		
		if ([[results objectForKey:@"result"] isEqualToString:@"ok"]) success = YES;
		
		if ([[results allKeys] containsObject:@"code"])
			imageID = [results objectForKey:@"code"];
		
		if ([[results allKeys] containsObject:@"count"])
			newLovesCount = [results objectForKey:@"count"];
		
//		[jsonString release];
	}
	
	if (success) {
				
		NSInteger imageViewTag = IMAGE_VIEW_TAG + scrollIndex;
        TAPhotoDetails *photoView = (TAPhotoDetails *)[self.photosScrollView viewWithTag:imageViewTag];
        
        [photoView updateLoveButton:YES];
	}
	
//	[loveFetcher release];
	loveFetcher = nil;
}


// Example fetcher response handling
- (void)receivedUnLoveResponse:(HTTPFetcher *)aFetcher {
    
    HTTPFetcher *theJSONFetcher = (HTTPFetcher *)aFetcher;
	
	NSAssert(aFetcher == loveFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	BOOL success;
	NSString *imageID;
	NSString *newLovesCount;
	
	if ([theJSONFetcher.data length] > 0) {
		
		// Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		
		// Create a dictionary from the JSON string
		NSDictionary *results = [jsonString objectFromJSONString];
		
		if ([[results objectForKey:@"result"] isEqualToString:@"ok"]) success = YES;
		
		if ([[results allKeys] containsObject:@"code"])
			imageID = [results objectForKey:@"code"];
		
		if ([[results allKeys] containsObject:@"count"])
			newLovesCount = [results objectForKey:@"count"];
		
//		[jsonString release];
	}
	
	if (success) {
        
		NSInteger imageViewTag = IMAGE_VIEW_TAG + scrollIndex;
        TAPhotoDetails *photoView = (TAPhotoDetails *)[self.photosScrollView viewWithTag:imageViewTag];
        
        [photoView updateLoveButton:NO];
	}
	
//	[loveFetcher release];
	loveFetcher = nil;
}


- (void)initFlagAPI:(NSString *)imageID {
	
	NSString *jsonString = [NSString stringWithFormat:@"username=%@&code=%@&token=%@", [self appDelegate].loggedInUsername, imageID, [[self appDelegate] sessionToken]];
	
	NSData *postData = [NSData dataWithBytes:[jsonString UTF8String] length:[jsonString length]];
	
	// Create the URL that will be used to authenticate this user
	NSString *methodName = @"Flag";
	NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];
	
	// Initialiase the URL Request
	NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:postData];
	
	flagFetcher = [[HTTPFetcher alloc] initWithURLRequest:request
												 receiver:self action:@selector(receivedFlagResponse:)];
	[flagFetcher start];
}


// Example fetcher response handling
- (void)receivedFlagResponse:(HTTPFetcher *)aFetcher {
    
	HTTPFetcher *theJSONFetcher = (HTTPFetcher *)aFetcher;
	
	NSAssert(aFetcher == flagFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	NSInteger statusCode = [theJSONFetcher statusCode];
    
    BOOL success = NO;
	
	if ([theJSONFetcher.data length] > 0 && statusCode == 200) {
		
		// Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		
		// Create a dictionary from the JSON string
		NSDictionary *results = [jsonString objectFromJSONString];
		
		if ([[results objectForKey:@"result"] isEqualToString:@"ok"]) success = YES;
		
//		[jsonString release];
	}
	
	[self hideLoading];
    
    if (success) {
    
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Flag was successful!" message:@"You successfully flagged this photo. Thanks!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [av show];
    }
	
//	[flagFetcher release];
	flagFetcher = nil;
    
}


- (void)initAddToGuideAPI:(NSString *)guideID photoID:(NSString *)photoID {
	
	NSString *postString = [NSString stringWithFormat:@"username=%@&token=%@&imageID=%@&guideID=%@", [self appDelegate].loggedInUsername, [[self appDelegate] sessionToken], photoID, guideID];
	
	NSLog(@"ADD TO GUIDE string:%@", postString);
	
	NSData *postData = [NSData dataWithBytes:[postString UTF8String] length:[postString length]];
	
	// Create the URL that will be used to authenticate this user
	NSString *methodName = @"addtoguide";	
	NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];
	
	// Initialiase the URL Request
	NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:postData];
	
	// JSONFetcher
	addToGuideFetcher = [[HTTPFetcher alloc] initWithURLRequest:request
												   receiver:self
													 action:@selector(receivedAddToGuideResponse:)];
	[addToGuideFetcher start];
}


// Example fetcher response handling
- (void)receivedAddToGuideResponse:(HTTPFetcher *)aFetcher {
    
    HTTPFetcher *theJSONFetcher = (HTTPFetcher *)aFetcher;
	
	//NSLog(@"ADD TO GUIDE DETAILS:%@",[[NSString alloc] initWithData:theJSONFetcher.data encoding:NSASCIIStringEncoding]);
    
	NSAssert(aFetcher == addToGuideFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	loading = NO;
	
	BOOL success = NO;
	NSInteger statusCode = [theJSONFetcher statusCode];
	NSString *title;
	NSString *message;
	
	if ([theJSONFetcher.data length] > 0 && statusCode == 200) {
		
		// Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		
		// Create a dictionary from the JSON string
		NSDictionary *results = [jsonString objectFromJSONString];
		
		if ([[results objectForKey:@"result"] isEqualToString:@"ok"]) { 
			
			success = YES;
			
			title = @"Success!";
			message = [NSString stringWithFormat:@"The photo was successfully added"];// to \"%@\"", ];
		}
		
		//NSLog(@"jsonString:%@", jsonString);
		
//		[jsonString release];
	}
	
	
	if (!success) {
		
		title = @"Sorry!";
		message = @"There was an error adding that photo";
	}
	
	
	UIAlertView *av = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
	[av show];
	
//	[addToGuideFetcher release];
	addToGuideFetcher = nil;
}


- (void)initAddGuideAPI:(NSString *)guideTitle photo:(Photo *)photo {
	
	NSString *username = [self appDelegate].loggedInUsername;
	NSString *title = guideTitle;
	NSString *city = [[photo city] title];
	NSInteger tagID = [[[photo tag] tagID] intValue];
	NSString *imageIDs = [photo photoID];
	
	NSString *postString = [NSString stringWithFormat:@"username=%@&title=%@&city=%@&tag=%i&imageIDs=%@&private=0&token=%@", username, title, city, tagID, imageIDs, [self appDelegate].sessionToken];
		
	NSLog(@"ADD GUIDE DATA:%@", postString);
	
	NSData *postData = [NSData dataWithBytes:[postString UTF8String] length:[postString length]];
	
	// Create the URL that will be used to authenticate this user
	NSString *methodName = @"addguide";
	NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];
	
	// Initialiase the URL Request
	NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:postData];
	
	// JSONFetcher
	createGuidefetcher = [[HTTPFetcher alloc] initWithURLRequest:request
											 receiver:self
											   action:@selector(receivedAddGuideResponse:)];
	[createGuidefetcher start];
}


// Example fetcher response handling
- (void)receivedAddGuideResponse:(HTTPFetcher *)aFetcher {
    
    HTTPFetcher *theJSONFetcher = (HTTPFetcher *)aFetcher;
	
	//NSLog(@"SAVE RESPONSE:%@",[[NSString alloc] initWithData:theJSONFetcher.data encoding:NSASCIIStringEncoding]);
    
	NSAssert(aFetcher == createGuidefetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	// New image data;
	NSDictionary *guideData;
	BOOL submissionSuccess;
	
	if ([theJSONFetcher.data length] > 0) {
		
		// Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		
		// Create a dictionary from the JSON string
		NSDictionary *results = [jsonString objectFromJSONString];
		
		if ([[results objectForKey:@"result"] isEqualToString:@"ok"]) {
			
			submissionSuccess = YES;
			
			guideData = [results objectForKey:@"guide"];
		}
		
//		[jsonString release];
	}
	
	NSString *responseMessage;
	NSString *responseTitle = ((submissionSuccess) ? @"Success!" : @"Sorry!");
	
	// If the submission was successful
	if (submissionSuccess) responseMessage = @"Your guide was successfully created.";
	else responseMessage = @"There was an error creating your guide.";
	
	
	// FOR NOW: Kick off the "Recommend" API on the back of this one.
	// These two function will probably have to be combined
	/*if (submissionSuccess && [self.recommendToUsernames count] > 0) {
	 
	 [self initRecommendAPI:[guideData objectForKey:@"guideID"]];
	 }*/
	
	
	// Show pop up for submission result
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:responseTitle
														message:responseMessage
													   delegate:self
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
	[alertView show];
	
	
	// Create Image object and store
	if (submissionSuccess) {
		
		// Pop to root view controller (photo picker/camera)
		//[self.navigationController popToRootViewControllerAnimated:YES];
	}
	
	// Clean up
//	[createGuidefetcher release];
	createGuidefetcher = nil;
    
}


- (IBAction)goBack:(id)sender {

	[self.navigationController popViewControllerAnimated:YES];
}


- (void)initUploadsAPI {
	
	NSString *postString = [NSString stringWithFormat:@"username=%@&pg=%i&sz=%i", [self appDelegate].loggedInUsername, imagesPageIndex, fetchSize];
	NSData *postData = [NSData dataWithBytes:[postString UTF8String] length:[postString length]];
	
	// Create the URL that will be used to authenticate this user
	NSString *methodName = @"Uploads";
	NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];
	
	// Initialiase the URL Request
	NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:postData];
	
	// HTTPFetcher
	uploadsFetcher = [[HTTPFetcher alloc] initWithURLRequest:request
                                                    receiver:self action:@selector(receivedUploadsResponse:)];
	[uploadsFetcher start];
}


// Example fetcher response handling
- (void)receivedUploadsResponse:(HTTPFetcher *)aFetcher {
    
    HTTPFetcher *theJSONFetcher = (HTTPFetcher *)aFetcher;
	
	//NSLog(@"UPLOADS DETAILS:%@",[[NSString alloc] initWithData:theJSONFetcher.data encoding:NSASCIIStringEncoding]);
    
	NSAssert(aFetcher == uploadsFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	loading = NO;
	
	NSInteger statusCode = [theJSONFetcher statusCode];
	
	if ([theJSONFetcher.data length] > 0 && statusCode == 200) {
		
		uploadsLoaded = YES;
		
		// Store incoming data into a string
		// Create a dictionary from the JSON string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		NSDictionary *results = [jsonString objectFromJSONString];
		
		NSArray *imagesArray = [results objectForKey:@"media"];
		
		// Take the data from the API, convert it
		// to Photos objects and store them in
		// self.photos array
		[self updatePhotosArray:imagesArray];
		
		[self userUploadsRequestFinished];
	}
	
	// hide loading
	[self hideLoading];
	
//	[uploadsFetcher release];
	uploadsFetcher = nil;
}


- (void)userUploadsRequestFinished {
	
	// update the page index for
	// the next batch
	imagesPageIndex++;
	
	// Update the horizontal scroll view
	[self populateTimeline];
}


- (void)initLovedAPI {
	
	loading = YES;
	
	NSString *jsonString = [NSString stringWithFormat:@"username=%@&pg=%i&sz=%i", [self appDelegate].loggedInUsername, imagesPageIndex, fetchSize];
	
	// Convert string to data for transmission
	NSData *jsonData = [NSData dataWithBytes:[jsonString UTF8String] length:[jsonString length]];
	
	// Create the URL that will be used to authenticate this user
	NSString *methodName = @"Loved";
	NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];
	
	// Initialiase the URL Request
	NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:jsonData];
	
	// HTTPFetcher
	lovedPhotosFetcher = [[HTTPFetcher alloc] initWithURLRequest:request
                                                   receiver:self
                                                     action:@selector(receivedLovedResponse:)];
	[lovedPhotosFetcher start];
}


// Example fetcher response handling
- (void)receivedLovedResponse:(HTTPFetcher *)aFetcher {
    
    HTTPFetcher *theJSONFetcher = (HTTPFetcher *)aFetcher;
    
    NSAssert(aFetcher == lovedPhotosFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	NSLog(@"PRINTING LOVED DATA:%@",[[NSString alloc] initWithData:theJSONFetcher.data encoding:NSASCIIStringEncoding]);
	
	loading = NO;
	
	NSInteger statusCode = [theJSONFetcher statusCode];
    
    if ([theJSONFetcher.data length] > 0 && statusCode == 200) {
        
		photosLoaded = YES;
		
		// Store incoming data into a string
		// Create a dictionary from the JSON string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		NSDictionary *results = [jsonString objectFromJSONString];
		
		NSArray *imagesArray = [results objectForKey:@"media"];
		
		// Take the data from the API, convert it
		// to Photos objects and store them in
		// self.photos array
		[self updatePhotosArray:imagesArray];
		
		
		// Request is done. Now update the UI and
		// the relevant iVars
		[self lovedImagesRequestFinished];
    }
	
	// hide loading animation
	[self hideLoading];
    
//    [lovedPhotosFetcher release];
    lovedPhotosFetcher = nil;
}


- (void)lovedImagesRequestFinished {
	
	// update the page index for
	// the next batch
	imagesPageIndex++;
	
	// Update the horizontal scroll view
	[self populateTimeline];
}


- (void)initMediaAPI {
	
	loading = YES;
	
	NSString *jsonString = [NSString stringWithFormat:@"code=%@", [self selectedPhotoID]];
	
	// Convert string to data for transmission
	NSData *jsonData = [NSData dataWithBytes:[jsonString UTF8String] length:[jsonString length]];
	
	// Create the URL that will be used to authenticate this user
	NSString *methodName = @"Media";
	NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];
	
	// Initialiase the URL Request
	NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:jsonData];
	
	// HTTPFetcher
	mediaFetcher = [[HTTPFetcher alloc] initWithURLRequest:request
                                                        receiver:self
                                                          action:@selector(receivedMediaResponse:)];
	[mediaFetcher start];
}


// Example fetcher response handling
- (void)receivedMediaResponse:(HTTPFetcher *)aFetcher {
    
    HTTPFetcher *theJSONFetcher = (HTTPFetcher *)aFetcher;
    
    NSAssert(aFetcher == mediaFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	//NSLog(@"PRINTING MEDIA DATA:%@",[[NSString alloc] initWithData:theJSONFetcher.data encoding:NSASCIIStringEncoding]);
	
	loading = NO;
	
	NSInteger statusCode = [theJSONFetcher statusCode];
    
    if ([theJSONFetcher.data length] > 0 && statusCode == 200) {
        
		photosLoaded = YES;
		
		// Store incoming data into a string
		// Create a dictionary from the JSON string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		NSDictionary *results = [jsonString objectFromJSONString];
        
        if ([results[@"result"] isEqualToString:@"ok"]) {
        
            NSDictionary *photoData = [results objectForKey:@"media"];
            
            // Take the data from the API, convert it
            // to Photos objects and store them in self.photos array
            [self updatePhotosArray:[NSArray arrayWithObject:photoData]];
            
            // Request is done. Now update the UI and
            // the relevant iVars
            [self mediaRequestFinished];
        }
		
        else {
        
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Place error"
                                                         message:@"There was an error retrieving that place. Please check your network settings."
                                                        delegate:self
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil, nil];
            [av show];
        }
    }
	
	// hide loading animation
	[self hideLoading];
    
    mediaFetcher = nil;
}


- (void)mediaRequestFinished {
	
	// Update the horizontal scroll view
	[self populateTimeline];
}



@end
