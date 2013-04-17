//
//  TAFeedVC.m
//  Tourism App
//
//  Created by Richard Lee on 28/08/12.
//  Copyright (c) 2012 C2 Media Pty Ltd. All rights reserved.
//

#import "TAFeedVC.h"
#import "JSONKit.h"
#import "AppDelegate.h"
#import "GridImage.h"
#import "SVProgressHUD.h"
#import "TAImageDetailsVC.h"
#import "TAScrollVC.h"
#import "Photo.h"
#import	"CustomTabBarItem.h"
#import "HTTPFetcher.h"
#import "User.h"


#define IMAGE_VIEW_TAG 7000
#define GRID_IMAGE_WIDTH 102.0
#define GRID_IMAGE_HEIGHT 102.0
#define IMAGE_PADDING 1.0
#define MAIN_CONTENT_HEIGHT 367.0

static NSString *kUserDefaultCityKey = @"userDefaultCityKey";

@interface TAFeedVC ()

@end

@implementation TAFeedVC

@synthesize myFeedBtn, myCityBtn;
@synthesize imagesView, gridScrollView;
@synthesize images, feedMode, photos;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	
    if (self) {
		
		CustomTabBarItem *tabItem = [[CustomTabBarItem alloc] initWithTitle:@"" image:nil tag:0];
        
        tabItem.customHighlightedImage = [UIImage imageNamed:@"feed_tab_button-on.png"];
        tabItem.customStdImage = [UIImage imageNamed:@"feed_tab_button.png"];
		tabItem.imageInsets = UIEdgeInsetsMake(6.0, 0.0, -6.0, 0.0);
		
        self.tabBarItem = tabItem;
        tabItem = nil;
		 
		// Observe when the user has actually logged-in
		// so we can then start loading data
		[self initLoginObserver];
    }
    return self;
}

- (void)viewDidLoad {
	
    [super viewDidLoad];
	
	// Setup nav bar
	[self initNavBar];
	
	// By default we are in 'my feed' mode
	// make sure the button is selected
	[self.myFeedBtn setImage:[UIImage imageNamed:@"nav-my-feed-button-on.png"] forState:(UIControlStateHighlighted|UIControlStateSelected|UIControlStateDisabled)];
	
	[self.myCityBtn setImage:[UIImage imageNamed:@"nav-my-city-button-on.png"] forState:(UIControlStateHighlighted|UIControlStateSelected|UIControlStateDisabled)];
	
	// Set the content insets - padding - for the main scroll view
	[self.gridScrollView setContentInset:UIEdgeInsetsMake(0.0, 0.0, 6.0, 0.0)];

	
	[self.myFeedBtn setSelected:YES];
	[self.myFeedBtn setHighlighted:NO];
    
	self.images = [NSMutableArray array];
	self.photos = [NSMutableArray array];
	
	// The fetch size for each API call
    fetchSize = 12;
}


#pragma mark - Private Methods
- (AppDelegate *)appDelegate {
	
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}


- (void)viewDidUnload {
	
	self.images = nil;
	self.photos = nil;
	
	self.myFeedBtn = nil;
	self.myCityBtn = nil;
	
    self.gridScrollView = nil;
    self.imagesView = nil;
    self.managedObjectContext = nil;
	
    [super viewDidUnload];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)viewWillAppear:(BOOL)animated {
	
	[super viewWillAppear:animated];
}



