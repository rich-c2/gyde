//
//  TAProfileVC.m
//  Tourism App
//
//  Created by Richard Lee on 20/08/12.
//  Copyright (c) 2012 C2 Media Pty Ltd. All rights reserved.
//

#import "TAProfileVC.h"
#import "JSONKit.h"
#import "HTTPFetcher.h"
#import "StringHelper.h"
#import "SVProgressHUD.h"
#import "TAUsersVC.h"
#import "TAImageGridVC.h"
#import "TAGuidesListVC.h"
#import "ImageManager.h"
#import "TALoginVC.h"
#import "TAMyContentVC.h"
#import "TASettingsVC.h"
#import "TASimpleListVC.h"
#import "TAFriendsVC.h"
#import "CustomTabBarItem.h"
#import "ProfileGuidesTableCell.h"
#import "TAGuideDetailsVC.h"
#import "TAScrollVC.h"

#define TABLE_HEADER_HEIGHT 20.0
#define TABLE_FOOTER_HEIGHT 10.0

#define POINTER_PLACES_OFFSET -65.0
#define POINTER_GUIDES_OFFSET 0.0

#define ANIMATION_DURATION 0.25

#define IMAGE_VIEW_TAG 7000
#define GRID_IMAGE_WIDTH 102.0
#define GRID_IMAGE_HEIGHT 102.0
#define IMAGE_PADDING 1.0

#define START_GRID_Y_POS 16.0

@interface TAProfileVC ()

@end

@implementation TAProfileVC

@synthesize username, avatarURL, usernameLabel, photosBtn, currentlyInLabel, avatarView, placesScrollView, guidesTable, guides;
@synthesize followUserBtn, followingUserBtn, followingBtn, followersBtn, myContentBtn, bioView;
@synthesize findFriendsBtn, contentScrollView, guidesBtn, modePointerView, photos;
@synthesize followersLabel, followingLabel, settingsBtn, backBtn;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil observeLogin:(BOOL)observe {
	
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	
    if (self) {
        
		// Listen for when the user has logged-in
		if (observe) {
			
			CustomTabBarItem *tabItem = [[CustomTabBarItem alloc] initWithTitle:@"" image:nil tag:0];
			
			tabItem.customHighlightedImage = [UIImage imageNamed:@"account_tab_button-on.png"];
			tabItem.customStdImage = [UIImage imageNamed:@"account_tab_button.png"];
			tabItem.imageInsets = UIEdgeInsetsMake(6.0, 0.0, -6.0, 0.0);
			
			self.tabBarItem = tabItem;
			tabItem = nil;
			
			[self initLoginObserver];
		}
    }
    return self;
}


#pragma mark - Private Methods
- (AppDelegate *)appDelegate {
	
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}


- (void)viewDidLoad {
	
    [super viewDidLoad];
	
	self.photos = [NSMutableArray array];
	
	// The fetch size for each API call
    fetchSize = 12;
	
	// Setup nav bar
	[self initNavBar];
	
	// Remove padding from bio text view
	self.bioView.contentInset = UIEdgeInsetsMake(-4,-8,0,0);
	
	// Update username label
	if ([self.username length] > 0)
		[self.usernameLabel setText:self.username];
	
	//[self.contentScrollView setContentSize:CGSizeMake(self.contentScrollView.frame.size.width, (self.contentScrollView.frame.size.height * 1.5))];
}


