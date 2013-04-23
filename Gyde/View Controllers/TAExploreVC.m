//
//  TAExploreVC.m
//  Tourism App
//
//  Created by Richard Lee on 28/08/12.
//  Copyright (c) 2012 C2 Media Pty Ltd. All rights reserved.
//

#import "TAExploreVC.h"
#import "TACitiesVC.h"
#import "MyCoreLocation.h"
#import "JSONKit.h"
#import "HTTPFetcher.h"
#import "XMLFetcher.h"
#import "StringHelper.h"
#import "SVProgressHUD.h"
#import "CustomTabBarItem.h"
#import "TagsCell.h"
#import "TAThumbsSlider.h"
#import "TAScrollVC.h"
#import "TAGuideDetailsVC.h"
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "TAMediaResultsVC.h"


#define TABLE_HEADER_HEIGHT 9.0
#define TABLE_FOOTER_HEIGHT 4.0

#define THUMBS_SLIDER_HEIGHT 118.0
#define THUMBS_SLIDER_PADDING 10.0

#define REGULAR_SLIDERS_CONTAINER_Y_POS 44.0
#define HIDE_SLIDERS_CONTAINER_Y_POS 244.0

#define REGULAR_SLIDERS_CONTAINER_HEIGHT 367.0
#define HIDE_SLIDERS_CONTAINER_HEIGHT 167.0

#define START_RESULTS_Y_POS -323.0
#define END_RESULTS_Y_POS 44.0

#define START_FILTER_Y_POS -156.0
#define END_FILTER_Y_POS 44.0

#define START_TAGS_TABLE_HEIGHT 0.0
#define END_TAGS_TABLE_HEIGHT 115.0

#define START_TAGS_TABLE_Y_POS 79.0
#define END_TAGS_TABLE_Y_POS 89.0

#define START_CITIES_TABLE_Y_POS 35.0
#define END_CITIES_TABLE_Y_POS 45.0

#define START_CITIES_TABLE_HEIGHT 0.0
#define END_CITIES_TABLE_HEIGHT 155.0

#define REGULAR_SEARCH_BUTTON_Y_POS 107.0
#define HIDE_SEARCH_BUTTON_Y_POS 200.0

#define REGULAR_TAG_FIELD_Y_POS 54.0
#define HIDE_TAG_FIELD_Y_POS 120.0

#define ANIMATION_DURATION 0.25

#define POPULAR_PHOTOS_SLIDER_TAG 9000
#define RECENT_PHOTOS_SLIDER_TAG 9001
#define POPULAR_GUIDES_TAG 9002
#define RECENT_GUIDES_SLIDER_TAG 9003

#define GENERIC_SLIDER_TAG 9000
#define BARS_SLIDER_TAG 9001
#define CAFES_SLIDER_TAG 9002
#define MUSEUMS_SLIDER_TAG 9003
#define GALLERIES_SLIDER_TAG 9004
#define RESTAURANT_SLIDER_TAG 9005
#define SPORTS_SLIDER_TAG 9006

@interface TAExploreVC ()

@end

@implementation TAExploreVC

@synthesize selectedTag, selectedCity,  locationManager, currentLocation;
@synthesize exploreMode, tags, delegate;
@synthesize filterBtn, managedObjectContext, slidesContainer;
@synthesize popularPhotosSlider, recentGuidesSlider, popularGuidesSlider, recentPhotosSlider;
@synthesize tagsTable, nearbyBtn, searchBtn, filterView, tableData, tableMode;
@synthesize loadCell, tagFieldContainer, filtering, tagBtn;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	
    if (self) {
		
//		CustomTabBarItem *tabItem = [[CustomTabBarItem alloc] initWithTitle:@"" image:nil tag:0];
//        
//        tabItem.customHighlightedImage = [UIImage imageNamed:@"explore_tab_button-on.png"];
//        tabItem.customStdImage = [UIImage imageNamed:@"explore_tab_button.png"];
//		tabItem.imageInsets = UIEdgeInsetsMake(6.0, 0.0, -6.0, 0.0);
//		
//        self.tabBarItem = tabItem;
//        tabItem = nil;
    }
    return self;
}

- (void)viewDidLoad {
	
    [super viewDidLoad];
    
	// Init our main table data array
	self.tableData = [NSArray array];
    
    // How many items do we want to fetch with each API call?
    fetchSize = 6;
    
    // Requests to fire off for the thumbs sliders
    self.requests = [NSMutableArray array];
    self.popularGuides = [NSMutableArray array];
    self.recentGuides = [NSMutableArray array];
	
    
	// Fetch the Tags and Cities from Core Data
	// and populate the tags array
	[self fetchTags];
    [self fetchCities];
	
	
	// Added interactive states for buttons ///////////////////////////////////////////////////
    [self.filterBtn setImage:[UIImage imageNamed:@"explore-search-button-on.png"] forState:(UIControlStateHighlighted|UIControlStateSelected|UIControlStateDisabled)];
    
    [self createThumbsSliders];
	
	
	// Get user location
    MyCoreLocation *location = [[MyCoreLocation alloc] init];
    self.locationManager = location;
    
    // We are the delegate for the MyCoreLocation object
    [self.locationManager setCaller:self];
    
    [self initLocationManager];
    
}


#pragma mark - Private Methods
- (AppDelegate *)appDelegate {
	
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}


- (void)viewDidUnload {
	
	self.managedObjectContext = nil;
	self.locationManager = nil;
	self.currentLocation = nil;
	self.tags = nil;
	self.filterBtn = nil;
	
	self.selectedTag = nil;
	self.selectedCity = nil;
	
	self.popularPhotosSlider = nil;
	self.recentGuidesSlider = nil;
	self.popularGuidesSlider = nil;
	self.recentPhotosSlider = nil;
	
	self.slidesContainer = nil;
    
    [self setNavBarTitle:nil];
    [super viewDidUnload];
}


