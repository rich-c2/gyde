//
//  TAGuidesListVC.m
//  Tourism App
//
//  Created by Richard Lee on 22/08/12.
//  Copyright (c) 2012 C2 Media Pty Ltd. All rights reserved.
//

#import "TAGuidesListVC.h"
#import "AppDelegate.h"
#import "StringHelper.h"
#import "JSONKit.h"
#import "HTTPFetcher.h"
#import "SVProgressHUD.h"
#import "TAGuideDetailsVC.h"
#import "TACreateGuideVC.h"
#import "Guide.h"
#import "City.h"
#import "Tag.h"
#import "MyGuidesTableCell.h"

@interface TAGuidesListVC ()

@end

@implementation TAGuidesListVC

@synthesize guidesMode, guidesTable, guides, username;
@synthesize selectedTag, selectedCity, selectedTagID, selectedPhotoID;

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
    
	// Remove the default nav bar
	[self initNavBar];
	
	//self.guides = [NSMutableArray array];
}

- (void)viewDidUnload {
	
	self.selectedTagID = nil;
	self.username = nil;
	self.guides = nil;
	self.selectedTag = nil; 
	self.selectedCity = nil;
	self.selectedPhotoID = nil;
    guidesTable = nil;
	
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)viewWillAppear:(BOOL)animated {
	
	[super viewWillAppear:animated];
	
	if (!loading && !guidesLoaded) { 
		
		[self showLoading];
		
		switch (self.guidesMode) {
				
			case GuidesModeFollowing:
				[self initFollowedGuidesAPI];
				break;
				
			case GuidesModeViewing:
				[self initMyGuidesAPI];
				break;
				
			case GuidesModeMyGuides:
				[self initMyGuidesAPI];
				break;
				
			case GuidesModeAddTo:
				[self initMyGuidesAPI];
				break;
				
			case GuidesModeSearchResults:
				[self initFindGuidesAPI];
				break;
				
			default:
				[self.guidesTable reloadData];
				[self hideLoading];
				break;
		}
	}
}


#pragma mark - Private Methods
- (AppDelegate *)appDelegate {
	
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	NSInteger numOfRows = [self.guides count];
	
	// If we're adding to a guide, then add on one 
	// more row to allow user to "Add to new" guide
	if (self.guidesMode == GuidesModeAddTo) numOfRows++;
	
    return numOfRows;
}


- (void)configureCell:(MyGuidesTableCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	
	NSString *guideTitle;
	NSString *subtitle;
    NSString *thumbURL;
	
	if (self.guidesMode == GuidesModeAddTo) {
		
		// deal with the "extra row" - which is going 
		// to be the "add to new" guide row
		if ([indexPath row] == [self.guides count]) {
		
			guideTitle = @"Add to new guide";
			subtitle = @"Create a new guide with this image";
            thumbURL = @"";
		}
		
		else {
			
			Guide *guide = [self.guides objectAtIndex:[indexPath row]];
			
			guideTitle = [guide title];
			subtitle = [NSString stringWithFormat:@"By %@ / 0 photos / 0 days", [[guide author] username]];
            thumbURL = [guide thumbURL];
		}
	}
	
	else {
		
		// Retrieve the Dictionary at the given index that's in self.guides
		NSDictionary *guide = [self.guides objectAtIndex:[indexPath row]];
		NSDictionary *authorDict = [guide objectForKey:@"author"];
		
		guideTitle = [guide objectForKey:@"title"];
		subtitle = [NSString stringWithFormat:@"By %@ / %@ photos / 0 days", [authorDict objectForKey:@"username"], [guide objectForKey:@"imagecount"]];
        thumbURL = [NSString stringWithFormat:@"%@%@", FRONT_END_ADDRESS,[guide objectForKey:@"thumb"]];
	}
    
    // Make sure the cell images don't scale
    [cell.backgroundView setContentMode:UIViewContentModeTop];
    [cell.selectedBackgroundView setContentMode:UIViewContentModeTop];
	
    if ([thumbURL length] > 0)[cell initImageDownload:thumbURL];
	[cell.titleLabel setText:guideTitle];
	[cell.authorLabel setText:subtitle];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    MyGuidesTableCell *cell = (MyGuidesTableCell *)[tableView dequeueReusableCellWithIdentifier:[MyGuidesTableCell reuseIdentifier]];
	
	if (cell == nil) {
        
        // Load the top-level objects from the custom cell XIB.
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"MyGuidesTableCell" owner:self options:nil];
        
        // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
        cell = [topLevelObjects objectAtIndex:0];
    }
    
    // Retrieve Track object and set it's name to the cell
	[self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {

	return 9.0;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

	UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.frame.size.width, 9.0)];
	[headerView setBackgroundColor:[UIColor clearColor]];
	
	return headerView;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	
	if (self.guidesMode == GuidesModeAddTo) {
		
		// deal with the "extra row" - which is going 
		// to be the "add to new" guide row
		if ([indexPath row] == [self.guides count]) {
	
			TACreateGuideVC *createGuideVC = [[TACreateGuideVC alloc] initWithNibName:@"TACreateGuideVC" bundle:nil];
			[createGuideVC setImageCode:self.selectedPhotoID];
			[createGuideVC setGuideTagID:self.selectedTagID];
			[createGuideVC setGuideCity:self.selectedCity];
			
            // If there is a delegate present then hand it onto the create guide screen
            if (self.delegate) [createGuideVC setDelegate:self.delegate];
            
			[self.navigationController pushViewController:createGuideVC animated:YES];
		}
		
		
		
		else {
            
            Guide *guide = [self.guides objectAtIndex:[indexPath row]];
            
            // If there is a delegate present then pass
            // the guide ID back to it and pop this view controller
            if (self.delegate) {
            
                [self.delegate guideWasSelected:[guide guideID]];
                
                [self.navigationController popViewControllerAnimated:YES];
            }
			
            // Add the photo to the Guide that was
            // selected from the table list
			else [self initAddToGuideAPI:guide];
		}
	}
			
	else {
	
		// Retrieve the Dictionary at the given index that's in self.users
		NSDictionary *guide = [self.guides objectAtIndex:[indexPath row]];
		
		TAGuideDetailsVC *guideDetailsVC = [[TAGuideDetailsVC alloc] initWithNibName:@"TAGuideDetailsVC" bundle:nil];
		[guideDetailsVC setGuideID:[guide objectForKey:@"guideID"]];
		
		// Is this a guide that the logged-in user created or someone else's?
		if (self.guidesMode == GuidesModeMyGuides) [guideDetailsVC setGuideMode:GuideModeCreated];
		
		else if (self.guidesMode == GuidesModeViewing) [guideDetailsVC setGuideMode:GuideModeViewing];
		
		else if (self.guidesMode == GuidesModeSearchResults) [guideDetailsVC setGuideMode:GuideModeViewing];
		
		[self.navigationController pushViewController:guideDetailsVC animated:YES];
	}
}