#pragma UIScrollViewDelegate methods 

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	
    if (loading) return;
    isDragging = YES;
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	
	if (loading) return;
	
	else if (isDragging && scrollView.contentOffset.y < 0) {
		
		// UPDATE UI
		
		/*if (scrollView.contentOffset.y > -65.0f && scrollView.contentOffset.y < 0.0f && !loading) {
		 
		 [refreshHeaderView flipImageAnimated:YES];
		 [refreshHeaderView setStatus:kPullToReloadStatus];
		 [popSound play];
		 
		 } else if (!refreshHeaderView.isFlipped
		 &amp;&amp; scrollView.contentOffset.y &lt; -65.0f) {
		 [refreshHeaderView flipImageAnimated:YES];
		 [refreshHeaderView setStatus:kReleaseToReloadStatus];
		 [psst1Sound play];
		 }*/
	}
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
				  willDecelerate:(BOOL)decelerate {
	
	if (loading) return;
	
	isDragging = NO;
	
	CGFloat endPoint = scrollView.contentSize.height - scrollView.frame.size.height;
	CGFloat tippingPoint = 75.0;
	
	if ((scrollView.contentOffset.y - endPoint) >= tippingPoint) {
		
		[self showLoading];
		[self loadMoreImages];
	}
}



#pragma GridImageDelegate methods 

- (void)gridImageButtonClicked:(NSInteger)viewTag {
	
	Photo *selectedPhoto = [self.photos objectAtIndex:(viewTag - IMAGE_VIEW_TAG)];
	
	TAScrollVC *horizontalScroll = [[TAScrollVC alloc] initWithNibName:@"TAScrollVC" bundle:nil];
    [horizontalScroll setManagedObjectContext:[self managedObjectContext]];
    [horizontalScroll setPhotosMode:PhotosModeRegular];
	[horizontalScroll setPhotos:self.photos];
	[horizontalScroll setSelectedPhotoID:[selectedPhoto photoID]];
	
	[self.navigationController pushViewController:horizontalScroll animated:YES];
}


- (void) imageLoaded:(UIImage*)image withURL:(NSURL*)url {
	
	NSArray *gridImages = [self.imagesView subviews];
	SEL selector = @selector(imageLoaded:withURL:);
	
	for (int i = 0; i < [gridImages count]; i++) {
		
		GridImage *gridImage = [gridImages objectAtIndex:i];
		
		if ([gridImage respondsToSelector:selector])
			[gridImage performSelector:selector withObject:image withObject:url];
		
		gridImage = nil;
	}	
}


#pragma MY-METHODS

- (void)initNavBar {
	
	// Hide default nav bar
	self.navigationController.navigationBarHidden = YES;
	
}


- (IBAction)goBack:(id)sender {
	
	[self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)myCityButtonTapped:(id)sender {

	[self.myCityBtn setSelected:YES];
	[self.myCityBtn setHighlighted:NO];
	
	[self.myFeedBtn setSelected:NO];
	
	[self showLoading];
	
	self.feedMode = FeedModeCity;
	[self refreshButtonClicked:nil];
}


- (IBAction)myFeedButtonTapped:(id)sender {
	
	[self.myFeedBtn setSelected:YES];
	[self.myFeedBtn setHighlighted:NO];
	
	[self.myCityBtn setSelected:NO];
	
	[self showLoading];
	
	self.feedMode = FeedModeFeed;
	[self refreshButtonClicked:nil];
}


- (void)willLogout {
    
    [self.navigationController popToRootViewControllerAnimated:NO];
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
		
		[self showLoading];
		
		// Reset page index and call the two
		// relevant APIs
		imagesPageIndex = 0;
		
		[self removeThumbnails];
		
		// Clear images array
		[self.images removeAllObjects];
		
		// Load the FEED from the API
		self.feedMode = FeedModeFeed;
		[self initFeedAPI];
		
		// Get an iVar of AppDelegate
		// and STOP observing the AppDelegate's userLoggedIn
		// property now that the user HAS logged-in
		//AppDelegate *appDelegate = [self appDelegate];
		//[appDelegate removeObserver:self forKeyPath:@"userLoggedIn"];
	}
}


- (void)viewModeButtonTapped:(id)sender {
	
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose an option" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Feed", @"Default city", @"Refresh", nil];
	
	[actionSheet showInView:[self view]];
	[actionSheet showFromTabBar:self.parentViewController.tabBarController.tabBar];
}