- (void)viewWillAppear:(BOOL)animated {
	
	[super viewWillAppear:animated];
    
    // Setup nav bar
	[self initNavBar];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - UITextField delegations
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    // If the current text field is username - put the focus on the password field
	if (textField == self.tagField) {
		
		[self.tagField resignFirstResponder];
		
		[self hideTagsTable];
		
		[self showSearchButton];
	}
	
	else if (textField == self.cityField) {
		
		[self.cityField resignFirstResponder];
		
		[self initCitySearchAPI];
	}
    
    return YES;
}


- (void)textFieldDidBeginEditing:(UITextField *)textField {
	
	// Show the tags table
	// so the user can select a new one
	if (textField == self.tagField) {
		
		self.tableMode = TableModeTags;
		
		self.tableData = self.tags;
		
		[self.tagsTable reloadData];
		
		[self showTagsTable];
	}
	
	else if (textField == self.cityField) {
        
		self.tableMode = TableModeCities;
        
        self.tableData = self.cities;
        
        [self.tagsTable reloadData];
		
        [self showCitiesTable];
		
		[self hideTagField];
	}
	
	if (self.searchBtn.alpha > 0.0) [self hideSearchButton];
}


- (BOOL)textFieldShouldClear:(UITextField *)textField {

    if (textField == self.cityField)
        self.selectedCity = nil;
    
    else
        self.selectedTag = nil;
    
    return YES;
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsIsnTableView:(UITableView *)tableView {
	
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	NSInteger numberOfRows = [self.tableData count];
    
    return numberOfRows;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TagsCell *cell = (TagsCell *)[tableView dequeueReusableCellWithIdentifier:[TagsCell reuseIdentifier]];
    
    if (cell == nil) {
        
        [[NSBundle mainBundle] loadNibNamed:@"TagsCell" owner:self options:nil];
        cell = loadCell;
        self.loadCell = nil;
    }
    
    
    /*
     Configure the backgroundView and selectedBackgroundView
     for the cell. Have to detect whether we're dealing
     with the first or last cell in the table - this will
     mean we need an image with a rounded border.
     */
    NSInteger row = [indexPath row];
    
    UIImage *bgViewImage;
    UIImage *selectedImage;
    
    
    if (row == ([self.tableData count] - 1)) {
        
        bgViewImage = [UIImage imageNamed:@"white-table-last-cell-bg.png"];
        selectedImage = [UIImage imageNamed:@"white-table-last-cell-bg-on.png"];
    }
    
    else if (row == 0) {
        
        bgViewImage = [UIImage imageNamed:@"white-table-cell-bg.png"];
        selectedImage = [UIImage imageNamed:@"white-table-cell-bg-on.png"];
    }
    
    else {
        
        bgViewImage = [UIImage imageNamed:@"white-table-cell-bg.png"];
        selectedImage = [UIImage imageNamed:@"white-table-last-cell-bg-on.png"];
    }
    
    
    UIImageView *bgView = [[UIImageView alloc] initWithImage:bgViewImage];
    cell.backgroundView = bgView;
    
    UIImageView *selBgView = [[UIImageView alloc] initWithImage:selectedImage];
    cell.selectedBackgroundView = selBgView;
    
    
    [self configureCell:cell atIndexPath:indexPath tableView:tableView];
    
    return cell;
}


- (void)configureCell:(TagsCell *)cell atIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView {
	
	NSString *cellText;
	
	if (self.tableMode == TableModeTags) {
        
		// Retrieve the Tag object from the tableData master array
		Tag *tag = [self.tableData objectAtIndex:[indexPath row]];
		
		cellText = [tag title];
	}
	
	else {
        
        City *city = [self.tableData objectAtIndex:[indexPath row]];
        cellText = [city title];
	}
	
	// Set the text of the cell
	cell.tagLabel.text = cellText;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	
	return TABLE_HEADER_HEIGHT;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.frame.size.width, TABLE_HEADER_HEIGHT)];
    [headerView setBackgroundColor:[UIColor clearColor]];
    
    if (tableView == self.tagsTable) {
        
        UIImage *roundedHeader = [UIImage imageNamed:@"white-table-rounded-header.png"];
        
        UIImageView *headerImage = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.frame.size.width, TABLE_HEADER_HEIGHT)];
        [headerImage setImage:roundedHeader];
        
        [headerView addSubview:headerImage];
    }
	
	return headerView;
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	
	return TABLE_FOOTER_HEIGHT;
}


- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.frame.size.width, TABLE_FOOTER_HEIGHT)];
    [headerView setBackgroundColor:[UIColor clearColor]];
    
    if (tableView == self.tagsTable) {
        
        UIImage *roundedHeader = [UIImage imageNamed:@"white-table-footer-shadow.png"];
        
        UIImageView *headerImage = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.frame.size.width, TABLE_FOOTER_HEIGHT)];
        [headerImage setImage:roundedHeader];
        
        [headerView addSubview:headerImage];
    }
	
	return headerView;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	// Check that we're dealing with the TagsTable table
    if (tableView == self.tagsTable) {
        
        if (self.tableMode == TableModeCities) {
            
            // Need to store the selected City dictionary
            // When the user clicks the 'Set' button this value will be passed
            // back to the delegate
            City *city = [self.tableData objectAtIndex:[indexPath row]];
            self.selectedCity = [city title];
            
            // Display the selected city in the search field
            self.cityField.text = self.selectedCity;
            
            // Hide the table now
            [self hideCitiesTable];
            
            [self showTagField];
            
            [self showSearchButton];
        }
        
        else {
            
            self.selectedTag = [self.tableData objectAtIndex:[indexPath row]];
            
            self.tagField.text = [self.selectedTag title];
            
            [self hideTagsTable];
            
            [self showSearchButton];
        }
    }
}


#pragma mark - Private Methods
- (void)updateLocationDidFinish:(CLLocation *)loc {
    
    self.currentLocation = loc;
	
	[self.locationManager stopUpdating];
	
	NSLog(@"FOUND LOCATION:%f\%f", self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude);
	
	[self startReverseGeocoding];
}


