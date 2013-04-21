//
//  TAImageGridVC.m
//  Tourism App
//
//  Created by Richard Lee on 21/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TAImageGridVC.h"
#import "HTTPFetcher.h"
#import "StringHelper.h"
#import "SVProgressHUD.h"
#import "JSONKit.h"
#import "AppDelegate.h"
#import "GridImage.h"
#import "Photo.h"
#import "TAScrollVC.h"
#import "TAMapVC.h"

#define IMAGE_VIEW_TAG 7000
#define GRID_IMAGE_WIDTH 102.0
#define GRID_IMAGE_HEIGHT 102.0
#define IMAGE_PADDING 1.0
#define MAIN_CONTENT_HEIGHT 367.0


@interface TAImageGridVC ()

@end

@implementation TAImageGridVC

@synthesize tagID, tag, city, resetButton, filterButton;
@synthesize imagesView, gridScrollView, sortMode, sortModeToggler;
@synthesize masterArray, username, imagesMode, photos, filteredPhotos;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
	
    [super viewDidLoad];
    
    self.title = @"PLACES";
    self.navigationController.navigationBarHidden = NO;
	
	// The fetch size for each API call
    fetchSize = 20;
	
	if (self.imagesMode == ImagesModeLikedPhotos || self.imagesMode == ImagesModeMyPhotos) {
	
		// view mode options
		UIBarButtonItem *filterButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"filter" style:UIBarButtonItemStyleDone target:self action:@selector(filterButtonTapped:)];
		filterButtonItem.target = self;
		
		self.filterButton = filterButtonItem;
		
		UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithTitle:@"reset" style:UIBarButtonItemStyleDone target:self action:@selector(resetPhotoFilters:)];
		buttonItem.target = self;
		
		self.resetButton = buttonItem;
	}
	
	if (self.imagesMode == ImagesModeCityTag) {
		
		// Show the sort toggler
		self.sortModeToggler.hidden = NO;
		
		// Reposition the scroll view to accomodate sort toggler
		/*CGRect newFrame = self.gridScrollView.frame;
		CGFloat shiftVal = 50;
		newFrame.origin.y += shiftVal;
		newFrame.size.height -= shiftVal;
		[self.gridScrollView setFrame:newFrame];*/
        
        
        UIButton *guidesTabBtn = (UIButton *)[self.view viewWithTag:LATEST_MODE_TAG];
        [guidesTabBtn setSelected:YES];
        [guidesTabBtn setHighlighted:NO];
        
        self.selectedTabButton = guidesTabBtn;
	
        UIButton *mapBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [mapBtn setFrame:CGRectMake(0, 0, 54, 27)];
        [mapBtn setTitle:@"MAP" forState:UIControlStateNormal];
        [mapBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:12]];
        [mapBtn setBackgroundImage:[UIImage imageNamed:@"follow-button.png"] forState:UIControlStateNormal];
        [mapBtn setBackgroundImage:[UIImage imageNamed:@"follow-button-on.png"] forState:UIControlStateHighlighted];
        [mapBtn addTarget:self action:@selector(viewImagesMap:) forControlEvents:UIControlEventTouchUpInside];
		UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:mapBtn];
		buttonItem.target = self;
		
		self.navigationItem.rightBarButtonItem = buttonItem;
	}
}


#pragma mark - Private Methods
- (AppDelegate *)appDelegate {
	
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)viewDidUnload {
	
	self.tagID = nil; 
	self.tag = nil; 
	self.city = nil;
	
	self.resetButton = nil;
	self.filterButton = nil;
	
	self.filteredPhotos = nil;
	self.photos = nil;
	self.masterArray = nil;
	self.username = nil;
	
    self.gridScrollView = nil;
    self.imagesView = nil;
	
	self.sortModeToggler = nil;
	
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)viewWillAppear:(BOOL)animated {

	[super viewWillAppear:animated];
	
	if (!loading && !imagesLoaded) {
		
		// Init array
		if (!self.filteredPhotos) self.filteredPhotos = [NSMutableArray array];
		if (!self.photos) self.photos = [NSMutableArray array];
		if (!self.masterArray) self.masterArray = [NSMutableArray array];
		
		switch (self.imagesMode) {
				
			case ImagesModeMyPhotos:
				self.masterArray = self.photos;
				[self setupNavBar];
				[self initUploadsAPI];
				break;
				
			case ImagesModeLikedPhotos:
				self.masterArray = self.photos;
				[self setupNavBar];
				[self initLovedAPI];
				break;
				
			case ImagesModeCityTag:
				self.masterArray = self.photos;
				[self initFindMediaAPI];
				break;
				
			default:
				break;
		}
	}
}



#pragma ExploreDelegate methods 

