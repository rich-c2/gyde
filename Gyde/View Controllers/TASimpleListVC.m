//
//  TASimpleListVC.m
//  Tourism App
//
//  Created by Richard Lee on 27/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TASimpleListVC.h"
#import "HTTPFetcher.h"
#import "SVProgressHUD.h"
#import "JSONKit.h"
#import "TAProfileVC.h"
#import "AppDelegate.h"
#import "Tag.h"
#import "TASimpleTableCell.h"

#define TABLE_HEADER_HEIGHT 9.0
#define TABLE_FOOTER_HEIGHT 4.0

@interface TASimpleListVC ()

@end

@implementation TASimpleListVC

@synthesize listItems, imageCode, listMode, listTable, managedObjectContext, delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


#pragma mark - Private Methods
- (AppDelegate *)appDelegate {
	
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload {
	
	self.imageCode = nil;
	self.listItems = nil;
	self.managedObjectContext = nil;
	
	self.listTable = nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)viewWillAppear:(BOOL)animated {
	
    [super viewWillAppear:animated];
	
	if (!usersLoaded && !loading) {
		
		loading = YES;
		
		// Show loading animation
		[self showLoading];
		
		if (self.listMode == ListModeLovedBy) 
			[self initLovedByAPI];
		else if (self.listMode == ListModeTags) 
			[self fetchTags];
	}
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
    return [self.listItems count];
}


- (void)configureCell:(TASimpleTableCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	
    
    // Make sure the cell images don't scale
    [cell.backgroundView setContentMode:UIViewContentModeTop];
    [cell.selectedBackgroundView setContentMode:UIViewContentModeTop];
    
	NSString *cellText;
	    
	if (self.listMode == ListModeLovedBy) {
		
		// Retrieve the Dictionary at the given index that's in self.users
		NSDictionary *item = [self.listItems objectAtIndex:[indexPath row]];
		
		cellText = [item objectForKey:@"username"];
	}
	
	// Tag mode - retrieve the Tag object from the array
	else if (self.listMode == ListModeTags) {
		
		Tag *tag = [self.listItems objectAtIndex:[indexPath row]];
		
		cellText = tag.title;
	}
		
	cell.titleLabel.text = cellText;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
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


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	// If we're in 'Tag mode'
	if (self.listMode == ListModeTags) {
	
		Tag *tag = [self.listItems objectAtIndex:[indexPath row]];
	
		// Pass selected tag back to the delegate
		[self.delegate tagSelected:tag];
		
		// Go back to the previous screen
		[self.navigationController popViewControllerAnimated:YES];
	}
	
	else if (self.listMode == ListModeLovedBy) {
	
		// Retrieve the Dictionary at the given index that's in self.users
		NSDictionary *user = [self.listItems objectAtIndex:[indexPath row]];
		
		TAProfileVC *profileVC = [[TAProfileVC alloc] initWithNibName:@"TAProfileVC" bundle:nil];
		[profileVC setUsername:[user objectForKey:@"username"]];
		
		[self.navigationController pushViewController:profileVC animated:YES];			
	}
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



#pragma MY-METHODS

- (IBAction)goBack:(id)sender {

    [self.navigationController popViewControllerAnimated:YES];
}


- (void)fetchTags {
	
	// Create fetch request
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:[NSEntityDescription entityForName:@"Tag" inManagedObjectContext:self.managedObjectContext]];
	[fetchRequest setPredicate:nil];
	[fetchRequest setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:NO]]];
	
	// Execute the fetch request
	NSError *error = nil;
	self.listItems = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	
	[self hideLoading];
}


- (void)initLovedByAPI {
	
	NSString *postString = [NSString stringWithFormat:@"code=%@", self.imageCode];
	NSData *postData = [NSData dataWithBytes:[postString UTF8String] length:[postString length]];
	
	// Create the URL that will be used to authenticate this user
	NSString *methodName = @"LovedBy";
	NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];
	
	// Initialiase the URL Request
	NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:postData];
	
	// HTTPFetcher
	fetcher = [[HTTPFetcher alloc] initWithURLRequest:request
												  receiver:self
													action:@selector(receivedLovedByResponse:)];
	[fetcher start];
}


// Example fetcher response handling
- (void)receivedLovedByResponse:(HTTPFetcher *)aFetcher {
    
    HTTPFetcher *theJSONFetcher = (HTTPFetcher *)aFetcher;
    
    NSAssert(aFetcher == fetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	// We are not loading
	loading = NO;
	
	NSInteger statusCode = [theJSONFetcher statusCode];
	
	//NSLog(@"PRINTING LOVED BY:%@",[[NSString alloc] initWithData:theJSONFetcher.data encoding:NSASCIIStringEncoding]);
    
    if ([theJSONFetcher.data length] > 0 && statusCode == 200) {
        
		// We've finished loading the artists
		usersLoaded = YES;
		
        // Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		
		// Create a dictionary from the JSON string
		NSDictionary *results = [jsonString objectFromJSONString];
		
		// Build an array from the dictionary for easy access to each entry
		NSMutableArray *newUsers = (NSMutableArray *)[results objectForKey:@"users"];
		
		// Sort alphabetically by venue title
		NSSortDescriptor *alphaDesc = [[NSSortDescriptor alloc] initWithKey:@"username" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
		[newUsers sortUsingDescriptors:[NSArray arrayWithObject:alphaDesc]];	
		
		self.listItems = newUsers;
		
		//NSLog(@"listItems:%@", self.listItems);
    }
	
	// Reload table
	[self.listTable reloadData];
	
	[self hideLoading];
    
    fetcher = nil;
}


- (void)showLoading {
	
	[SVProgressHUD showInView:self.view status:nil networkIndicator:YES posY:-1 maskType:SVProgressHUDMaskTypeClear];
}


- (void)hideLoading {
	
	[SVProgressHUD dismissWithSuccess:@"Loaded!"];
}


@end