#pragma LocationsDelegate

- (void)locationSelected:(NSDictionary *)city {
	
	useCurrentLocation = NO;
	
	// Set the selected City
	[self setSelectedCity:[city objectForKey:@"city"]]; 
	
	// Set the city button's title to that of the City selected
	//[self.cityBtn setTitle:[self.selectedCity title] forState:UIControlStateNormal];
}


#pragma ThumsSliderDelegate methods

- (void)thumbTappedWithID:(NSString *)thumbID fromSlider:(TAThumbsSlider *)slider {

    
    if (slider == self.popularPhotosSlider) {
    
        NSMutableArray *arrayCopy = [self.featuredPhotos mutableCopy];
        
        TAScrollVC *horizontalScroll = [[TAScrollVC alloc] initWithNibName:@"TAScrollVC" bundle:nil];
        [horizontalScroll setPhotos:arrayCopy];
        
        [horizontalScroll setSelectedPhotoID:thumbID];
        
        [self.navigationController pushViewController:horizontalScroll animated:YES];
    }
    
    else if (slider == self.recentPhotosSlider) {
        
        NSMutableArray *arrayCopy = [self.recentPhotos mutableCopy];
        
        TAScrollVC *horizontalScroll = [[TAScrollVC alloc] initWithNibName:@"TAScrollVC" bundle:nil];
        [horizontalScroll setPhotos:arrayCopy];
        
        [horizontalScroll setSelectedPhotoID:thumbID];
        
        [self.navigationController pushViewController:horizontalScroll animated:YES];
    }
    
    else if (slider == self.recentGuidesSlider) {
        
        TAGuideDetailsVC *guideDetailsVC = [[TAGuideDetailsVC alloc] initWithNibName:@"TAGuideDetailsVC" bundle:nil];
        [guideDetailsVC setGuideID:thumbID];
        
        [self.navigationController pushViewController:guideDetailsVC animated:YES];
    }
    
    else if (slider == self.popularGuidesSlider) {
        
        TAGuideDetailsVC *guideDetailsVC = [[TAGuideDetailsVC alloc] initWithNibName:@"TAGuideDetailsVC" bundle:nil];
        [guideDetailsVC setGuideID:thumbID];
        
        [self.navigationController pushViewController:guideDetailsVC animated:YES];
    }
}


- (void)initNavBar {
	
	// Hide default nav bar
	self.navigationController.navigationBarHidden = YES;
	
}


- (IBAction)goBack:(id)sender {
	
	[self.navigationController popViewControllerAnimated:YES];
}


- (void)initLocationManager {

    [self.navBarTitle setText:@"LOADING"];
    
    // Start find the user's location
    [self showLoadingWithStatus:@"Updating your location"];
    [self.locationManager startUpdating];
}


- (void)willLogout {
    
    [self.navigationController popToRootViewControllerAnimated:NO];
}


- (void)fadeOut:(UIView *)view {

    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
		
		view.alpha = 0.0;
		
	} completion:^(BOOL finished) {
		
		// callback functionality
	}];
}


- (IBAction)filterButtonTapped:(id)sender {
    
	if (filtering) {
		
		[self.filterBtn setSelected:NO];
		[self.filterBtn setHighlighted:NO];
		
		[self hideFilterView];
		
		[self showSlidersContainer];
	}
	
	else {
		
		[self.filterBtn setSelected:YES];
		[self.filterBtn setHighlighted:NO];
		
		[self showFilterView];
		
		[self hideSlidersContainer];
	}
    
    if (searching) {
        
        searching = NO;
    }
	
	filtering = !filtering;
}


- (IBAction)searchButtonTapped:(id)sender {
	
	// Hide the filter view
	// animate up
	[self filterButtonTapped:nil];
    
    // We are now in search mode
    searching = YES;
    
    TAMediaResultsVC *searchResults = [[TAMediaResultsVC alloc] initWithNibName:@"TAMediaResultsVC" bundle:nil];
    [searchResults setTag:[self.selectedTag title]];
    [searchResults setTagID:[self.selectedTag tagID]];
    [searchResults setCity:self.selectedCity];
    
    [self.navigationController pushViewController:searchResults animated:YES];
}


- (void)hideSlidersContainer {
    
	// Set the new frame for the table
	CGRect newFrame = self.slidesContainer.frame;
	newFrame.origin.y = HIDE_SLIDERS_CONTAINER_Y_POS;
	newFrame.size.height = CGRectGetHeight(self.view.frame) - (44.0 + CGRectGetHeight(self.filterView.frame));
	
	[UIView animateWithDuration:ANIMATION_DURATION animations:^{
		
		self.slidesContainer.frame = newFrame;
		
	} completion:^(BOOL finished) {
		
		// callback functionality?
	}];
}


- (void)showSlidersContainer {
	
	// Set the new frame for the table
	CGRect newFrame = self.slidesContainer.frame;
	newFrame.origin.y = REGULAR_SLIDERS_CONTAINER_Y_POS;
	newFrame.size.height = CGRectGetHeight(self.view.frame) - (44.0);
	
	[UIView animateWithDuration:ANIMATION_DURATION animations:^{
		
		self.slidesContainer.frame = newFrame;
		
	} completion:^(BOOL finished) {
		
		// callback functionality?
	}];
}


- (void)showFilterView {
	
	// Set the new frame for the table
	CGRect newFrame = self.filterView.frame;
	newFrame.origin.y = END_FILTER_Y_POS;
	
	[UIView animateWithDuration:ANIMATION_DURATION animations:^{
		
		self.filterView.frame = newFrame;
		
	} completion:^(BOOL finished) {
		
		// enable nearby btn?
		
		// enable city search field?
		
		// enable tag search field?
	}];
}