- (void)finishedFilteringWithPhotos:(NSArray *)newPhotos {
	
	filterMode = YES;
	[self setupNavBar];

	NSMutableArray *mutablePhotos = [newPhotos mutableCopy];
	self.filteredPhotos = mutablePhotos;
	
	self.masterArray = self.filteredPhotos;
	
	
	
	[self refreshImageGrid];
}


- (void) imageLoaded:(UIImage*)image withURL:(NSURL*)url {
	
	NSArray *gridImages = [self.imagesView subviews];
	SEL selector = @selector(imageLoaded:withURL:);
	
	for (int i = 0; i < [gridImages count]; i++) {
		
		GridImage *gridImage = [gridImages objectAtIndex: i];
		
		if ([gridImage respondsToSelector:selector])
			[gridImage performSelector:selector withObject:image withObject:url];
		
		gridImage = nil;
	}
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
    [horizontalScroll setPhotosMode:PhotosModeRegular];
	[horizontalScroll setPhotos:self.photos];
	[horizontalScroll setSelectedPhotoID:[selectedPhoto photoID]];
	
	[self.navigationController pushViewController:horizontalScroll animated:YES];
}


#pragma MY-METHODS

- (IBAction)goBack:(id)sender {

    [self.navigationController popViewControllerAnimated:YES];
}


- (void)initFindMediaAPI {
	
	NSString *sort = ((self.sortMode == SortModeLatest) ? @"latest" : @"popular");
	
	NSString *jsonString = [NSString stringWithFormat:@"username=%@&tag=%i&city=%@&pg=%i&sz=%i&sort=%@&token=%@", [self appDelegate].loggedInUsername, [self.tagID intValue], self.city, imagesPageIndex, fetchSize, sort, [[self appDelegate] sessionToken]];
	NSLog(@"jsonString:%@", jsonString);
	
	// Convert string to data for transmission
	NSData *jsonData = [NSData dataWithBytes:[jsonString UTF8String] length:[jsonString length]];
	
	// Create the URL that will be used to authenticate this user
	NSString *methodName = @"FindMedia";
	NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];
	
	// Create URL request with URL and the JSON data
	NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:jsonData];
	
	// HTTPFetcher
	imagesFetcher = [[HTTPFetcher alloc] initWithURLRequest:request
												  receiver:self
													action:@selector(receivedFindMediaResponse:)];
	[imagesFetcher start];
}


// Example fetcher response handling
- (void)receivedFindMediaResponse:(HTTPFetcher *)aFetcher {
    
    HTTPFetcher *theJSONFetcher = (HTTPFetcher *)aFetcher;
    
    NSAssert(aFetcher == imagesFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	//NSLog(@"PRINTING FIND MEDIA:%@",[[NSString alloc] initWithData:theJSONFetcher.data encoding:NSASCIIStringEncoding]);
	
	loading = NO;
	
	NSInteger statusCode = [theJSONFetcher statusCode];
    
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
		
		[self userUploadsRequestFinished];
    }
	
	// hide loading
	[self hideLoading];
    
    imagesFetcher = nil;
}


- (IBAction)loadMoreImages {
	
	loading = YES;
	
	[self showLoading];
	
	switch (self.imagesMode) {
			
		case ImagesModeMyPhotos:
			[self initUploadsAPI];
			break;
			
		case ImagesModeLikedPhotos:
			[self initLovedAPI];
			break;
			
		case ImagesModeCityTag:
			[self initFindMediaAPI];
			break;
			
		default:
			break;
	}
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
	
	for (int i = subviewsCount; i < [self.masterArray count]; i++) {
		
		// Retrieve Photo object from array, and construct
		// a URL string for the thumbnail image
		Photo *photo = [self.masterArray objectAtIndex:i];
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


- (void)initUploadsAPI {
	
	NSString *postString = [NSString stringWithFormat:@"username=%@&pg=%i&sz=%i", self.username, imagesPageIndex, fetchSize];
	NSData *postData = [NSData dataWithBytes:[postString UTF8String] length:[postString length]];
	
	// Create the URL that will be used to authenticate this user
	NSString *methodName = @"Uploads";
	NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];
	
	// Initialiase the URL Request
	NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:postData];
	
	// HTTPFetcher
	imagesFetcher = [[HTTPFetcher alloc] initWithURLRequest:request
												   receiver:self action:@selector(receivedUploadsResponse:)];
	[imagesFetcher start];
} 


// Example fetcher response handling
- (void)receivedUploadsResponse:(HTTPFetcher *)aFetcher {
    
    HTTPFetcher *theJSONFetcher = (HTTPFetcher *)aFetcher;
	
	//NSLog(@"UPLOADS DETAILS:%@",[[NSString alloc] initWithData:theJSONFetcher.data encoding:NSASCIIStringEncoding]);
    
	NSAssert(aFetcher == imagesFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	loading = NO;
	
	NSInteger statusCode = [theJSONFetcher statusCode];
	
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
		
		[self userUploadsRequestFinished];
	}
	
	// hide loading
	[self hideLoading];
	
	imagesFetcher = nil;
}