- (void)viewDidUnload {
	
	self.photos = nil;
	self.guides = nil;
	self.avatarURL = nil;
	self.currentlyInLabel = nil;
	self.username = nil;
	
	self.followingUserBtn = nil;
	
    self.followUserBtn = nil;
	
    self.followingBtn = nil;
    self.followersBtn = nil;
	self.photosBtn = nil;
	self.usernameLabel = nil;
	self.avatarView = nil;
	self.myContentBtn = nil;
    self.findFriendsBtn = nil;
	
	self.contentScrollView = nil;
	
	self.guidesBtn = nil;
	self.bioView = nil;
	self.modePointerView = nil;
	self.placesScrollView = nil;
	self.followersLabel = nil;
	self.followingLabel = nil;
	self.settingsBtn = nil;
	self.backBtn = nil;
	self.guidesTable = nil;
    
    [super viewDidUnload];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)viewWillAppear:(BOOL)animated {
	
	if ([self.navigationController.viewControllers count] == 1) self.backBtn.hidden = YES;
	
	if ([self.username length] > 0){
	
		// Start fetching the Profile API
		// if we're not already loading it.
		if (!loading && !profileLoaded) { 
			
			//[self showLoading];
			
			[self loadUserDetails];
		}
		
		// Init the "Uploads" API
		if (!uploadsLoaded && self.placesScrollView.alpha > 0.0) {
            
            //[self showLoadingWithStatus:@"Loading places" inView:self.placesScrollView];
		
			[self initUploadsAPI];
		}
		
		else if (!guidesLoaded && self.guidesTable.alpha > 0.0) {
			
			[self initMyGuidesAPI];
		}
		
		// IF we're not already loading 
		// "isFollowing" API then start it
		if (!loadingIsFollowing && !isFollowingLoaded) {
			
			// IF the loggedIn User is look at his/her own profile
			// then disable the follow/unfollow buttons
			if (![self.username isEqualToString:[self appDelegate].loggedInUsername]) {
		
				[self detectFollowStatus];
			}
		}
		
		// FOR NOW: Add an "save" button to the top-right of the nav bar
		// if this is a guide NOT created by the logged-in user
		if ([self.username isEqualToString:[self appDelegate].loggedInUsername]) {
			
			
			[self.followUserBtn setHidden:YES];
			[self.followUserBtn setHidden:YES];
			
			[self.settingsBtn setHidden:NO];
		}
		
		else {
			
			// HIDE MY CONTENT BUTTON
			self.myContentBtn.hidden = YES;
			self.findFriendsBtn.hidden = YES;
		}
	}
    
    // Deselect any selected table rows
    [self.guidesTable deselectRowAtIndexPath:[self.guidesTable indexPathForSelectedRow] animated:YES];
	
	[super viewWillAppear:animated];
}




#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
    return [self.guides count];
}


- (void)configureCell:(ProfileGuidesTableCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	
    // Make sure the cell images don't scale
    [cell.backgroundView setContentMode:UIViewContentModeTop];
    [cell.selectedBackgroundView setContentMode:UIViewContentModeTop];
    	
	Guide *guide = [self.guides objectAtIndex:[indexPath row]];
    
    [cell configureCellWithGude:guide];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    
    ProfileGuidesTableCell *cell = (ProfileGuidesTableCell *)[tableView dequeueReusableCellWithIdentifier:[ProfileGuidesTableCell reuseIdentifier]];
    
	
	if (cell == nil) {
        
        // Load the top-level objects from the custom cell XIB.
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ProfileGuidesTableCell" owner:self options:nil];
        
        // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
        cell = [topLevelObjects objectAtIndex:0];
    }
    
    
    
    // Retrieve Track object and set it's name to the cell
	[self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	
	return TABLE_HEADER_HEIGHT;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	
	UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.frame.size.width, TABLE_HEADER_HEIGHT)];
	[headerView setBackgroundColor:[UIColor clearColor]];
	
	return headerView;
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	
	return TABLE_FOOTER_HEIGHT;
}


- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	
	UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.frame.size.width, TABLE_FOOTER_HEIGHT)];
	[headerView setBackgroundColor:[UIColor clearColor]];
	
	return headerView;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	// Retrieve the Dictionary at the given index that's in self.users
	Guide *guide = [self.guides objectAtIndex:[indexPath row]];
	
	TAGuideDetailsVC *guideDetailsVC = [[TAGuideDetailsVC alloc] initWithNibName:@"TAGuideDetailsVC" bundle:nil];
	[guideDetailsVC setGuideID:[guide guideID]];
	
	[guideDetailsVC setGuideMode:GuideModeCreated];
	
	[self.navigationController pushViewController:guideDetailsVC animated:YES];
}


#pragma GridImageDelegate methods