- (void)updateImageGrid {
	
	CGFloat gridWidth = self.imagesView.frame.size.width;
	CGFloat maxXPos = gridWidth - GRID_IMAGE_WIDTH;
	
	CGFloat startXPos = 0.0;
	CGFloat xPos = startXPos;
	CGFloat yPos = 0.0;
	
	// Number of new rows to add, and how many have already
	// been added previously
	NSInteger subviewsCount = [self.imagesView.subviews count];
	
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
		[self.imagesView addSubview:gridImage];

		
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
	NSInteger rowCount = [[self.imagesView subviews] count]/3;
	NSInteger leftOver = [[self.imagesView subviews] count]%3;
	if (leftOver > 0) rowCount++;
	
	// Update the scroll view's content height
	CGRect imagesViewFrame = self.imagesView.frame;
	CGFloat gridRowsHeight = (rowCount * (GRID_IMAGE_HEIGHT + IMAGE_PADDING));
	
	CGFloat sViewContentHeight = imagesViewFrame.origin.y + gridRowsHeight + IMAGE_PADDING;
	
	// Set image view frame height
	imagesViewFrame.size.height = gridRowsHeight;
	[self.imagesView setFrame:imagesViewFrame];
	
	// Adjust content height of the scroll view
	[self.gridScrollView setContentSize:CGSizeMake(self.gridScrollView.frame.size.width, sViewContentHeight)];
}


- (void)userUploadsRequestFinished {
	
	// update the page index for 
	// the next batch
	imagesPageIndex++;
	
	// Update the image grid
	[self updateImageGrid];
}


- (void)initFindMediaAPI {
	
	loading = YES;
	
	NSString *defaultCity = [self getUsersDefaultCity];
	
	// Convert string to data for transmission
	NSString *jsonString = [NSString stringWithFormat:@"username=%@&city=%@&pg=%i&size=%i&token=%@", [self appDelegate].loggedInUsername, defaultCity, imagesPageIndex, fetchSize, [[self appDelegate] sessionToken]];
	
	NSData *jsonData = [NSData dataWithBytes:[jsonString UTF8String] length:[jsonString length]];
	
	// Create the URL that will be used to authenticate this user
	NSString *methodName = @"FindMedia";
	NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];
	
	// Initialiase the URL Request
	NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:jsonData];
	
	// JSONFetcher
	imagesFetcher = [[HTTPFetcher alloc] initWithURLRequest:request
												   receiver:self
													 action:@selector(receivedFindMediaResponse:)];
	[imagesFetcher start];
}


// Example fetcher response handling
- (void)receivedFindMediaResponse:(HTTPFetcher *)aFetcher {
    
    HTTPFetcher *theJSONFetcher = (HTTPFetcher *)aFetcher;
    
    NSAssert(aFetcher == imagesFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	//NSLog(@"PRINTING DATA:%@",[[NSString alloc] initWithData:theJSONFetcher.data encoding:NSASCIIStringEncoding]);
	
	loading = NO;
	
	NSInteger statusCode = [theJSONFetcher statusCode];
    
    if ([theJSONFetcher.data length] > 0 && statusCode == 200) {
		
		imagesLoaded = YES;
		
		// Store incoming data into a string
		// Create a dictionary from the JSON string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		NSDictionary *results = [jsonString objectFromJSONString];

		
		//NSArray *imagesArray = [results objectForKey:@"media"];
		//[self.images addObjectsFromArray:imagesArray];
		
		NSArray *imagesArray = [results objectForKey:@"media"];
		//[self.images addObjectsFromArray:imagesArray];
		
		// Take the data from the API, convert it 
		// to Photos objects and store them in 
		// self.photos array
		[self updatePhotosArray:imagesArray];
		
		//NSLog(@"CITY COUNT:%i", [self.images count]);
		
		[self userUploadsRequestFinished];
    }
    
	// hide loading
	[self hideLoading];
	
    imagesFetcher = nil;
}


- (void)initFeedAPI {
	
	loading = YES;
	
	// Convert string to data for transmission
	NSString *jsonString = [NSString stringWithFormat:@"username=%@&pg=%i&sz=%i&token=%@", [self appDelegate].loggedInUsername, imagesPageIndex, fetchSize, [[self appDelegate] sessionToken]];
	
	NSData *jsonData = [NSData dataWithBytes:[jsonString UTF8String] length:[jsonString length]];
	
	// Create the URL that will be used to authenticate this user
	NSString *methodName = @"Feed";
	NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];
	
	// Create URL request with URL and the JSON data
	NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:jsonData];
	
	// JSONFetcher
	imagesFetcher = [[HTTPFetcher alloc] initWithURLRequest:request
												   receiver:self
													 action:@selector(receivedFeedResponse:)];
	[imagesFetcher start];
}