- (void)userUploadsRequestFinished {
	
	// update the page index for 
	// the next batch
	imagesPageIndex++;
	
	// Update the image grid
	[self updateImageGrid];
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
	imagesFetcher = [[HTTPFetcher alloc] initWithURLRequest:request
												  receiver:self
													action:@selector(receivedLovedResponse:)];
	[imagesFetcher start];
}


// Example fetcher response handling
- (void)receivedLovedResponse:(HTTPFetcher *)aFetcher {
    
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
    
    imagesFetcher = nil;
}


- (void)lovedImagesRequestFinished {
	
	// update the page index for 
	// the next batch
	imagesPageIndex++;
	
	// Update the image grid
	[self updateImageGrid];
}


- (void)showLoading {
	
	[SVProgressHUD showInView:self.view status:nil networkIndicator:YES posY:-1 maskType:SVProgressHUDMaskTypeClear];
}


- (void)hideLoading {
	
	[SVProgressHUD dismissWithSuccess:@"Loaded!"];
}


- (void)setupNavBar {
	
	if (!filterMode) self.navigationItem.rightBarButtonItem = self.filterButton;
	else self.navigationItem.rightBarButtonItem = self.resetButton;
	
}


/*
 Iterates through the self.images array,  
 converts all the Dictionary values to
 Photos (NSManagedObjects) and stores
 them in self.photos array
 */
- (void)updatePhotosArray:(NSArray *)imagesArray {
	
	NSManagedObjectContext *context = [self appDelegate].managedObjectContext;
	
	for (NSDictionary *image in imagesArray) {
		
		Photo *photo = [Photo photoWithPhotoData:image inManagedObjectContext:context];
		if (photo) [self.photos addObject:photo];
	}
	
	
	if (self.sortMode == SortModePopular) {
		
		NSSortDescriptor *lovesDesc = [[NSSortDescriptor alloc] initWithKey:@"lovesCount" ascending:NO];
		[self.photos sortUsingDescriptors:[NSArray arrayWithObject:lovesDesc]];	
	}
	
	else {
		
		 NSSortDescriptor *dateDesc = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
		 [self.photos sortUsingDescriptors:[NSArray arrayWithObject:dateDesc]];	
	}
}
	 
	 
- (void)refreshImageGrid {
	
	[self showLoading];

	[self removeThumbnails];
	
	if (filterMode) {
	
		[self updateImageGrid];
		
		[self hideLoading];
	}
	
	else {
		
		// Reset page index and call the two
		// relevant APIs
		imagesPageIndex = 0;
		
		switch (self.imagesMode) {
				
			case ImagesModeMyPhotos:
				[self initUploadsAPI];
				break;
				
			case ImagesModeLikedPhotos:
				[self initLovedAPI];
				break;
				
			case ImagesModeCityTag:
				[self initFindMediaAPI];
				break;
				
			default:
				break;
		}
	}
}


- (void)resetPhotoFilters:(id)sender {
	
	filterMode = NO;

	[self showLoading];
	
	[self setupNavBar];
	
	[self removeThumbnails];
	
	self.masterArray = self.photos;
	
	[self.filteredPhotos removeAllObjects];
	
	[self updateImageGrid];
	
	[self hideLoading];
}
	 
	 
- (void)removeThumbnails {
 
	for (GridImage *gImage in self.imagesView.subviews) {
	 
		[gImage removeFromSuperview];
	}
}


- (void)viewImagesMap:(id)sender {

	TAMapVC *mapVC = [[TAMapVC alloc] initWithNibName:@"TAMapVC" bundle:nil];
	[mapVC setMapMode:MapModeMultiple];
	[mapVC setPhotos:self.photos];
	
	[self.navigationController pushViewController:mapVC animated:YES];
}


- (IBAction)sortModeWasChanged:(id)sender {
    
    UIButton *btn = (UIButton *)sender;
    
    if (btn.tag != self.sortMode) {
        
        [self.selectedTabButton setSelected:NO];
        
        [btn setSelected:YES];
        [btn setHighlighted:NO];
        
        self.selectedTabButton = btn;
        
        // Change the sortMode property to reflect
        // the selection made by the user
        if (btn.tag == SortModeLatest) self.sortMode = SortModeLatest;
        else self.sortMode = SortModePopular;
	
        // Clear the thumbnails from the grid
        [self removeThumbnails];
        
        // Clear the self.photos array
        [self.photos removeAllObjects];
        
        // Reset the page index
        imagesPageIndex = 0;
        
        [self showLoading];
        
        // Call the findMedia API
        [self initFindMediaAPI];
    }
}


	 
@end