- (void)gridImageButtonClicked:(NSInteger)viewTag {
	
	Photo *photo = [self.photos objectAtIndex:(viewTag - IMAGE_VIEW_TAG)];
    
    if (!self.managedObjectContext) self.managedObjectContext = [self appDelegate].managedObjectContext;
	
	// Push the Image Details VC onto the stack
	TAScrollVC *horizontalScroll = [[TAScrollVC alloc] initWithNibName:@"TAScrollVC" bundle:nil];
    [horizontalScroll setManagedObjectContext:[self managedObjectContext]];
	[horizontalScroll setPhotos:self.photos];
	[horizontalScroll setSelectedPhotoID:[photo photoID]];
	
	[self.navigationController pushViewController:horizontalScroll animated:YES];
}


#pragma mark MY-METHODS

- (IBAction)goBack:(id)sender {

	[self.navigationController popViewControllerAnimated:YES];
}

- (void)initLoginObserver {
	
	// Get an iVar of AppDelegate
	AppDelegate *appDelegate = [self appDelegate];
	
	/*
     Register to receive change notifications for the "userLoggedIn" property of
     the 'appDelegate' and specify that both the old and new values of "userLoggedIn"
     should be provided in the observe… method.
     */
    [appDelegate addObserver:self
						   forKeyPath:@"userLoggedIn"
							  options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
							  context:NULL];
}


- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object change:(NSDictionary *)change
                       context:(void *)context {
	
	NSInteger loggedIn = 0;
	
    if ([keyPath isEqual:@"userLoggedIn"])
		loggedIn = [[change objectForKey:NSKeyValueChangeNewKey] intValue];
	
	
	if (loggedIn == 1) {
		
		//[self setupNavBar];
		
		// Set the username for this profile
		// It equals the username of whoever just logged-in
		self.username = [self appDelegate].loggedInUsername;
		
		[self.usernameLabel setText:self.username];
		
		//[self showLoading];
		
		//[self loadUserDetails];
		
		[self.followingUserBtn setHidden:YES];
		[self.followUserBtn setHidden:YES];
		
		[self.settingsBtn setHidden:NO];
		
		// Get an iVar of AppDelegate
		// and STOP observing the AppDelegate's userLoggedIn
		// property now that the user HAS logged-in
		//AppDelegate *appDelegate = [self appDelegate];
		//[appDelegate removeObserver:self forKeyPath:@"userLoggedIn"];
	}
	
	else if (loggedIn == 0) { 
	
		[self clearUIFields];
	}
}


- (void)initTestData {

	// For now, set the username to be whoever is logged-in
	self.username = [self appDelegate].loggedInUsername;
}


- (IBAction)followingButtonTapped:(id)sender {
	
	// Push the following VC onto the stack
	TAUsersVC *followingVC = [[TAUsersVC alloc] initWithNibName:@"TAUsersVC" bundle:nil];
	[followingVC setSelectedUsername:self.username];
	[followingVC setManagedObjectContext:[self managedObjectContext]];
	[followingVC setUsersMode:UsersModeFollowing];
	[followingVC setNavigationTitle:@"Following"];
	
	[self.navigationController pushViewController:followingVC animated:YES];
}


- (IBAction)followersButtonTapped:(id)sender {
	
	// Push the followers VC onto the stack
	TAUsersVC *followersVC = [[TAUsersVC alloc] initWithNibName:@"TAUsersVC" bundle:nil];
	[followersVC setSelectedUsername:self.username];
	[followersVC setManagedObjectContext:[self managedObjectContext]];
	[followersVC setUsersMode:UsersModeFollowers];
	[followersVC setNavigationTitle:@"Followers"];
	
	[self.navigationController pushViewController:followersVC animated:YES];
}


- (IBAction)followUserButtonTapped:(id)sender {

	// Initiate Follow API
	[self initFollowAPI];
}


- (IBAction)followingUserButtonTapped:(id)sender {

	// Initiate Unfollow API
	[self initUnfollowAPI];
}


#pragma Follow/Unfollow methods