- (void)hideFilterView {
	
	if ([self.cityField isFirstResponder] || [self.tagField isFirstResponder]) [self hideKeyboard];
	
	// Set the new frame for the table
	CGRect newFrame = self.filterView.frame;
	newFrame.origin.y = START_FILTER_Y_POS;
	
	[UIView animateWithDuration:ANIMATION_DURATION animations:^{
		
		self.filterView.frame = newFrame;
		
	} completion:^(BOOL finished) {
		
		// enable nearby btn?
		
		// enable city search field?
		
		// enable tag search field?
	}];
}


- (void)startReverseGeocoding {
    
    self.reverseGeocoder = [[MKReverseGeocoder alloc] initWithCoordinate:self.currentLocation.coordinate];
    self.reverseGeocoder.delegate = self;
    [self.reverseGeocoder start];
}


- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error
{
    NSLog(@"MKReverseGeocoder has failed.");
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Location error" message:@"There was an error calculating your current city. Please check your network connection." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [av show];
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark
{
    MKPlacemark * myPlacemark = placemark;
    NSString *subLocality=myPlacemark.subLocality;
    
    //    NSLog(@"city%@",city);
    //    NSLog(@"subThrough%@",subThrough);
    //    NSLog(@"locality%@",locality);
    //    NSLog(@"subLocality%@",subLocality);
    //    NSLog(@"adminisArea%@",adminisArea);
    //    NSLog(@"subAdminArea%@",subAdminArea);
    //    NSLog(@"postalCode%@",postalCode);
    //    NSLog(@"country%@",country);
    //    NSLog(@"countryCode%@",countryCode);
    
    self.selectedCity = subLocality;
    
    // City has been found - update the nav bar title
    [self.navBarTitle setText:[self.selectedCity uppercaseString]];
    
    [self createThumbsRequests];
    
	[self hideLoading];
}


- (void)retrieveLocationData {
	
	// Create JSON call to retrieve dummy City values
	NSString *methodName = @"geocode";
	NSString *yahooURL = @"http://where.yahooapis.com/";
	NSString *yahooAPIKey = @"UvRWaq30";
	
	NSString *urlString = [NSString stringWithFormat:@"%@%@?q=%f,%f&gflags=R&appid=%@", yahooURL, methodName, self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude, yahooAPIKey];
	NSLog(@"YAHOO URL:%@", urlString);
	
	NSURL *url = [urlString convertToURL];
	
	// Create the request.
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
														   cachePolicy:NSURLRequestUseProtocolCachePolicy
													   timeoutInterval:45.0];
	[request setValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
	[request setHTTPMethod:@"GET"];
	
    if (cityFetcher) {
        
		[cityFetcher cancel];
		cityFetcher = nil;
	}
    
    
	// XML Fetcher
	cityFetcher = [[XMLFetcher alloc] initWithURLRequest:request xPathQuery:@"//ResultSet" receiver:self action:@selector(receivedYahooResponse:)];
	[cityFetcher start];
}


// Example fetcher response handling
- (void)receivedYahooResponse:(XMLFetcher *)aFetcher {
    
    if (![aFetcher isEqual:cityFetcher])
        return;
	
	BOOL requestSuccess = NO;
	BOOL errorDected = NO;
	
	//NSLog(@"PRINTING YAHOO DATA:%@",[[NSString alloc] initWithData:theXMLFetcher.data encoding:NSASCIIStringEncoding]);
	
	// IF STATUS CODE WAS OKAY (200)
	if ([cityFetcher statusCode] == 200) {
		
		// XML Data was returned from the API successfully
		if (([cityFetcher.data length] > 0) && ([cityFetcher.results count] > 0)) {
			
			requestSuccess = YES;
			
			XPathResultNode *versionsNode = [cityFetcher.results lastObject];
			
			// loop through the children of the <registration> node
			for (XPathResultNode *child in versionsNode.childNodes) {
				
				if ([[child name] isEqualToString:@"ErrorMessage"]) {
					
					errorDected = ([[child contentString] isEqualToString:@"No error"] ? NO : YES);
				}
				
				else if ([[child name] isEqualToString:@"Result"]) {
					
					for (XPathResultNode *childNode in child.childNodes) {
						
						if ([[childNode name] isEqualToString:@"city"] && [[childNode contentString] length] > 0) { 
							
							self.selectedCity = [childNode contentString];
						}
					}
				}
			}
		}
	}
    
	if (requestSuccess && !errorDected) {
		
        // City has been found - update the nav bar title
        [self.navBarTitle setText:[self.selectedCity uppercaseString]];
        
        [self createThumbsRequests];
	}
	else {
		
		UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Sorry!" message:@"We were unable to locate your current city. Please search for one." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
		[av show];
	}
	
	[self hideLoading];
    
    cityFetcher = nil;	
	
}


- (void)showLoadingWithStatus:(NSString *)status {
	
	[SVProgressHUD showInView:self.view status:status networkIndicator:YES posY:-1 maskType:SVProgressHUDMaskTypeClear];
}


- (void)hideLoading {
	
	[SVProgressHUD dismissWithSuccess:@"Loaded!"];
}


- (void)createThumbsSliders {
	
	CGFloat xPos = 0.0;
	CGFloat yPos = 12.0;
	

    CGRect tsFrame = CGRectMake(xPos, yPos, 320.0, THUMBS_SLIDER_HEIGHT);
    TAThumbsSlider *slider = [[TAThumbsSlider alloc] initWithFrame:tsFrame title:@"Popular Places" photosCount:@"0"];
    [slider setSliderMode:SliderModePhotos];
    [slider setDelegate:self];
    [slider setTag:POPULAR_PHOTOS_SLIDER_TAG];
    
    self.popularPhotosSlider = slider;

    [self.slidesContainer addSubview:self.popularPhotosSlider];
    
    
    yPos += (THUMBS_SLIDER_HEIGHT + THUMBS_SLIDER_PADDING);
    

    CGRect tsFrame2 = CGRectMake(xPos, yPos, 320.0, THUMBS_SLIDER_HEIGHT);
    TAThumbsSlider *slider2 = [[TAThumbsSlider alloc] initWithFrame:tsFrame2 title:@"Recent Places" photosCount:@"0"];
    [slider2 setSliderMode:SliderModePhotos];
    [slider2 setDelegate:self];
    [slider2 setTag:RECENT_PHOTOS_SLIDER_TAG];
		
    self.recentPhotosSlider = slider2;
    
    [self.slidesContainer addSubview:self.recentPhotosSlider];
    
    
    yPos += (THUMBS_SLIDER_HEIGHT + THUMBS_SLIDER_PADDING);
    
    
    CGRect tsFrame3 = CGRectMake(xPos, yPos, 320.0, THUMBS_SLIDER_HEIGHT);
    TAThumbsSlider *slider3 = [[TAThumbsSlider alloc] initWithFrame:tsFrame3 title:@"Popular Guides" photosCount:@"0"];
    [slider3 setSliderMode:SliderModeGuides];
    [slider3 setDelegate:self];
    [slider3 setTag:POPULAR_GUIDES_TAG];
    
    self.popularGuidesSlider = slider3;
    
    [self.slidesContainer addSubview:self.popularGuidesSlider];
    
    
    yPos += (THUMBS_SLIDER_HEIGHT + THUMBS_SLIDER_PADDING);
    
    
    CGRect tsFrame4 = CGRectMake(xPos, yPos, 320.0, THUMBS_SLIDER_HEIGHT);
    TAThumbsSlider *slider4 = [[TAThumbsSlider alloc] initWithFrame:tsFrame4 title:@"Recent Guides" photosCount:@"0"];
    [slider4 setSliderMode:SliderModeGuides];
    [slider4 setDelegate:self];
    [slider4 setTag:RECENT_GUIDES_SLIDER_TAG];
    
    self.recentGuidesSlider = slider4;
    
    [self.slidesContainer addSubview:self.recentGuidesSlider];    
    
    [self.slidesContainer setContentSize:CGSizeMake(self.slidesContainer.frame.size.width, (yPos+THUMBS_SLIDER_HEIGHT))];
    [self.slidesContainer setContentInset:UIEdgeInsetsMake(0, 0, 14, 0)];
    
}


- (NSMutableArray *)createSliderData:(NSArray *)photosArray {

	NSMutableArray *photoDictionaries = [NSMutableArray array];
	
	for (Photo *photo in photosArray) {
		
		NSDictionary *photoData = [NSDictionary dictionaryWithObject:[photo thumbURL] forKey:[photo photoID]];
		
		[photoDictionaries addObject:photoData];
	}
	
	return photoDictionaries;
}


- (NSMutableArray *)createSliderDataWithGuides:(NSArray *)guidesArray {
    
	NSMutableArray *guideDictionaries = [NSMutableArray array];
	
	for (Guide *guide in guidesArray) {
		
		NSDictionary *guideData = [NSDictionary dictionaryWithObject:[guide thumbURL] forKey:[guide guideID]];
		
		[guideDictionaries addObject:guideData];
	}
	
	return guideDictionaries;
}


- (void)createThumbsRequests {
    
    // If there are old requests still in the array
    // then remove them.
    if ([self.requests count] > 0) [self.requests removeAllObjects];
    
    NSString *defaultCity = self.selectedCity;
    NSString *apiMethodName = @"FindMedia";
    NSString *token = [[self appDelegate] sessionToken];
    NSString *username =  [self appDelegate].loggedInUsername;
    NSInteger pageNum = 0;
    
    // Convert string to data for transmission
    NSString *jsonString = [NSString stringWithFormat:@"username=%@&city=%@&pg=%i&sz=%i&sort=%@&token=%@", [self appDelegate].loggedInUsername, defaultCity, pageNum, fetchSize, @"popular", [[self appDelegate] sessionToken]];
    NSMutableData *jsonData = [NSMutableData dataWithBytes:[jsonString UTF8String] length:[jsonString length]];
    
    // Create the URL that will be used to authenticate this user
	NSURL *url = [[self appDelegate] createRequestURLWithMethod:apiMethodName testMode:NO];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    [request addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
    [request addRequestHeader:@"Content-Length" value:[NSString stringWithFormat:@"%d", [jsonData length]]];
    [request setRequestMethod:@"POST"];
    [request setTag:BARS_SLIDER_TAG];
    
    TAThumbsSlider *slider = (TAThumbsSlider *)[self.view viewWithTag:BARS_SLIDER_TAG];
    [request setDownloadProgressDelegate:slider.progressBar];
    [slider.progressBar setHidden:NO];
    
    [request setPostBody:jsonData];
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(popularPlacesFinished:)];
    [request setDidFailSelector:@selector(requestWentWrong:)];
    
    [self.requests addObject:request];
    
    
    // Convert string to data for transmission
    NSString *recentPlacesString = [NSString stringWithFormat:@"username=%@&city=%@&pg=%i&sz=%i&sort=%@&token=%@", [self appDelegate].loggedInUsername, defaultCity, pageNum, fetchSize, @"latest", [[self appDelegate] sessionToken]];
    NSMutableData *cafesData = [NSMutableData dataWithBytes:[recentPlacesString UTF8String] length:[recentPlacesString length]];
    
    // Create the URL that will be used to authenticate this user
	NSURL *cafesRequestURL = [[self appDelegate] createRequestURLWithMethod:apiMethodName testMode:NO];
    
    ASIHTTPRequest *cafesRequest = [ASIHTTPRequest requestWithURL:cafesRequestURL];
    [cafesRequest addRequestHeader:@"Accept" value:@"application/json"];
    [cafesRequest addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
    [cafesRequest addRequestHeader:@"Content-Length" value:[NSString stringWithFormat:@"%d", [jsonData length]]];
    [cafesRequest setRequestMethod:@"POST"];
    [cafesRequest setTag:CAFES_SLIDER_TAG];
    
    TAThumbsSlider *cafesSlider = (TAThumbsSlider *)[self.view viewWithTag:CAFES_SLIDER_TAG];
    [cafesRequest setDownloadProgressDelegate:cafesSlider.progressBar];
    [cafesSlider.progressBar setHidden:NO];
    
    [cafesRequest setPostBody:cafesData];
    [cafesRequest setDelegate:self];
    [cafesRequest setDidFinishSelector:@selector(recentPlacesFinished:)];
    [cafesRequest setDidFailSelector:@selector(requestWentWrong:)];
    
    [self.requests addObject:cafesRequest];
    
    
    // Convert string to data for transmission
    NSString *popularGuidesString = [NSString stringWithFormat:@"pg=%i&sz=%i&token=%@", pageNum, fetchSize, [[self appDelegate] sessionToken]];
    NSMutableData *museumsData = [NSMutableData dataWithBytes:[popularGuidesString UTF8String] length:[popularGuidesString length]];
    
    // Create the URL that will be used to authenticate this user
	NSURL *museumsRequestURL = [[self appDelegate] createRequestURLWithMethod:@"popularguides" testMode:NO];
    
    ASIHTTPRequest *museumsRequest = [ASIHTTPRequest requestWithURL:museumsRequestURL];
    [museumsRequest addRequestHeader:@"Accept" value:@"application/json"];
    [museumsRequest addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
    [museumsRequest addRequestHeader:@"Content-Length" value:[NSString stringWithFormat:@"%d", [museumsData length]]];
    [museumsRequest setRequestMethod:@"POST"];
    [museumsRequest setTag:MUSEUMS_SLIDER_TAG];
    
    TAThumbsSlider *museumsSlider = (TAThumbsSlider *)[self.view viewWithTag:MUSEUMS_SLIDER_TAG];
    [museumsRequest setDownloadProgressDelegate:museumsSlider.progressBar];
    [museumsSlider.progressBar setHidden:NO];
    
    [museumsRequest setPostBody:museumsData];
    [museumsRequest setDelegate:self];
    [museumsRequest setDidFinishSelector:@selector(popularGuidesFinished:)];
    [museumsRequest setDidFailSelector:@selector(requestWentWrong:)];
    
    [self.requests addObject:museumsRequest];
    
    
    // Convert string to data for transmission
    NSString *latestGuidesString = [NSString stringWithFormat:@"pg=%i&sz=%i&token=%@", pageNum, fetchSize, [[self appDelegate] sessionToken]];
    NSMutableData *galleriesData = [NSMutableData dataWithBytes:[latestGuidesString UTF8String] length:[latestGuidesString length]];
    
    // Create the URL that will be used to authenticate this user
	NSURL *galleriesRequestURL = [[self appDelegate] createRequestURLWithMethod:@"latestguides" testMode:NO];
    
    ASIHTTPRequest *galleriesRequest = [ASIHTTPRequest requestWithURL:galleriesRequestURL];
    [galleriesRequest addRequestHeader:@"Accept" value:@"application/json"];
    [galleriesRequest addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
    [galleriesRequest addRequestHeader:@"Content-Length" value:[NSString stringWithFormat:@"%d", [galleriesData length]]];
    [galleriesRequest setRequestMethod:@"POST"];
    [galleriesRequest setTag:GALLERIES_SLIDER_TAG];
    
    TAThumbsSlider *galleriesSlider = (TAThumbsSlider *)[self.view viewWithTag:GALLERIES_SLIDER_TAG];
    [galleriesRequest setDownloadProgressDelegate:galleriesSlider.progressBar];
    [galleriesSlider.progressBar setHidden:NO];
    
    [galleriesRequest setPostBody:galleriesData];
    [galleriesRequest setDelegate:self];
    [galleriesRequest setDidFinishSelector:@selector(recentGuidesFinished:)];
    [galleriesRequest setDidFailSelector:@selector(requestWentWrong:)];
    
    [self.requests addObject:galleriesRequest];
    
    [self getThumbsSliderData];
}



// This method creates self.queue if it hasn't
// been initialized. It also iterates through
// the requests array and adds each request to
// self.queue. The network queue is then fired.
- (void)getThumbsSliderData {
    
    if(!self.queue) {
        
        self.queue = [[ASINetworkQueue alloc] init];
        [self.queue setQueueDidFinishSelector:@selector(thumbsQueueFinished:)];
        [self.queue setShouldCancelAllRequestsOnFailure:NO];
        [self.queue setDelegate:self];
    }
    
    for(ASIHTTPRequest *request in self.requests)
        [self.queue addOperation:request];
    
    slidersLoaded = NO;
    
    [self.queue go];
    
}


- (void)thumbsQueueFinished:(ASINetworkQueue *)queue {

    slidersLoaded = YES;
}


- (void)popularPlacesFinished:(ASIHTTPRequest*)req {
    
    //NSLog(@"PHOTOS FINISHED:%@", [req responseString]);
    
    // Create a dictionary from the JSON string
    NSDictionary *results = [[req responseString] objectFromJSONString];
    
    // Build an array from the dictionary for easy access to each entry
    self.featuredPhotos = [[self appDelegate] serializePhotoData:[results objectForKey:@"media"]];

    NSMutableArray *photoDictionaries = [self createSliderData:self.featuredPhotos];
    [self.popularPhotosSlider setImages:photoDictionaries];
    
    // Hide the slider's progress bar
    [self.popularPhotosSlider.progressBar setHidden:YES];
    
    featuredPhotosLoaded = YES;
}


- (void)recentPlacesFinished:(ASIHTTPRequest*)req {
    
    //NSLog(@"RECENT PHOTOS FINISHED:%@", [req responseString]);
    
    // Create a dictionary from the JSON string
    NSDictionary *results = [[req responseString] objectFromJSONString];
    
    // Build an array from the dictionary for easy access to each entry
    self.recentPhotos = [[self appDelegate] serializePhotoData:[results objectForKey:@"media"]];
    
    NSMutableArray *photoDictionaries = [self createSliderData:self.recentPhotos];
    [self.recentPhotosSlider setImages:photoDictionaries];
    
    // Hide the slider's progress bar
    [self.recentPhotosSlider.progressBar setHidden:YES];
    
    recentPhotosLoaded = YES;
}


- (void)recentGuidesFinished:(ASIHTTPRequest*)req {
    
    //NSLog(@"FEATURED GUIDES FINISHED:%@", [req responseString]);
    
    // Create a dictionary from the JSON string
    NSDictionary *results = [[req responseString] objectFromJSONString];
    
    // Build an array from the dictionary for easy access to each entry
    self.recentGuides = [[self appDelegate] serializeGuideData:[results objectForKey:@"guides"]];
    
    NSMutableArray *photoDictionaries = [self createSliderDataWithGuides:self.recentGuides];
    [self.recentGuidesSlider setImages:photoDictionaries];
    
    // Hide the slider's progress bar
    [self.recentGuidesSlider.progressBar setHidden:YES];
    
    featuredGuidesLoaded = YES;
}


- (void)popularGuidesFinished:(ASIHTTPRequest*)req {
    
    //NSLog(@"POPULAR GUIDES FINISHED:%@", [req responseString]);
    
    // Create a dictionary from the JSON string
    NSDictionary *results = [[req responseString] objectFromJSONString];
    
    // Build an array from the dictionary for easy access to each entry
    self.popularGuides = [[self appDelegate] serializeGuideData:[results objectForKey:@"guides"]];
    
    NSMutableArray *photoDictionaries = [self createSliderDataWithGuides:self.popularGuides];    
    
    [self.popularGuidesSlider setImages:photoDictionaries];
    
    // Hide the slider's progress bar
    [self.popularGuidesSlider.progressBar setHidden:YES];
    
    popularGuidesLoaded = YES;
}


/*
 Determines whether the city text field
 or tag text field are currently the
 first responder. If either of them are
 then the keyboard is hidden */
- (void)hideKeyboard {
    
	if ([self.cityField isFirstResponder]) [self.cityField resignFirstResponder];
	
	else if ([self.tagField isFirstResponder]) [self.tagField resignFirstResponder];
}


#pragma TagsDelegate

- (void)fetchTags {
	
	// Create fetch request
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:[NSEntityDescription entityForName:@"Tag" inManagedObjectContext:self.managedObjectContext]];
	[fetchRequest setPredicate:nil];
	[fetchRequest setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:NO]]];
	
	// Execute the fetch request
	NSError *error = nil;
	self.tags = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
}


- (void)fetchCities {
	
	// Create fetch request
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:[NSEntityDescription entityForName:@"City" inManagedObjectContext:self.managedObjectContext]];
	[fetchRequest setPredicate:nil];
	[fetchRequest setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:NO]]];
	
	// Execute the fetch request
	NSError *error = nil;
	self.cities = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    NSLog(@"FETCHED CITIES:%@", self.cities);
}


