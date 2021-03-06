//
//  TAPlacesVC.m
//  Tourism App
//
//  Created by Richard Lee on 3/09/12.
//  Copyright (c) 2012 C2 Media Pty Ltd. All rights reserved.
//

#import "TAPlacesVC.h"
#import "StringHelper.h"
#import "TAMapItVC.h"
#import "TASimpleTableCell.h"
#import "MyMapAnnotation.h"

#define TABLE_HEADER_HEIGHT 9.0
#define TABLE_FOOTER_HEIGHT 9.0

@interface TAPlacesVC ()

@end

@implementation TAPlacesVC

@synthesize placesTable, places, latitude, longitude, delegate;


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
    
    self.navigationItem.title = @"LOCATIONS";
    
    UIButton *mapItBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [mapItBtn setImage:[UIImage imageNamed:@"nav-bar-map-it-button.png"] forState:UIControlStateNormal];
    [mapItBtn setImage:[UIImage imageNamed:@"nav-bar-map-it-button-on.png"] forState:UIControlStateHighlighted];
    [mapItBtn setFrame:CGRectMake(267, 0, 54, 27)];
    [mapItBtn addTarget:self action:@selector(mapItButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *mapItButtonItem = [[UIBarButtonItem alloc] initWithCustomView:mapItBtn];
    
    self.navigationItem.rightBarButtonItem = mapItButtonItem;
    
    
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


- (void)mapItButtonTapped:(id)sender {
	
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