- (void)loadUserDetails {
	
	loading = YES;
	
	// Make API call for User details
	[self initProfileAPI];
}


- (void)initFollowAPI {
	
	NSString *postString = [NSString stringWithFormat:@"following=%@&follower=%@&token=%@", self.username, [self appDelegate].loggedInUsername, [self appDelegate].sessionToken];
	
	NSData *postData = [NSData dataWithBytes:[postString UTF8String] length:[postString length]];
	
	// Create the URL that will be used to authenticate this user
	NSString *methodName = @"Follow";	
	NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];
	
	// Initialiase the URL Request
	NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:postData];
	
	// HTTPFetcher
	followFetcher = [[HTTPFetcher alloc] initWithURLRequest:request
													 receiver:self
													   action:@selector(receivedFollowResponse:)];
	[followFetcher start];
}


// Example fetcher response handling
- (void)receivedFollowResponse:(HTTPFetcher *)aFetcher {
    
    HTTPFetcher *theJSONFetcher = (HTTPFetcher *)aFetcher;
	
	//NSLog(@"DETAILS:%@",[[NSString alloc] initWithData:theJSONFetcher.data encoding:NSASCIIStringEncoding]);
    
	NSAssert(aFetcher == followFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	BOOL success = NO;
	NSInteger statusCode = [theJSONFetcher statusCode];
	
	if ([theJSONFetcher.data length] > 0 && statusCode == 200) {
		
		// Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		
		// Create a dictionary from the JSON string
		NSDictionary *results = [jsonString objectFromJSONString];
		
		if ([[results objectForKey:@"result"] isEqualToString:@"ok"]) success = YES;
		
		//NSLog(@"FOLLOW jsonString:%@", jsonString);
	}
	
	// Follow API was successful
	if (success) {
		
		// Hide 'Follow' user button
		[self.followUserBtn setHidden:YES];
	
		// Display 'Following' user button
		[self.followingUserBtn setHidden:NO];
	}
	
	followFetcher = nil;
}


- (void)initUnfollowAPI {

	NSString *postString = [NSString stringWithFormat:@"following=%@&follower=%@&token=%@", self.username, [self appDelegate].loggedInUsername, [self appDelegate].sessionToken];
	
	NSData *postData = [NSData dataWithBytes:[postString UTF8String] length:[postString length]];
	
	// Create the URL that will be used to authenticate this user
	NSString *methodName = @"Unfollow";	
	NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];
	
	// Initialiase the URL Request
	NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:postData];
	
	// HTTPFetcher
	unfollowFetcher = [[HTTPFetcher alloc] initWithURLRequest:request
													receiver:self
													  action:@selector(receivedUnfollowResponse:)];
	[unfollowFetcher start];
}


// Example fetcher response handling
- (void)receivedUnfollowResponse:(HTTPFetcher *)aFetcher {
    
    HTTPFetcher *theJSONFetcher = (HTTPFetcher *)aFetcher;
	
	//NSLog(@"DETAILS:%@",[[NSString alloc] initWithData:theJSONFetcher.data encoding:NSASCIIStringEncoding]);
    
	NSAssert(aFetcher == unfollowFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");	
	
	BOOL success = NO;
	NSInteger statusCode = [theJSONFetcher statusCode];
	
	if ([theJSONFetcher.data length] > 0 && statusCode == 200) {
		
		// Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		
		// Create a dictionary from the JSON string
		NSDictionary *results = [jsonString objectFromJSONString];
		
		if ([[results objectForKey:@"result"] isEqualToString:@"ok"]) success = YES;
		
		//NSLog(@"UNFOLLOW jsonString:%@", jsonString);
	}
	
	// Follow API was successful
	if (success) {
		
		// Show 'Follow' user button
		[self.followUserBtn setHidden:NO];
		
		// Hide 'Following' user button
		[self.followingUserBtn setHidden:YES];
	}
		
	unfollowFetcher = nil;
}


#pragma Profile methods

- (void)initProfileAPI {

	NSString *postString = [NSString stringWithFormat:@"username=%@", self.username];
	NSData *postData = [NSData dataWithBytes:[postString UTF8String] length:[postString length]];
	
	// Create the URL that will be used to authenticate this user
	NSString *methodName = @"Profile";	
	NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];
	
	// Initialiase the URL Request
	NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:postData];
	
	// HTTPFetcher
	profileFetcher = [[HTTPFetcher alloc] initWithURLRequest:request
													receiver:self
											   action:@selector(receivedProfileResponse:)];
	[profileFetcher start];
}