#pragma MY METHODS

- (IBAction)goBack:(id)sender {

	[self.navigationController popViewControllerAnimated:YES];
}

- (void)initNavBar {

    self.title = @"GUIDES";
	self.navigationController.navigationBarHidden = NO;
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
	
	//NSLog(@"PRINTING MY GUIDES:%@",[[NSString alloc] initWithData:theJSONFetcher.data encoding:NSASCIIStringEncoding]);
	
	loading = NO;
	
	NSInteger statusCode = [theJSONFetcher statusCode];
    
    if ([theJSONFetcher.data length] > 0 && statusCode == 200) {
		
		guidesLoaded = YES;
		
		// Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		
		// Create a dictionary from the JSON string
		NSDictionary *results = [jsonString objectFromJSONString];
		
		
		// For 'Add To' mode we need to
		// serialize the Guides data so that
		// we can filter out the Guides that don't
		// match the city/tag combo we're looking for
		if (self.guidesMode == GuidesModeAddTo) {
			
			NSArray *guidesArray = [results objectForKey:@"guides"];

			NSArray *tempGuides = [[self appDelegate] serializeGuideData:guidesArray];
			
			self.guides = (NSMutableArray *)[tempGuides filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"city.title = %@ AND tag.tagID = %@", self.selectedCity, self.selectedTagID]];
		}
		
		else {
			
			// Build an array from the dictionary for easy access to each entry
			self.guides = [results objectForKey:@"guides"];
		}
	}
	
	[self finishedMyGuidesRequest];
	
	guidesFetcher = nil;
}


- (void)finishedMyGuidesRequest {
	
	[self.guidesTable reloadData];
	
	[self hideLoading];
}


- (void)initFollowedGuidesAPI {
	
	NSString *jsonString = [NSString stringWithFormat:@"username=%@&token=%@", [self appDelegate].loggedInUsername, [[self appDelegate] sessionToken]];
	NSData *postData = [NSData dataWithBytes:[jsonString UTF8String] length:[jsonString length]];
	
	// Create the URL that will be used to authenticate this user
	NSString *methodName = @"GetFollowedGuides";
	NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];
	
	// Initialiase the URL Request
	NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:postData];
	
	// HTTPFetcher
	guidesFetcher = [[HTTPFetcher alloc] initWithURLRequest:request
												   receiver:self action:@selector(receivedFollowedGuideResponse:)];
	[guidesFetcher start];
}