// Example fetcher response handling
- (void)receivedFeedResponse:(HTTPFetcher *)aFetcher {
    
    HTTPFetcher *theJSONFetcher = (HTTPFetcher *)aFetcher;
    
    NSAssert(aFetcher == imagesFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	//NSLog(@"PRINTING FEED MEDIA:%@",[[NSString alloc] initWithData:theJSONFetcher.data encoding:NSASCIIStringEncoding]);
	
	loading = NO;
	
	NSInteger statusCode = [theJSONFetcher statusCode];
	
	//SBJson *json;
    
    if ([theJSONFetcher.data length] > 0 && statusCode == 200) {
        
        imagesLoaded = YES;
		
		// Store incoming data into a string
		// Create a dictionary from the JSON string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		NSDictionary *results = [jsonString objectFromJSONString];
		
		
		NSArray *imagesArray = [results objectForKey:@"media"];
		
		// Take the data from the API, convert it 
		// to Photos objects and store them in 
		// self.photos array
		[self updatePhotosArray:imagesArray];
		
		//NSLog(@"IMAGES:%@", self.images);
		
		[self userUploadsRequestFinished];
    }
	
	// hide loading
	[self hideLoading];
    
    imagesFetcher = nil;
}


- (IBAction)loadMoreImages {
	
	[self showLoading];
	
	loading = YES;
	
	switch (self.feedMode) {
			
		case FeedModeFeed:
			[self initFeedAPI];
			break;
			
		case FeedModeCity:
			[self initFindMediaAPI];
			break;
			
		default:
			break;
	}
}


- (void)showLoading {
	
	[SVProgressHUD showInView:self.view status:nil networkIndicator:YES posY:-1 maskType:SVProgressHUDMaskTypeClear];
}


- (void)hideLoading {
	
	[SVProgressHUD dismissWithSuccess:@"Loaded!"];
}


- (void)removeThumbnails {
	
	for (GridImage *gImage in self.imagesView.subviews) {
		
		[gImage removeFromSuperview];
	}
}


- (void)refreshButtonClicked:(id)sender {
	
	if (!loading) {
		
		// Reset page index and call the two
		// relevant APIs
		imagesPageIndex = 0;
		
		[self removeThumbnails];
		
		// Clear images array
		[self.images removeAllObjects];
		[self.photos removeAllObjects];
		
		switch (self.feedMode) {
				
			case FeedModeFeed:
				[self initFeedAPI];
				break;
				
			case FeedModeCity:
				[self initFindMediaAPI];
				break;
				
			default:
				break;
		}
	}
} 


- (NSString *)getUsersDefaultCity {

	// In time this should be a property that will be saved in NSUserDefaults.
	NSString *defaultCity = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultCityKey];
	
	return defaultCity;
}


/*
 Iterates through the self.images array,  
 converts all the Dictionary values to
 Photos (NSManagedObjects) and stores
 them in self.photos array
 */
- (void)updatePhotosArray:(NSArray *)imagesArray {
	
	NSManagedObjectContext *context = self.managedObjectContext;
    
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


@end