// Example fetcher response handling
- (void)receivedProfileResponse:(HTTPFetcher *)aFetcher {
    
    HTTPFetcher *theJSONFetcher = (HTTPFetcher *)aFetcher;
	
	//NSLog(@"PROFILE DETAILS:%@",[[NSString alloc] initWithData:theJSONFetcher.data encoding:NSASCIIStringEncoding]);
    
	NSAssert(aFetcher == profileFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	loading = NO;
	
	NSInteger statusCode = [theJSONFetcher statusCode];
	
	if ([theJSONFetcher.data length] > 0 && statusCode == 200) {
		
		profileLoaded = YES;
		
		// Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		
		// Create a dictionary from the JSON string
		NSDictionary *results = [jsonString objectFromJSONString];
		
		// Build an array from the dictionary for easy access to each entry
		NSDictionary *newUserData = [results objectForKey:@"user"];

		// Update name label
		[self.currentlyInLabel setText:[NSString stringWithFormat:@"Currently in: %@", [newUserData objectForKey:@"city"]]];
		
		// Update followers and following buttons
		[self.followersLabel setText:[newUserData objectForKey:@"followers"]];
		[self.followingLabel setText:[newUserData objectForKey:@"following"]];
		
		// Update photos button
		[self.photosBtn setTitle:[NSString stringWithFormat:@"My photos (%@)", [newUserData objectForKey:@"media"]] forState:UIControlStateNormal];
		
		// Load avatar image
		self.avatarURL = [NSString stringWithFormat:@"%@%@", FRONT_END_ADDRESS, [newUserData objectForKey:@"avatar"]];
		[self initAvatarImage:self.avatarURL];
		
		//Bio
		NSString *bioText = [newUserData objectForKey:@"bio"];
		if ([bioText length] > 0) self.bioView.text = bioText; 

	}
	
	// Hide loading view
	//[self hideLoading];
	
	profileFetcher = nil;
}


# pragma isFollowing methods

- (void)detectFollowStatus {
	
	loadingIsFollowing = YES;
	
	[self initIsFollowingAPI];
}


- (void)initIsFollowingAPI {
	
	NSString *postString = [NSString stringWithFormat:@"username=%@&following=%@", [self appDelegate].loggedInUsername, self.username];
	NSData *postData = [NSData dataWithBytes:[postString UTF8String] length:[postString length]];
	
	// Create the URL that will be used to authenticate this user
	NSString *methodName = @"isFollowing";	
	NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];
	
	// Initialiase the URL Request
	NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:postData];
	
	// HTTPFetcher
	isFollowingFetcher = [[HTTPFetcher alloc] initWithURLRequest:request
													receiver:self
													  action:@selector(receivedIsFollowingResponse:)];
	[isFollowingFetcher start];
}


- (void)initNavBar {
	
	// Hide default nav bar
	self.navigationController.navigationBarHidden = YES;
}


