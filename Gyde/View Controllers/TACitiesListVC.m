//
//  TACitiesListVC.m
//  Tourism App
//
//  Created by Richard Lee on 30/08/12.
//  Copyright (c) 2012 C2 Media Pty Ltd. All rights reserved.
//

#import "TACitiesListVC.h"
#import "SVProgressHUD.h"
#import "AppDelegate.h"
#import "JSONKit.h"
#import "HTTPFetcher.h"
#import "XMLFetcher.h"
#import "StringHelper.h"
#import "MyCoreLocation.h"
#import "DefaultCityCell.h"
#import "City.h"

#define TABLE_START_Y_POS 78.0
#define TABLE_END_Y_POS 88.0

@interface TACitiesListVC ()

@end

@implementation TACitiesListVC

@synthesize cities, citiesTable, delegate, searchField, locateBtn;
@synthesize selectedCity, locationManager, currentLocation, setBtn;


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
	
	// Get user location
	MyCoreLocation *location = [[MyCoreLocation alloc] init];
	self.locationManager = location;
	
	// We are the delegate for the MyCoreLocation object
	[self.locationManager setCaller:self];
	
    
	/*
		Check if a selectedCity has already
		been selected set. If so -
		display this city in the search field
	*/
    if (self.selectedCity)
        [self.searchField setText:[self.selectedCity title]];
}

#pragma mark - Private Methods
- (AppDelegate *)appDelegate {
	
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)viewDidUnload {
	
	self.setBtn = nil;
		
    self.citiesTable = nil;
	
	self.cities = nil; 
	self.citiesTable = nil; 
	
	self.searchField = nil;
	
	self.locationManager = nil;
	self.currentLocation = nil;
	
	locateBtn = nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)viewWillAppear:(BOOL)animated {

	[super viewWillAppear:animated];
    
    [self fetchCities];
	
	// Remove default nav bar
	[self initNavBar];
}


#pragma mark - UITextField delegations
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    // If the current text field is username - put the focus on the password field
	if (textField == self.searchField)
		[self.searchField resignFirstResponder];
	
    if (!loading) {
		
		[self showLoading];
		
		[self initCitySearchAPI];
	}
    
    return YES;
}


- (void)textFieldDidBeginEditing:(UITextField *)textField {

	// Disable the SET button now that
	// user has entered a 'search' mode
	// Free text shouldn't be SET as the
	// user's city
	self.setBtn.hidden = YES;
}


#pragma mark - Private Methods
- (void)updateLocationDidFinish:(CLLocation *)loc {
    
    self.currentLocation = loc;
	
	[self.locationManager stopUpdating];
	
	NSLog(@"FOUND LOCATION:%f\%f", self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude);
	
	[self retrieveYahooCity];
}


#pragma mark Search Bar Delegate methods
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	
	if (!loading) {
		
		[self showLoading];
		
		[self initCitySearchAPI];
	}
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsIsnTableView:(UITableView *)tableView {
	
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	NSInteger numberOfRows = [self.cities count];
    
    return numberOfRows;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	DefaultCityCell *cell = (DefaultCityCell *)[tableView dequeueReusableCellWithIdentifier:[DefaultCityCell reuseIdentifier]];
	
	if (cell == nil) {
        
		// Load the top-level objects from the custom cell XIB.
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"DefaultCityCell" owner:self options:nil];
        
        // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
        cell = [topLevelObjects objectAtIndex:0];
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
	
	
	if (row == ([self.cities count] - 1)) {
		
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


- (void)configureCell:(DefaultCityCell *)cell atIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView {
    
    // Make sure the cell images don't scale
    [cell.backgroundView setContentMode:UIViewContentModeTop];
    [cell.selectedBackgroundView setContentMode:UIViewContentModeTop];
	
	// Retrieve City from cities array
	City *city = [self.cities objectAtIndex:[indexPath row]];
	NSString *cellTitle = [city title];
	
	// Set the text of the cell
	cell.cityLabel.text = cellTitle;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	
	return 9.0;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	
	UIImage *roundedHeader = [UIImage imageNamed:@"white-table-rounded-header.png"];
	
	UIImageView *headerView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.frame.size.width, 9.0)];
	[headerView setImage:roundedHeader];
	
	return headerView;
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	
	return 4.0;
}


- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	
	UIImage *roundedHeader = [UIImage imageNamed:@"white-table-footer-shadow.png"];
	
	UIImageView *headerView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.frame.size.width, 4.0)];
	[headerView setImage:roundedHeader];
	
	return headerView;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	// Need to store the selected City object
	// When the user clicks the 'Set' button this value will be passed
	// back to the delegate
	self.selectedCity = [self.cities objectAtIndex:[indexPath row]];
	
	// Display the selected city in the search field
	self.searchField.text = [self.selectedCity title];
	
	// Enable the user to SET this as their
	// city now that they've selected one
	self.setBtn.hidden = NO;
}


- (void)initCitySearchAPI {
	
	NSString *postString = [NSString stringWithFormat:@"q=%@", self.searchField.text];
	NSData *postData = [NSData dataWithBytes:[postString UTF8String] length:[postString length]];
	
	// Create the URL that will be used to authenticate this user
	NSString *methodName = @"citysearch";
	NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];
	
	// Initialiase the URL Request
	NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:postData];
	
	citiesFetcher = [[HTTPFetcher alloc] initWithURLRequest:request
													 receiver:self action:@selector(receivedCitySearchResponse:)];
	[citiesFetcher start];
}


// Example fetcher response handling
- (void)receivedCitySearchResponse:(HTTPFetcher *)aFetcher {
    
    HTTPFetcher *theJSONFetcher = (HTTPFetcher *)aFetcher;
    
    NSAssert(aFetcher == citiesFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	// We are not loading
	loading = NO;
	
	//NSLog(@"PRINTING CITY SEARCH DATA:%@",[[NSString alloc] initWithData:theXMLFetcher.data encoding:NSASCIIStringEncoding]);
	
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
		
		// Show the city results
		[self showTable];
	}
    
    citiesFetcher = nil;
}


- (IBAction)goBack:(id)sender {

	[self.navigationController popViewControllerAnimated:YES];
}


- (void)initNavBar {

	self.navigationController.navigationBarHidden = YES;
}