- (void)hideTagField {
    
	CGFloat alpha = 0.0;
	
	// Disable any user interaction
	self.tagField.userInteractionEnabled = NO;
	
	// Set the new frame for the table
	CGRect newFrame = self.tagFieldContainer.frame;
	newFrame.origin.y = HIDE_TAG_FIELD_Y_POS;
	
	[UIView animateWithDuration:ANIMATION_DURATION animations:^{
		
		self.tagFieldContainer.frame = newFrame;
		self.tagFieldContainer.alpha = alpha;
		
	} completion:^(BOOL finished) {
		
		// callback functionality
	}];
}


- (void)showTagField {
	
	CGFloat alpha = 1.0;
	
	// Set the new frame for the table
	CGRect newFrame = self.tagFieldContainer.frame;
	newFrame.origin.y = REGULAR_TAG_FIELD_Y_POS;
	
	[UIView animateWithDuration:ANIMATION_DURATION animations:^{
		
		self.tagFieldContainer.frame = newFrame;
		self.tagFieldContainer.alpha = alpha;
		
	} completion:^(BOOL finished) {
		
		// Enable any user interaction
		self.tagField.userInteractionEnabled = YES;
	}];
}


- (void)showCitiesTable {
	
	
	// Reposition to the starting animation point
	// in case the user was just in tags mode
	if (self.tagsTable.frame.origin.y != START_CITIES_TABLE_Y_POS) {
        
		// Set the new frame for the table
		CGRect newFrame = self.tagsTable.frame;
		newFrame.origin.y = START_CITIES_TABLE_Y_POS;
		newFrame.size.height = START_CITIES_TABLE_HEIGHT;
		self.tagsTable.frame = newFrame;
	}
	
	
	CGFloat alpha = 1.0;
	
	// Set the new frame for the table
	CGRect newFrame = self.tagsTable.frame;
	newFrame.origin.y = END_CITIES_TABLE_Y_POS;
	newFrame.size.height = END_CITIES_TABLE_HEIGHT;
	
	[UIView animateWithDuration:ANIMATION_DURATION animations:^{
		
		self.tagsTable.frame = newFrame;
		self.tagsTable.alpha = alpha;
		
	} completion:^(BOOL finished) {
		
		self.tagsTable.userInteractionEnabled = YES;
	}];
}


