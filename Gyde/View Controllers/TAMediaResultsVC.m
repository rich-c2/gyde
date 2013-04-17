//
//  TAMediaResultsVC.m
//  Tourism App
//
//  Created by Richard Lee on 30/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TAMediaResultsVC.h"
#import "SVProgressHUD.h"
#import "JSONKit.h"
#import "HTTPFetcher.h"
#import "TAGuidesListVC.h"
#import "TAImageGridVC.h"
#import "ProfileGuidesTableCell.h"
#import "TAGuideDetailsVC.h"
#import "GridImage.h"
#import "TAScrollVC.h"
#import "ASIHTTPRequest.h"

#define TABLE_HEADER_HEIGHT 9.0
#define TABLE_FOOTER_HEIGHT 4.0

#define IMAGE_VIEW_TAG 7000
#define GRID_IMAGE_WIDTH 102.0
#define GRID_IMAGE_HEIGHT 102.0
#define IMAGE_PADDING 1.0
#define MAIN_CONTENT_HEIGHT 367.0

@interface TAMediaResultsVC ()

@end

@implementation TAMediaResultsVC

@synthesize resultsMode = _resultsMode;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
	
    [super viewDidLoad];
    
    self.photos = [NSMutableArray array];
    
    // Set our custom nav bar title
    // to display the search input (City/Tag)
    NSString *tagString = @"";
    if (self.tagID) tagString = [NSString stringWithFormat:@"%@", self.tag];
    
    [self.searchInputTitle setText:[[NSString stringWithFormat:@"%@ %@", self.city, tagString] uppercaseString]];
    
    // Set the content insets - padding - for the main scroll view
	[self.gridScrollView setContentInset:UIEdgeInsetsMake(6.0, 0.0, 6.0, 0.0)];
    
    // No. of photos returned from findMedia
    fetchSize = 12;
    
    // By default, we want the view to be in 'Guides mode'
    // and for the guides sub nav button to be selected
    self.resultsMode = ResultsModeGuides;
    
    UIButton *guidesTabBtn = (UIButton *)[self.view viewWithTag:GUIDES_MODE_TAG];
    [guidesTabBtn setSelected:YES];
    [guidesTabBtn setHighlighted:NO];
    
    self.selectedTabButton = guidesTabBtn;
}


#pragma mark - Private Methods
- (AppDelegate *)appDelegate {
	
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}


- (void)viewDidUnload {
	
	self.tagID = nil;
	self.tag = nil;
	self.city = nil;
    
    self.guides = nil;
    self.photos = nil;
    
    self.findMediaRequest = nil;
    self.findGuidesRequest = nil;
	
    [self setSearchInputTitle:nil];
    [self setGuidesTable:nil];
    [self setGridScrollView:nil];
    
    self.selectedTabButton = nil;
    
    [super viewDidUnload];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)viewWillAppear:(BOOL)animated {

	[super viewWillAppear:animated];
    
    if (self.resultsMode == ResultsModeGuides && !guidesLoaded) {
        
        [self initFindGuidesAPI];
    }

    else if (!imagesLoaded) {
        
        [self initFindMediaAPI];
    }
}


