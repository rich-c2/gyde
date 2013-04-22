//
//  TAPlacesVC.m
//  Tourism App
//
//  Created by Richard Lee on 3/09/12.
//  Copyright (c) 2012 C2 Media Pty Ltd. All rights reserved.
//

#import "TAPlacesVC.h"
#import "StringHelper.h"
#import "HTTPFetcher.h"
#import "JSONKit.h"
#import "TAMapItVC.h"
#import "SVProgressHUD.h"
#import "TASimpleTableCell.h"
#import "MyMapAnnotation.h"

#define TABLE_HEADER_HEIGHT 9.0
#define TABLE_FOOTER_HEIGHT 9.0

NSString* const CLIENT_ID = @"DKN1SLXTCU0PUYUXXLNQDO1DYBNX2WZ3GJCXU0FMSZSYMQSK";
NSString* const CLIENT_SECRET = @"GIJHYETIFSBFBMWGRKXJ0TPYZJ0UGRP2B5WRGWD5E5TKFZKV";

@interface TAPlacesVC ()

@end

@implementation TAPlacesVC

@synthesize placesTable, mapItBtn, places, latitude, longitude, delegate;


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
    
    // Hide the note view
    [self.tipView hideTipViewWithAnimation:NO completionBlock:^(BOOL finished){}];
    
	self.places = [NSMutableArray array];
    
    [self initMap];
}

- (void)viewDidUnload {
	
	self.places = nil;
	self.latitude = nil; 
	self.longitude = nil;
	
    placesTable = nil;
    mapItBtn = nil;
    [self setPlacesMap:nil];
    [self setLoadingView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)viewWillAppear:(BOOL)animated {
    
    
    // Show the note view
    [self.tipView showTipViewWithAnimation:YES completionBlock:^(BOOL finished){
        
        [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(hideTipView) userInfo:nil repeats:NO];
    }];
	
	
	if (!loading && !venuesLoaded) {
		
        [self initGetPlacesApi:^(BOOL success){
            
            if (success) {
        
                [self.placesTable reloadData];
                [self initMapLocations];
            }
            
            else {
            
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Locations error"
                                                             message:@"There was an error finding nearby locations. Please check your network connection."
                                                            delegate:self
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil, nil];
                [av show];
            }
        }];
	}
		
    [super viewWillAppear:animated];
}

- (void)hideTipView {
    
    // Hide the note view
    [self.tipView hideTipViewWithAnimation:YES completionBlock:^(BOOL finished){}];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
    return [self.places count];
}


- (void)configureCell:(TASimpleTableCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	
    // Retrieve the Dictionary at the given index that's in self.followers
	NSDictionary *place = [self.places objectAtIndex:[indexPath row]];
	NSString *placeName = [place objectForKey:@"Name"];
    
    // Make sure the cell images don't scale
    [cell.backgroundView setContentMode:UIViewContentModeTop];
    [cell.selectedBackgroundView setContentMode:UIViewContentModeTop];
	
	[cell.titleLabel setText:placeName];
}


- (UITableViewCell *)tableView:(UITableView *)tableView 
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    TASimpleTableCell *cell = (TASimpleTableCell *)[tableView dequeueReusableCellWithIdentifier:[TASimpleTableCell reuseIdentifier]];
    
    if (cell == nil) {
        
        // Load the top-level objects from the custom cell XIB.
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"TASimpleTableCell" owner:self options:nil];
        
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
	
	// Retrieve the corresponding place dictionary
	// then extract the relevant data we need to pass to the delegate
	// and place it within a dictionary of it's own
	// Then 'pop' the user back one VC
	NSDictionary *place = [self.places objectAtIndex:[indexPath row]];
	
	NSMutableDictionary *placeData = [NSMutableDictionary dictionary];
	[placeData setObject:[place objectForKey:@"Location"] forKey:@"location"];
	[placeData setObject:[place objectForKey:@"Name"] forKey:@"name"];
	[placeData setObject:@"0" forKey:@"verified"];
	
	[self.delegate placeSelected:placeData];
	
	[self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)mapItButtonTapped:(id)sender {
	
	CLLocation *location = [[CLLocation alloc] initWithLatitude:[self.latitude doubleValue] longitude:[self.longitude doubleValue]];

	TAMapItVC *mapItVC = [[TAMapItVC alloc] initWithNibName:@"TAMapItVC" bundle:nil];
	[mapItVC setCurrentLocation:location];
	[mapItVC setDelegate:self.delegate];
	
	[self.navigationController pushViewController:mapItVC animated:YES];
}