- (void)hideCitiesTable {
	
	CGFloat alpha = 0.0;
	
	// Disable any user interaction
	self.tagsTable.userInteractionEnabled = NO;
	
	// Set the new frame for the table
	CGRect newFrame = self.tagsTable.frame;
	newFrame.origin.y = START_CITIES_TABLE_Y_POS;
	newFrame.size.height = START_CITIES_TABLE_HEIGHT;
	
	[UIView animateWithDuration:ANIMATION_DURATION animations:^{
		
		self.tagsTable.frame = newFrame;
		self.tagsTable.alpha = alpha;
		
	} completion:^(BOOL finished) {
		
		[self showSearchButton];
	}];
}


- (void)showTagsTable {
	
	
	// Reposition to the starting animation point
	// in case the user was just in tags mode
	if (self.tagsTable.frame.origin.y != START_TAGS_TABLE_Y_POS) {
		
		// Set the new frame for the table
		CGRect newFrame = self.tagsTable.frame;
		newFrame.origin.y = START_TAGS_TABLE_Y_POS;
		newFrame.size.height = START_TAGS_TABLE_HEIGHT;
		self.tagsTable.frame = newFrame;
	}
    
	CGFloat alpha = 1.0;
	
	// Set the new frame for the table
	CGRect newFrame = self.tagsTable.frame;
	newFrame.origin.y = END_TAGS_TABLE_Y_POS;
	newFrame.size.height = END_TAGS_TABLE_HEIGHT;
	
	[UIView animateWithDuration:ANIMATION_DURATION animations:^{
		
		self.tagsTable.frame = newFrame;
		self.tagsTable.alpha = alpha;
		
	} completion:^(BOOL finished) {
		
		self.tagsTable.userInteractionEnabled = YES;
	}];
}