- (void)viewWillDisappear:(BOOL)animated {
    
	[super viewWillDisappear:animated];
    
    if ([self.findMediaRequest inProgress]) {
        
        [self.findMediaRequest clearDelegatesAndCancel];
    }
    
    if ([self.findGuidesRequest inProgress])
        [self.findGuidesRequest clearDelegatesAndCancel];
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsIsnTableView:(UITableView *)tableView {
	
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


// Customize the appearance of table view cells.
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


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	// Retrieve the Guide object at the given index that's in self.guides
    Guide *guide = [self.guides objectAtIndex:[indexPath row]];
    
    TAGuideDetailsVC *guideDetailsVC = [[TAGuideDetailsVC alloc] initWithNibName:@"TAGuideDetailsVC" bundle:nil];
    [guideDetailsVC setGuideID:[guide guideID]];
    
    // Is this a guide that the logged-in user created or someone else's?
    [guideDetailsVC setGuideMode:GuideModeViewing];
    
    [self.navigationController pushViewController:guideDetailsVC animated:YES];
}



#pragma GridImageDelegate methods

- (void)gridImageButtonClicked:(NSInteger)viewTag {
	
	Photo *photo = [self.photos objectAtIndex:(viewTag - IMAGE_VIEW_TAG)];
	
	// Push the Image Details VC onto the stack
	TAScrollVC *horizontalScroll = [[TAScrollVC alloc] initWithNibName:@"TAScrollVC" bundle:nil];
	[horizontalScroll setPhotos:self.photos];
	[horizontalScroll setSelectedPhotoID:[photo photoID]];
	
	[self.navigationController pushViewController:horizontalScroll animated:YES];
}


#pragma MY METHODS

- (IBAction)goBack:(id)sender {

    [self.navigationController popViewControllerAnimated:YES];
}


- (void)showLoading {
	
	[SVProgressHUD showInView:self.view status:nil networkIndicator:YES posY:-1 maskType:SVProgressHUDMaskTypeClear];
}


- (void)hideLoading {
	
	[SVProgressHUD dismissWithSuccess:@"Loaded!"];
}


- (IBAction)subNavTabTapped:(id)sender {

    UIButton *btn = (UIButton *)sender;
    
    if (btn.tag != self.resultsMode) {
        
        [self.selectedTabButton setSelected:NO];
        
        [btn setSelected:YES];
        [btn setHighlighted:NO];
        
        self.selectedTabButton = btn;
        
        switch (btn.tag) {
                
            case ResultsModeGuides:
                self.resultsMode = ResultsModeGuides;
                [self fadeView:self.gridScrollView alpha:0.0 duration:0.5];
                [self fadeView:self.guidesTable alpha:1.0 duration:0.5];
                [self initFindGuidesAPI];
                break;
                
            case ResultsModePhotos:
                self.resultsMode = ResultsModePhotos;
                [self fadeView:self.guidesTable alpha:0.0 duration:0.5];
                [self fadeView:self.gridScrollView alpha:1.0 duration:0.5];
                [self initFindMediaAPI];
                break;
                
            default:
                break;
        }
    }
}


- (void)fadeView:(UIView *)view alpha:(CGFloat)alpha duration:(CGFloat)duration {
    
	[UIView animateWithDuration:duration animations:^{
		
		view.alpha = alpha;
		
	} completion:^(BOOL finished) {
		
		view.userInteractionEnabled = YES;
	}];
}


- (void)initFindGuidesAPI {
    
    NSString *tagString = @"";
    if (self.tagID) tagString = [NSString stringWithFormat:@"&tag=%i", self.tagID.intValue];
    
    NSString *jsonString = [NSString stringWithFormat:@"username=%@%@&city=%@&pg=%i&sz=%@&private=0&token=%@", [self appDelegate].loggedInUsername, tagString, self.city, 0, @"20", [[self appDelegate] sessionToken]];
	
	// Convert string to data for transmission
	NSMutableData *jsonData = [NSMutableData dataWithBytes:[jsonString UTF8String] length:[jsonString length]];
    
    // Create the URL that will be used to authenticate this user
	NSString *methodName = @"FindGuides";
	NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];

    self.findGuidesRequest = [ASIHTTPRequest requestWithURL:url];
    [self.findGuidesRequest addRequestHeader:@"Accept" value:@"application/json"];
    [self.findGuidesRequest addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
    [self.findGuidesRequest addRequestHeader:@"Content-Length" value:[NSString stringWithFormat:@"%d", [jsonData length]]];
    [self.findGuidesRequest setRequestMethod:@"POST"];
    
    //[self.findGuidesRequest setDownloadProgressDelegate:self.guidesProgressBar];
    
    [self.findGuidesRequest setPostBody:jsonData];
    [self.findGuidesRequest setDelegate:self];
    [self.findGuidesRequest setDidFinishSelector:@selector(findGuidesAPIFinished:)];
    [self.findGuidesRequest setDidFailSelector:@selector(findGuidesAPIFailed:)];
    [self.findGuidesRequest startAsynchronous];
}


- (void)findGuidesAPIFinished:(ASIHTTPRequest*)req {
    
    NSLog(@"findGuidesAPIFinished");

    if ([req.responseData length] > 0 && [req responseStatusCode] == 200) {
		
		guidesLoaded = YES;
        
        // Create a dictionary from the JSON string
        NSDictionary *results = [[req responseString] objectFromJSONString];
		
		// Build an array from the dictionary for easy access to each entry
		self.guides = (NSMutableArray *)[[self appDelegate] serializeGuideData:[results objectForKey:@"guides"]];
    }
	
	//[self hideLoading];
    
	// Reload the table
	[self.guidesTable reloadData];
}


- (void)findGuidesAPIFailed:(ASIHTTPRequest*)req {

    guidesLoaded = NO;
    
    //[self hideLoading];
}


- (void)initFindMediaAPI {
    
    NSString *tagIDString = @"";
    
    if (self.tagID) tagIDString = [NSString stringWithFormat:@"&tag=%i", self.tagID.intValue];
    
    // Convert string to data for transmission
	NSString *jsonString = [NSString stringWithFormat:@"username=%@&city=%@%@&pg=%i&size=%i&token=%@", [self appDelegate].loggedInUsername, self.city, tagIDString, imagesPageIndex, fetchSize, [[self appDelegate] sessionToken]];
	
	NSMutableData *jsonData = [NSMutableData dataWithBytes:[jsonString UTF8String] length:[jsonString length]];
	
	// Create the URL that will be used to authenticate this user
	NSString *methodName = @"FindMedia";
	NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];
    
    self.findMediaRequest = [ASIHTTPRequest requestWithURL:url];
    [self.findMediaRequest addRequestHeader:@"Accept" value:@"application/json"];
    [self.findMediaRequest addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
    [self.findMediaRequest addRequestHeader:@"Content-Length" value:[NSString stringWithFormat:@"%d", [jsonData length]]];
    [self.findMediaRequest setRequestMethod:@"POST"];
    
    //[self.findMediaRequest setDownloadProgressDelegate:self.guidesProgressBar];
    
    [self.findMediaRequest setPostBody:jsonData];
    [self.findMediaRequest setDelegate:self];
    [self.findMediaRequest setDidFinishSelector:@selector(findMediaAPIFinished:)];
    [self.findMediaRequest setDidFailSelector:@selector(findMediaAPIFailed:)];
    [self.findMediaRequest startAsynchronous];
}


- (void)findMediaAPIFinished:(ASIHTTPRequest*)req {
    
    NSLog(@"findMediaAPIFinished");
    
    if ([req.responseData length] > 0 && [req responseStatusCode] == 200) {
		
		imagesLoaded = YES;
        
        // Create a dictionary from the JSON string
        NSDictionary *results = [[req responseString] objectFromJSONString];
		
        NSArray *imagesArray = [results objectForKey:@"media"];
		
		// Take the data from the API, convert it
		// to Photos objects and store them in
		// self.photos array
		[self updatePhotosArray:imagesArray];
		
		[self findMediaRequestFinished];
    }
    
	// hide loading
	//[self hideLoading];
}


- (void)findMediaAPIFailed:(ASIHTTPRequest*)req {
    
    imagesLoaded = NO;
    
    self.findMediaRequest = nil;
    
   // [self hideLoading];
}


- (void)findMediaRequestFinished {
	
	// update the page index for
	// the next batch
	imagesPageIndex++;
	
	// Update the image grid
	[self updateImageGrid];
}


- (void)updateImageGrid {
	
	CGFloat gridWidth = self.gridScrollView.frame.size.width;
	CGFloat maxXPos = gridWidth - GRID_IMAGE_WIDTH;
	
	CGFloat startXPos = 0.0;
	CGFloat xPos = startXPos;
	CGFloat yPos = 0.0;
	
	// Number of new rows to add, and how many have already
	// been added previously
	NSInteger subviewsCount = [self.gridScrollView.subviews count];
	
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
		[self.gridScrollView addSubview:gridImage];
		
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
	NSInteger rowCount = [[self.gridScrollView subviews] count]/3;
	NSInteger leftOver = [[self.gridScrollView subviews] count]%3;
	if (leftOver > 0) rowCount++;
	
	// Update the scroll view's content height
	CGFloat gridRowsHeight = ((rowCount * (GRID_IMAGE_HEIGHT + IMAGE_PADDING))); //self.gridScrollView.frame.origin.y + 
    	
	CGFloat sViewContentHeight = gridRowsHeight + IMAGE_PADDING;
	
	// Adjust content height of the scroll view
	[self.gridScrollView setContentSize:CGSizeMake(self.gridScrollView.frame.size.width, sViewContentHeight)];
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
}


@end