- (void)initGetPlacesApi:(void(^)(BOOL success))completionBlock {
    
    loading = YES;
    venuesLoaded = NO;
    
    NSString *latString = [NSString stringWithFormat:@"%f", [self.latitude doubleValue]];
    NSString *lngString = [NSString stringWithFormat:@"%f", [self.longitude doubleValue]];
    NSDictionary *params = @{ @"lat" : latString, @"lng" : lngString };
    
    [[GlooRequestManager sharedManager] post:@"getplaces"
                                      params:params
                               dataLoadBlock:^(NSDictionary *json) {}
                             completionBlock:^(NSDictionary *json) {
                                 
                                 loading = NO;
                                 
                                 if ([json[@"result"] isEqualToString:@"ok"]) {
                                 
                                     venuesLoaded = YES;
                                     self.places = json[@"places"];
                                     completionBlock(YES);
                                 }
                                 
                                 else {
                                 
                                     completionBlock(NO);
                                 }
                             }
                                  viewForHUD:self.view];
}


- (void)searchVenues {
	
	//[self.loadingSpinner startAnimating];
	
	NSString *urlString = [NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/search?ll=%f,%f&client_id=%@&client_secret=%@&v=20120703", [self.latitude doubleValue], [self.longitude doubleValue], CLIENT_ID, CLIENT_SECRET];
	
	NSURL *url = [urlString convertToURL];
    
    // Initialiase the URL Request
    NSMutableURLRequest *request =(NSMutableURLRequest*)[NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    // Add the Authorization header with the credentials made above. 
	[request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"GET"];
	
	// HTTPFetcher
    venuesFetcher = [[HTTPFetcher alloc] initWithURLRequest:request
												   receiver:self
													 action:@selector(receivedVenuesResponse:)];
    [venuesFetcher start];
}


// Example fetcher response handling
- (void)receivedVenuesResponse:(HTTPFetcher *)aFetcher {
    
    HTTPFetcher *theJSONFetcher = (HTTPFetcher *)aFetcher;
    
    NSAssert(aFetcher == venuesFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	//NSLog(@"PRINTING VENUES DATA:%@",[[NSString alloc] initWithData:theJSONFetcher.data encoding:NSASCIIStringEncoding]);
	
	//[self.loadingSpinner stopAnimating];
	
	loading = NO;
	
	NSInteger statusCode = [theJSONFetcher statusCode];
    
    if ([theJSONFetcher.data length] > 0 && statusCode == 200) {
		
		venuesLoaded = YES;
        
        // Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		
		// Create a dictionary from the JSON string
		NSDictionary *results = [jsonString objectFromJSONString];
		
		// Build an array from the dictionary for easy access to each entry
		NSDictionary *responseDict = [results objectForKey:@"response"];
		
		NSMutableArray *newVenues = (NSMutableArray *)[responseDict objectForKey:@"venues"];
		
		self.places = newVenues;
		
		NSLog(@"venues:%@", self.places);
    }
	
	[self hideLoading];
	
	// Reload table
	[self.placesTable reloadData];
    
    [self initMapLocations];
    
    venuesFetcher = nil;
}


- (IBAction)goBack:(id)sender {

    [self.navigationController popViewControllerAnimated:YES];
}


- (void)showLoading {
	
	//[SVProgressHUD showInView:self.view status:nil networkIndicator:YES posY:-1 maskType:SVProgressHUDMaskTypeClear];
    
    [self.loadingView setHidden:NO];
}


- (void)hideLoading {
	
	//[SVProgressHUD dismissWithSuccess:@"Loaded!"];
    
    [self.loadingView setHidden:YES];
}


- (void)initMap {

    /*Region and Zoom*/
	MKCoordinateRegion region;
	MKCoordinateSpan span;
	span.latitudeDelta = 0.009;
	span.longitudeDelta = 0.009;
    
    CLLocationCoordinate2D coordLocation;
    coordLocation.latitude = [self.latitude doubleValue];
    coordLocation.longitude = [self.longitude doubleValue];
    
    region.span = span;
    region.center = coordLocation;
        
    [self.placesMap setRegion:region animated:TRUE];
    [self.placesMap regionThatFits:region];
}


- (void)initMapLocations {
    
	for (int i = 0; i < [self.places count]; i++) {
		
        NSDictionary *place = [self.places objectAtIndex:i];
		
        // Location data
        NSDictionary *locationData = [place objectForKey:@"Location"];
        
		CLLocationCoordinate2D coordLocation;
		coordLocation.latitude = [[locationData objectForKey:@"lat"] doubleValue];
		coordLocation.longitude = [[locationData objectForKey:@"lng"] doubleValue];
        
		NSString *title = [place objectForKey:@"Name"];
		if ([title length] == 0) title = @"[untitled]";
		
		MyMapAnnotation *mapAnnotation = [[MyMapAnnotation alloc] initWithCoordinate:coordLocation title:title];
		[self.placesMap addAnnotation:mapAnnotation];
	}
}


@end