- (void)hideTagsTable {
	
	CGFloat alpha = 0.0;
	
	// Disable any user interaction
	self.tagsTable.userInteractionEnabled = NO;
	
	// Set the new frame for the table
	CGRect newFrame = self.tagsTable.frame;
	newFrame.origin.y = START_TAGS_TABLE_Y_POS;
	newFrame.size.height = START_TAGS_TABLE_HEIGHT;
	
	[UIView animateWithDuration:ANIMATION_DURATION animations:^{
		
		self.tagsTable.frame = newFrame;
		self.tagsTable.alpha = alpha;
		
	} completion:^(BOOL finished) {
        
	}];
}


- (void)showSearchButton {
	
	CGFloat alpha = 1.0;
	
	// Set the new frame for the table
	CGRect newFrame = self.searchBtn.frame;
	newFrame.origin.y = REGULAR_SEARCH_BUTTON_Y_POS;
	
	[UIView animateWithDuration:ANIMATION_DURATION animations:^{
		
		self.searchBtn.frame = newFrame;
		self.searchBtn.alpha = alpha;
		
	} completion:^(BOOL finished) {
		
		self.searchBtn.enabled = YES;
	}];
}


- (void)hideSearchButton {
	
	// disable tap
	self.searchBtn.enabled = NO;
	
	CGFloat alpha = 0.0;
	
	// Set the new frame for the table
	CGRect newFrame = self.searchBtn.frame;
	newFrame.origin.y = HIDE_SEARCH_BUTTON_Y_POS;
	
	[UIView animateWithDuration:ANIMATION_DURATION animations:^{
		
		self.searchBtn.frame = newFrame;
		self.searchBtn.alpha = alpha;
		
	} completion:^(BOOL finished) {
		
		// any callback functionality?
	}];
}