/*
	This passes the selectedCity value back
	to the delegate class. 
 
	The user is also taken back one step 
	in the navigation controller stack.
*/
- (IBAction)setButtonTapped:(id)sender {

	// Pass the selected city to our delegate
	[self.delegate locationSelected:self.selectedCity];
	
	// Go back to the previous screen
	[self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)locateButtonTapped:(id)sender {
	
	if ([self.searchField isFirstResponder]) [self.searchField resignFirstResponder];
	
	self.setBtn.hidden = YES;

	if (!self.locationManager.updating) {
		
		// Deselect nearby button
		[self.locateBtn setSelected:YES];
		[self.locateBtn setHighlighted:NO];
		
		[self showLoading];
		
		[self.locationManager startUpdating];
	}
}


- (void)retrieveYahooCity {
	
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
	
	// XML Fetcher
	cityFetcher = [[XMLFetcher alloc] initWithURLRequest:request xPathQuery:@"//ResultSet" receiver:self action:@selector(receivedYahooResponse:)];
	[cityFetcher start];
}


// Example fetcher response handling
- (void)receivedYahooResponse:(HTTPFetcher *)aFetcher {
    
    XMLFetcher *theXMLFetcher = (XMLFetcher *)aFetcher;
    NSAssert(theXMLFetcher == cityFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	BOOL requestSuccess = NO;
	BOOL errorDected = NO;
	
	//NSLog(@"PRINTING YAHOO DATA:%@",[[NSString alloc] initWithData:theXMLFetcher.data encoding:NSASCIIStringEncoding]);
	
	
	NSString *yahooCity;
	
	
	// IF STATUS CODE WAS OKAY (200)
	if ([theXMLFetcher statusCode] == 200) {
		
		// XML Data was returned from the API successfully
		if (([theXMLFetcher.data length] > 0) && ([theXMLFetcher.results count] > 0)) {
			
			requestSuccess = YES;
			
			XPathResultNode *versionsNode = [theXMLFetcher.results lastObject];
			
			// loop through the children of the <registration> node
			for (XPathResultNode *child in versionsNode.childNodes) {
				
				if ([[child name] isEqualToString:@"ErrorMessage"]) {
					
					errorDected = ([[child contentString] isEqualToString:@"No error"] ? NO : YES);
				}
				
				else if ([[child name] isEqualToString:@"Result"]) {
					
					for (XPathResultNode *childNode in child.childNodes) {
						
						if ([[childNode name] isEqualToString:@"city"] && [[childNode contentString] length] > 0) {
							
							NSLog(@"SELECTED LOCATION:%@", [childNode contentString]);
							
							yahooCity = [childNode contentString];
						}
					}
				}
			}
		}
	}
	
	if (requestSuccess && !errorDected) {
		
		self.selectedCity = [NSDictionary dictionaryWithObjectsAndKeys:yahooCity, @"city", nil];
		
		[self.searchField setText:yahooCity];
		
		self.setBtn.hidden = NO;
	}
	
	else {
		
		UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Sorry!" message:@"We were unable to locate your current city. Please search for one." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
		[av show];
	}
	
	[self hideLoading];
	
	// Deselect nearby button
	[self.locateBtn setSelected:NO];
	[self.locateBtn setHighlighted:NO];
    
    cityFetcher = nil;
	
}


- (void)showLoading {
	
	[SVProgressHUD showInView:self.view status:nil networkIndicator:YES posY:-1 maskType:SVProgressHUDMaskTypeClear];
}


- (void)hideLoading {
	
	[SVProgressHUD dismissWithSuccess:@"Loaded!"];
}


- (void)hideTable {
	
	CGFloat animationDuration = 0.25;
	CGFloat alpha = 0.0;
	
	// Disable any user interaction
	self.citiesTable.userInteractionEnabled = NO;
	
	// Set the new frame for the table
	CGRect newFrame = self.citiesTable.frame;
	newFrame.origin.y = TABLE_START_Y_POS;

	[UIView animateWithDuration:animationDuration animations:^{
		
		self.citiesTable.frame = newFrame;
		self.citiesTable.alpha = alpha;
		
	} completion:^(BOOL finished) {
		
		self.citiesTable.userInteractionEnabled = YES;
	}];
}


- (void)showTable {
	
	CGFloat animationDuration = 0.25;
	CGFloat alpha = 1.0;
	
	// Set the new frame for the table
	CGRect newFrame = self.citiesTable.frame;
	newFrame.origin.y = TABLE_END_Y_POS;
	
	[UIView animateWithDuration:animationDuration animations:^{
		
		self.citiesTable.frame = newFrame;
		self.citiesTable.alpha = alpha;
		
	} completion:^(BOOL finished) {
		
		self.citiesTable.userInteractionEnabled = YES;
	}];
}


- (void)fetchCities {
    
    if (!self.managedObjectContext) self.managedObjectContext = [self appDelegate].managedObjectContext;
	
	// Create fetch request
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:[NSEntityDescription entityForName:@"City" inManagedObjectContext:self.managedObjectContext]];
	[fetchRequest setPredicate:nil];
	[fetchRequest setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:NO]]];
	
	// Execute the fetch request
	NSError *error = nil;
	self.cities = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    NSLog(@"FETCHED CITIES:%@", self.cities);
    
    [self.citiesTable reloadData];
}


- (void)updateCitiesArray:(NSArray *)newCities {
    
    for (NSDictionary *cityDict in newCities) {
        
        [City cityWithTitle:[cityDict objectForKey:@"city"] inManagedObjectContext:self.managedObjectContext];
    }
    
    [self fetchCities];
}


@end