// Example fetcher response handling
- (void)receivedFollowedGuideResponse:(HTTPFetcher *)aFetcher {
    
    HTTPFetcher *theJSONFetcher = (HTTPFetcher *)aFetcher;
    
    NSAssert(aFetcher == guidesFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	//NSLog(@"PRINTING FOLLOWED GUIDES:%@",[[NSString alloc] initWithData:theJSONFetcher.data encoding:NSASCIIStringEncoding]);
    
	loading = NO;
	
    NSInteger statusCode = [theJSONFetcher statusCode];
    
    if ([theJSONFetcher.data length] > 0 && statusCode == 200) {
		
		guidesLoaded = YES;
        
        // Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		
		// Create a dictionary from the JSON string
		NSDictionary *results = [jsonString objectFromJSONString];
		
		// Build an array from the dictionary for easy access to each entry
		self.guides = [results objectForKey:@"guides"];
    }
	
	// Reload the table
	[self.guidesTable reloadData];
	
	[self hideLoading];
    
    guidesFetcher = nil;
}


- (void)showLoading {
	
	[SVProgressHUD showInView:self.view status:nil networkIndicator:YES posY:-1 maskType:SVProgressHUDMaskTypeClear];
}


- (void)hideLoading {
	
	[SVProgressHUD dismissWithSuccess:@"Loaded!"];
}


- (void)initAddToGuideAPI:(Guide *)guide {

	NSString *postString = [NSString stringWithFormat:@"username=%@&token=%@&imageID=%@&guideID=%@", [self appDelegate].loggedInUsername, [[self appDelegate] sessionToken], self.selectedPhotoID, guide.guideID];
	
	NSLog(@"ADD TO GUIDE string:%@", postString);
	
	NSData *postData = [NSData dataWithBytes:[postString UTF8String] length:[postString length]];
	
	// Create the URL that will be used to authenticate this user
	NSString *methodName = @"addtoguide";	
	NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];
	
	// Initialiase the URL Request
	NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:postData];
	
	// HTTPFetcher
	guidesFetcher = [[HTTPFetcher alloc] initWithURLRequest:request
											 receiver:self
											   action:@selector(receivedAddToGuideResponse:)];
	[guidesFetcher start];
}


// Example fetcher response handling
- (void)receivedAddToGuideResponse:(HTTPFetcher *)aFetcher {
    
    HTTPFetcher *theJSONFetcher = (HTTPFetcher *)aFetcher;
	
	//NSLog(@"ADD TO GUIDE DETAILS:%@",[[NSString alloc] initWithData:theJSONFetcher.data encoding:NSASCIIStringEncoding]);
    
	NSAssert(aFetcher == guidesFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
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
			message = [NSString stringWithFormat:@"The photo was successfully added"];
		}
	}
	
	
	if (!success) {
	
		title = @"Sorry!";
		message = @"There was an error adding that photo";
	}
	
	
	UIAlertView *av = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
	[av show];
	
	guidesFetcher = nil;
}


- (void)initFindGuidesAPI {
	
	NSString *jsonString = [NSString stringWithFormat:@"username=%@&tag=%i&city=%@&pg=%i&sz=%@&private=0&token=%@", [self appDelegate].loggedInUsername, [self.selectedTagID intValue], self.selectedCity, 0, @"20", [[self appDelegate] sessionToken]];
	
	// Convert string to data for transmission
	NSData *jsonData = [NSData dataWithBytes:[jsonString UTF8String] length:[jsonString length]];
	
	// Create the URL that will be used to authenticate this user
	NSString *methodName = @"FindGuides";
	NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];
	
	// Create URL request with URL and the JSON data
	NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:jsonData];
	
	// HTTPFetcher
	guidesFetcher = [[HTTPFetcher alloc] initWithURLRequest:request
												   receiver:self
													 action:@selector(receivedFindGuidesResponse:)];
	[guidesFetcher start];
	
	[self hideLoading];
}	


// Example fetcher response handling
- (void)receivedFindGuidesResponse:(HTTPFetcher *)aFetcher {
    
    HTTPFetcher *theJSONFetcher = (HTTPFetcher *)aFetcher;
    
    NSAssert(aFetcher == guidesFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	//NSLog(@"PRINTING FIND GUIDES:%@",[[NSString alloc] initWithData:theJSONFetcher.data encoding:NSASCIIStringEncoding]);
	
	NSInteger statusCode = [theJSONFetcher statusCode];
    
    if ([theJSONFetcher.data length] > 0 && statusCode == 200) {
		
		guidesLoaded = YES;
        
        // Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		
		// Create a dictionary from the JSON string
		NSDictionary *results = [jsonString objectFromJSONString];
		
		// Build an array from the dictionary for easy access to each entry
		self.guides = [results objectForKey:@"guides"];
		
    }
	
	// Reload the table
	[self.guidesTable reloadData];
	
	[self hideLoading];
    
    guidesFetcher = nil;
}


@end