// Example fetcher response handling
- (void)receivedIsFollowingResponse:(HTTPFetcher *)aFetcher {
    
    HTTPFetcher *theJSONFetcher = (HTTPFetcher *)aFetcher;
	
	//NSLog(@"ISFOLLOWING DETAILS:%@",[[NSString alloc] initWithData:theJSONFetcher.data encoding:NSASCIIStringEncoding]);
    
	NSAssert(aFetcher == isFollowingFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	loadingIsFollowing = NO;
	NSInteger statusCode = [theJSONFetcher statusCode];
	
	if ([theJSONFetcher.data length] > 0 && statusCode == 200) {
		
		isFollowingLoaded = YES;
		
		// Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		
		// Create a dictionary from the JSON string
		NSDictionary *results = [jsonString objectFromJSONString];
	
		// Update UI to reflect the result of the API call
		NSString *result = [results objectForKey:@"following"];
		[self updateFollowingButton:result];
	}
	
	// Hide loading view
	[self hideLoading];
	
	isFollowingFetcher = nil;
}


- (void)updateFollowingButton:(NSString *)isFollowing {

	// Enable the correct button
	// If this use is being followed by the logged-in user
	// then show the followingUser button. And vice-versa.
	if ([isFollowing isEqualToString:@"true"])
		[self.followingUserBtn setHidden:NO];
	
	else [self.followUserBtn setHidden:NO];
}


- (IBAction)photosButtonTapped:(id)sender {

	// Push the following VC onto the stack
	TAImageGridVC *imageGridVC = [[TAImageGridVC alloc] initWithNibName:@"TAImageGridVC" bundle:nil];
	[imageGridVC setUsername:self.username];
	
	[self.navigationController pushViewController:imageGridVC animated:YES];
}


- (void)initAvatarImage:(NSString *)avatarURLString {
	
	if (avatarURLString && !self.avatarView.image) {
		
		NSURL *url = [avatarURLString convertToURL];
		
		UIImage* img = [ImageManager loadImage:url progressIndicator:nil];
		if (img) [self.avatarView setImage:img];
    }
}


- (void) imageLoaded:(UIImage*)image withURL:(NSURL*)url {
	
	if ([[self.avatarURL convertToURL] isEqual:url]) {
		
		[self.avatarView setImage:image];
	}
	
	else {
		
		NSArray *gridImages = [self.placesScrollView subviews];
		SEL selector = @selector(imageLoaded:withURL:);
		
		for (int i = 0; i < [gridImages count]; i++) {
			
			GridImage *gridImage = [gridImages objectAtIndex: i];
			
			if ([gridImage respondsToSelector:selector])
				[gridImage performSelector:selector withObject:image withObject:url];
			
			gridImage = nil;
		}
	}
}


- (void)showLoadingWithStatus:(NSString *)status inView:(UIView *)view {
	
	[SVProgressHUD showInView:view status:status networkIndicator:YES posY:-1 maskType:SVProgressHUDMaskTypeClear];
}


- (void)hideLoading {
	
	[SVProgressHUD dismiss];
}


- (IBAction)myContentButtonTapped:(id)sender {
	
	// Push the following VC onto the stack
	TAMyContentVC *myContentVC = [[TAMyContentVC alloc] initWithNibName:@"TAMyContentVC" bundle:nil];
	[myContentVC setUsername:self.username];
	[self.navigationController pushViewController:myContentVC animated:YES];
}


- (IBAction)findFriendsButtonTapped:(id)sender {
	
	// Push the following VC onto the stack
	TAFriendsVC *friendsVC = [[TAFriendsVC alloc] initWithNibName:@"TAFriendsVC" bundle:nil];
	[self.navigationController pushViewController:friendsVC animated:YES];
}


- (void)willLogout {
	
	[self clearUIFields];
    
    [self.navigationController popToRootViewControllerAnimated:NO];
}


- (void)clearUIFields {
	
	// Start 'observing' for when the user
	// logs in again 
	//[self initLoginObserver];

	self.username = nil;
	self.currentlyInLabel.text = nil;
	self.myContentBtn.hidden = YES;
	self.findFriendsBtn.hidden = YES;
	[self.followersBtn setTitle:@"0 Followers" forState:UIControlStateNormal];
	[self.followingBtn setTitle:@"0 Following" forState:UIControlStateNormal];
	self.followingUserBtn.hidden = YES;
	self.followUserBtn.hidden = YES;
	
	self.avatarURL = nil;
	self.avatarView.image = nil;
	[self.photosBtn setTitle:@"Photos" forState:UIControlStateNormal];
}


- (IBAction)placesButtonTapped:(id)sender {

	[self animateToPlaces];
}


- (IBAction)guidesButtonTapped:(id)sender {
	
	[self animateToGuides];
}


- (void)animateToPlaces {
	
	// Set the new frame for the pointer image view
	CGRect newFrame = self.modePointerView.frame;
	newFrame.origin.x = POINTER_PLACES_OFFSET;
	
	// Fade out the uploads scroll view
	CGFloat guidesAlpha = 0.0;
	
	[UIView animateWithDuration:ANIMATION_DURATION animations:^{
		
		self.modePointerView.frame = newFrame;
		self.guidesTable.alpha = guidesAlpha;
		
	} completion:^(BOOL finished) {
		
		/*	on callback, we want to disable the places scroll
			view before fading it in. On top of that. */
		
		self.placesScrollView.userInteractionEnabled = NO;
		
		[self fadeView:self.placesScrollView alpha:1.0 duration:ANIMATION_DURATION];
	}];
}


- (void)animateToGuides {
	
	// Set the new frame for the pointer image view
	CGRect newFrame = self.modePointerView.frame;
	newFrame.origin.x = POINTER_GUIDES_OFFSET;
	
	// Fade out the uploads scroll view
	CGFloat placesAlpha = 0.0;
	
	[UIView animateWithDuration:ANIMATION_DURATION animations:^{
		
		self.modePointerView.frame = newFrame;
		self.placesScrollView.alpha = placesAlpha;
		
	} completion:^(BOOL finished) {
		
		/*	on callback, we want to disable the guides table
			before fading in the guidesTable. On top of that
			we want to start loading the user's guides */
		
		self.guidesTable.userInteractionEnabled = NO;
		
		[self fadeView:self.guidesTable alpha:1.0 duration:ANIMATION_DURATION];
		
		if (!guidesLoaded) {
			
			[self showLoadingWithStatus:@"Loading guides" inView:self.guidesTable];
			
			[self initMyGuidesAPI];
		}
	}];
}


- (void)fadeView:(UIView *)view alpha:(CGFloat)alpha duration:(CGFloat)duration {

	[UIView animateWithDuration:duration animations:^{
		
		view.alpha = alpha;
		
	} completion:^(BOOL finished) {
		
		view.userInteractionEnabled = YES;
	}];
}


- (void)updateImageGrid {
	
	CGFloat gridWidth = self.placesScrollView.frame.size.width;
	CGFloat maxXPos = gridWidth - GRID_IMAGE_WIDTH;
	
	CGFloat startXPos = 0.0;
	CGFloat xPos = startXPos;
	CGFloat yPos = START_GRID_Y_POS;
	
	// How many have already thumbs have been added previously?
	NSInteger subviewsCount = [self.placesScrollView.subviews count];
	
	// Set what the next tag value should be
	NSInteger tagCounter = IMAGE_VIEW_TAG + subviewsCount;
	
	// If images have previously been added, calculate where to
	// start placing the next batch of images
	if (subviewsCount > 0) {
		
		NSInteger rowCount = subviewsCount/3;
		NSInteger leftOver = subviewsCount%3;
		
		// Calculate starting xPos & yPos
		xPos = (leftOver * (GRID_IMAGE_WIDTH + IMAGE_PADDING));
		yPos = (rowCount * (GRID_IMAGE_HEIGHT + IMAGE_PADDING));
	}
	
	for (int i = subviewsCount; i < [self.photos count]; i++) {
		
		// Retrieve Photo object from array, and construct
		// a URL string for the thumbnail image
		Photo *photo = [self.photos objectAtIndex:i];
		NSString *thumbURL = [photo thumbURL];
		
		// Create GridImage, set its Tag and Delegate, and add it
		// to the imagesView
		CGRect newFrame = CGRectMake(xPos, yPos, GRID_IMAGE_WIDTH, GRID_IMAGE_HEIGHT);
		GridImage *gridImage = [[GridImage alloc] initWithFrame:newFrame imageURL:thumbURL];
		[gridImage setTag:tagCounter];
		[gridImage setDelegate:self];
		[self.placesScrollView addSubview:gridImage];
		
		// Update xPos & yPos for new image
		xPos += (GRID_IMAGE_WIDTH + IMAGE_PADDING);
		
		// Update tag for next image
		tagCounter++;
		
		if (xPos > maxXPos) {
			
			xPos = startXPos;
			yPos += (GRID_IMAGE_HEIGHT + IMAGE_PADDING);
		}
	}
	
	// Update size of the relevant views
	[self updateGridLayout];
}


- (void)updateGridLayout {
	
	// Updated number of how many rows there are
	NSInteger rowCount = [[self.placesScrollView subviews] count]/3;
	NSInteger leftOver = [[self.placesScrollView subviews] count]%3;
	if (leftOver > 0) rowCount++;
	
	// Update the scroll view's content height
	CGFloat gridRowsHeight = (START_GRID_Y_POS + (rowCount * (GRID_IMAGE_HEIGHT + IMAGE_PADDING)));
	
	CGFloat sViewContentHeight = gridRowsHeight + IMAGE_PADDING;
	
	// Adjust content height of the scroll view
	[self.placesScrollView setContentSize:CGSizeMake(self.placesScrollView.frame.size.width, sViewContentHeight)];
}


- (void)initUploadsAPI {
	
	NSString *postString = [NSString stringWithFormat:@"username=%@&pg=%i&sz=%i", self.username, imagesPageIndex, fetchSize];
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
    
    NSAssert(aFetcher == uploadsFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	//NSLog(@"PRINTING FIND MEDIA:%@",[[NSString alloc] initWithData:theJSONFetcher.data encoding:NSASCIIStringEncoding]);
	
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
    
    uploadsFetcher = nil;
}


- (void)userUploadsRequestFinished {
	
	// update the page index for
	// the next batch
	imagesPageIndex++;
	
	// Update the image grid
	[self updateImageGrid];
}


/*
 Iterates through the self.images array,
 converts all the Dictionary values to
 Photos (NSManagedObjects) and stores
 them in self.photos array
 */
- (void)updatePhotosArray:(NSArray *)imagesArray {
    
    if (!self.managedObjectContext) self.managedObjectContext = [self appDelegate].managedObjectContext;
	
	for (NSDictionary *image in imagesArray) {
		
		Photo *photo = [Photo photoWithPhotoData:image inManagedObjectContext:self.managedObjectContext];
		if (photo) [self.photos addObject:photo];
	}
}


- (void)initMyGuidesAPI {
	
	NSString *postString = [NSString stringWithFormat:@"username=%@&token=%@", self.username, [[self appDelegate] sessionToken]];
	NSData *postData = [NSData dataWithBytes:[postString UTF8String] length:[postString length]];
	
	// Create the URL that will be used to authenticate this user
	NSString *methodName = @"MyGuides";
	NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];
	
	// Initialiase the URL Request
	NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:postData];
	
	// HTTPFetcher
	guidesFetcher = [[HTTPFetcher alloc] initWithURLRequest:request
												   receiver:self action:@selector(receivedMyGuidesResponse:)];
	[guidesFetcher start];
}


// Example fetcher response handling
- (void)receivedMyGuidesResponse:(HTTPFetcher *)aFetcher {
    
    HTTPFetcher *theJSONFetcher = (HTTPFetcher *)aFetcher;
	
	NSAssert(aFetcher == guidesFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	NSLog(@"PRINTING MY GUIDES:%@",[[NSString alloc] initWithData:theJSONFetcher.data encoding:NSASCIIStringEncoding]);
	
	loading = NO;
	
	NSInteger statusCode = [theJSONFetcher statusCode];
    
    if ([theJSONFetcher.data length] > 0 && statusCode == 200) {
		
		guidesLoaded = YES;
		
		// Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		
		// Create a dictionary from the JSON string
		NSDictionary *results = [jsonString objectFromJSONString];
		
		NSArray *guidesArray = [results objectForKey:@"guides"];
			
		self.guides = (NSMutableArray *)[[self appDelegate] serializeGuideData:guidesArray];
		
	}
	
	[self finishedMyGuidesRequest];
	
	guidesFetcher = nil;
}


- (void)finishedMyGuidesRequest {
	
	[self.guidesTable reloadData];
	
	[self hideLoading];
}



		 
@end