- (void)tagSelected:(Tag *)tag {
	
	// Set the selected Tag
	[self setSelectedTag:tag];
	
	// Set the Tag button's title to that of the Location's
	[self.tagBtn setTitle:tag.title forState:UIControlStateNormal];
}


- (void)initCitySearchAPI {
	
	NSString *postString = [NSString stringWithFormat:@"q=%@", self.cityField.text];
	NSData *postData = [NSData dataWithBytes:[postString UTF8String] length:[postString length]];
	
	// Create the URL that will be used to authenticate this user
	NSString *methodName = @"citysearch";
	NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];
	
	// Initialiase the URL Request
	NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:postData];
	
	citySearchFetcher = [[HTTPFetcher alloc] initWithURLRequest:request
                                                       receiver:self action:@selector(receivedCitySearchResponse:)];
	[citySearchFetcher start];
}


// Example fetcher response handling
- (void)receivedCitySearchResponse:(HTTPFetcher *)aFetcher {
    
    HTTPFetcher *theJSONFetcher = (HTTPFetcher *)aFetcher;
    
    NSAssert(aFetcher == citySearchFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	// We are not loading
	loading = NO;
	
	//NSLog(@"PRINTING CITY SEARCH DATA:%@",[[NSString alloc] initWithData:theJSONFetcher.data encoding:NSASCIIStringEncoding]);
	
	NSInteger statusCode = [theJSONFetcher statusCode];
    
    if ([theJSONFetcher.data length] > 0 && statusCode == 200) {
		
		// We've finished loading the cities
		citiesLoaded = YES;
        
        // Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		
		// Create a dictionary from the JSON string
		NSDictionary *results = [jsonString objectFromJSONString];
		
		// Build an array from the dictionary for easy access to each entry
		[self updateCitiesArray:[results objectForKey:@"cities"]];
    }
	
	[self hideLoading];
	
	if (citiesLoaded) {
		
		self.tableData = self.cities;
		
		[self.tagsTable reloadData];
		
		// Show the city results
		[self showCitiesTable];
	}
    
    citySearchFetcher = nil;
}


- (void)updateCitiesArray:(NSArray *)newCities {
    
    for (NSDictionary *cityDict in newCities) {
        
        [City cityWithTitle:[cityDict objectForKey:@"city"] inManagedObjectContext:self.managedObjectContext];
    }
    
    [self fetchCities];
}


- (IBAction)nearbyButtonTapped:(id)sender {
	
	
	// HIDE KEYBOARD
	if ([self.cityField isFirstResponder] || [self.tagField isFirstResponder])
        [self hideKeyboard];
	
	
	// HIDE CITIES TABLE
	if (self.tagsTable.alpha > 0.0) {
        
        [self hideTagsTable];
        
		//if (self.tableMode == TableModeCities) [self hideCitiesTable];
		
		//else [self hideTagsTable];
	}
	
	
	/*	Check if the location manager
     is working. If not, let it
     start calculating the user's location */
	
	if (!self.locationManager.updating) {
		
		[self.nearbyBtn setSelected:YES];
		[self.nearbyBtn setHighlighted:NO];
		
		[self showLoading];
		
		[self.locationManager startUpdating];
	}
	
	else {
		
		UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Sorry!" message:@"Still updating your location!" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
		[av show];
	}
}


- (void)showLoading {
	
	[SVProgressHUD showInView:self.view status:nil networkIndicator:YES posY:-1 maskType:SVProgressHUDMaskTypeClear];
}



@end
