//
//  TASettingsVC.m
//  Tourism App
//
//  Created by Richard Lee on 3/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TASettingsVC.h"
#import "TACitiesListVC.h"
#import <MessageUI/MessageUI.h>
#import "AppDelegate.h"
#import "HTTPFetcher.h"
#import "JSONKit.h"
#import "SVProgressHUD.h"
#import "EditProfileVC.h"
#import "TAScrollVC.h"
#import "TAGuidesListVC.h"
#import "SettingsTableCell.h"

#define TABLE_HEADER_HEIGHT 30.0
#define TABLE_FOOTER_HEIGHT 2.0

static NSString *kUserDefaultCityKey = @"userDefaultCityKey";

@interface TASettingsVC ()

@end

@implementation TASettingsVC

@synthesize settingsTable, menuDictionary, keys;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	
    if (self) {
		
       //[self setHidesBottomBarWhenPushed:NO];
    }
    return self;
}

- (void)viewDidLoad {
	
    [super viewDidLoad];
	
	[self initNavBar];
    
    // , @"Find via Twitter", @"Invite via Twitter"
    // , @"settings-icon-twitter.png", @"settings-icon-twitter.png"
	    
    NSArray *friendsObjects = [NSArray arrayWithObjects:@"Search users", @"Find via contacts", nil];
    NSArray *friendsIcons = [NSArray arrayWithObjects:@"settings-icon-map-marker.png", @"settings-icon-map-marker.png", nil];
    
	NSArray *accountObjects = [NSArray arrayWithObjects:@"Edit profile", nil];
    NSArray *accountIcons = [NSArray arrayWithObjects:@"settings-icon-map-marker.png", nil];
    
	NSArray *otherObjects = [NSArray arrayWithObjects:@"Contact support", nil];
    NSArray *otherIcons = [NSArray arrayWithObjects:@"settings-icon-contact.png", nil];
    
	NSArray *cityObjects = [NSArray arrayWithObjects:[self getUsersDefaultCity], nil];
	NSArray *cityIcons = [NSArray arrayWithObjects:@"settings-icon-map-marker.png", nil];
    
	
    NSArray *tmpKeys = [[NSArray alloc] initWithObjects:@"Friends", @"Account", @"Default City", @"Other", nil];
	self.keys = tmpKeys;
    
    NSArray *iconObjects = [[NSArray alloc] initWithObjects:friendsIcons, accountIcons, cityIcons, otherIcons, nil];
    
    NSMutableDictionary *tempIcons = [[NSMutableDictionary alloc] initWithObjects:iconObjects forKeys:self.keys];
    
    self.icons = tempIcons;
    
    
    // Create the master menu dictionary
    // which contains the arrays containing the relevant string objects
    // for each section of the menu table
	NSArray *objects = [NSArray arrayWithObjects:friendsObjects, accountObjects, cityObjects, otherObjects, nil];
    NSMutableDictionary *tmpMenuDict = [[NSMutableDictionary alloc] initWithObjects:objects forKeys:self.keys];
    
	self.menuDictionary = tmpMenuDict;
}


#pragma mark - Private Methods
- (AppDelegate *)appDelegate {
	
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}


- (void)viewDidUnload {
	
	self.menuDictionary = nil;
	self.keys = nil;
    self.icons = nil;
    self.settingsTable = nil;
    self.managedObjectContext = nil;
	
    [super viewDidUnload];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
    
    User *currUser = [User userWithUsername:[self appDelegate].loggedInUsername inManagedObjectContext:[self appDelegate].managedObjectContext];
    
    // Replace the default city value in the menuDictionary
	NSArray *newCityObjects = [NSArray arrayWithObjects:currUser.city, nil];
	[self.menuDictionary setValue:newCityObjects forKey:@"Default City"];

    [self.settingsTable reloadData];
    
    [self.settingsTable deselectRowAtIndexPath:[self.settingsTable indexPathForSelectedRow] animated:YES];
    
}


#pragma CitiesDelegate

- (void)locationSelected:(City *)city {
	
	[self showLoading];
	
	NSString *newCity = [city title];
    
    User *currUser = [User userWithUsername:[self appDelegate].loggedInUsername inManagedObjectContext:[self appDelegate].managedObjectContext];
    currUser.city = newCity;
    
    NSError *error = nil;
    [[self appDelegate].managedObjectContext save:&error];
	
	[self initUpdateProfileAPI:newCity];
	
	// Replace the default city value in the menuDictionary
	NSArray *newCityObjects = [NSArray arrayWithObjects:newCity, nil];
	[self.menuDictionary setValue:newCityObjects forKey:@"Default City"];
	
	[self.settingsTable reloadData];
	
	// A default city has just been selected. Store it.
	[[NSUserDefaults standardUserDefaults] setObject:newCity forKey:kUserDefaultCityKey];
}


#pragma mark MFMailComposeViewControllerDelegate

// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{	
    
    // Notifies users about errors associated with the interface
    switch (result) {
            
        case MFMailComposeResultCancelled:
            NSLog(@"Result: canceled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Result: saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Result: sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Result: failed");
            break;
        default:
            NSLog(@"Result: not sent");
            break;
    }
    
    [self dismissModalViewControllerAnimated:YES];
}


#pragma UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat sectionHeaderHeight = TABLE_HEADER_HEIGHT;
    
    if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0)
        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    
    else if (scrollView.contentOffset.y>=sectionHeaderHeight)
        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
		
    return [self.keys count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	NSArray *listData =[self.menuDictionary objectForKey:[self.keys objectAtIndex:section]];
	
    return [listData count];
}


- (void)configureCell:(SettingsTableCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	
    
    NSString *key = [self.keys objectAtIndex:[indexPath section]];
    
	NSArray *listData =[self.menuDictionary objectForKey:key]; 
	NSString *listItem = [listData objectAtIndex:[indexPath row]];
    
    NSString *iconName = [[self.icons objectForKey:key] objectAtIndex:[indexPath row]];
    
    // Make sure the cell images don't scale
    [cell.backgroundView setContentMode:UIViewContentModeTop];
    [cell.selectedBackgroundView setContentMode:UIViewContentModeTop];
	
    cell.iconView.image = [UIImage imageNamed:iconName];
	cell.titleLabel.text = listItem;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    SettingsTableCell *cell = (SettingsTableCell *)[tableView dequeueReusableCellWithIdentifier:[SettingsTableCell reuseIdentifier]];
    
    if (cell == nil) {
        
        // Load the top-level objects from the custom cell XIB.
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"SettingsTableCell" owner:self options:nil];
        
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
    
    // Section title label
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(14.0, 13.0, 295.0, 12.0)];
    [title setText:[[self.keys objectAtIndex:section] uppercaseString]];
    [title setFont:[UIFont boldSystemFontOfSize:12.0]];
    [title setBackgroundColor:[UIColor clearColor]];
    [title setShadowColor:[UIColor colorWithRed:252.0/255.0 green:250.0/255.0 blue:248.0/255.0 alpha:1.0]];
    
    [headerView addSubview:title];
    
	return headerView;
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
	return TABLE_FOOTER_HEIGHT;
}


- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.frame.size.width, TABLE_FOOTER_HEIGHT)];
    [footerView setBackgroundColor:[UIColor clearColor]];
    
    // Section groove border
    UIImage *borderImage = [UIImage imageNamed:@"thumb-sliders-horizontal-divider.png"];
    UIImageView *border = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, (TABLE_FOOTER_HEIGHT - borderImage.size.height), borderImage.size.width, borderImage.size.height)];
    [border setImage:borderImage];
    
    [footerView addSubview:border];
    
	return footerView;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSArray *listData =[self.menuDictionary objectForKey:[self.keys objectAtIndex:[indexPath section]]]; 
	NSString *listItem = [listData objectAtIndex:[indexPath row]];
		
	NSString *key = [self.keys objectAtIndex:[indexPath section]];
	
	
	
	// DO LOG OUTT!!!!!!!!
	if ([listItem isEqualToString:@"Log out"]){
		
		// Log the user out
		[self logout];
	}
	
	else if ([listItem isEqualToString:@"Loved photos"]) {
    
        TAScrollVC *horizontalScroll = [[TAScrollVC alloc] initWithNibName:@"TAScrollVC" bundle:nil];
        [horizontalScroll setPhotosMode:PhotosModeLovedPhotos];
        
        [self.navigationController pushViewController:horizontalScroll animated:YES];
    }
	
	else if ([listItem isEqualToString:@"Followed guides"]) {
    
        // Go to the list of guides I'm following
		// Set the username using the username property
		// Set the GuideMode to be GuidesModeFollowing
		TAGuidesListVC *guidesListVC = [[TAGuidesListVC alloc] initWithNibName:@"TAGuidesListVC" bundle:nil];
		[guidesListVC setUsername:[self appDelegate].loggedInUsername];
		[guidesListVC setGuidesMode:GuidesModeFollowing];
		
		[self.navigationController pushViewController:guidesListVC animated:YES];
    }
	
	else if ([listItem isEqualToString:@"Private photos"]) {
		
		
	}

	
	else if ([listItem isEqualToString:@"Edit profile"]){
		
		EditProfileVC *editProfileVC = [[EditProfileVC alloc] initWithNibName:@"EditProfileVC" bundle:nil];
		
		[self.navigationController pushViewController:editProfileVC animated:YES];
	}
	
	else if ([key isEqualToString:@"Default City"]){
		
		TACitiesListVC *citiesListVC = [[TACitiesListVC alloc] initWithNibName:@"TACitiesListVC" bundle:nil];
		[citiesListVC setDelegate:self];
        [citiesListVC setManagedObjectContext:self.managedObjectContext];
		
		// Look for the user's default city
		NSString *defaultCity = [self getUsersDefaultCity];
		
		if ([defaultCity length] > 0) {
            
            City *city = [City cityWithTitle:defaultCity inManagedObjectContext:self.managedObjectContext];
		
			if (city)[citiesListVC setSelectedCity:city];
		}
		
		[self.navigationController pushViewController:citiesListVC animated:YES];
	}
	
	else if ([listItem isEqualToString:@"About"]){
		
		/*
		TAAboutVC *aboutVC = [[TAAboutVC alloc] initWithNibName:@"TAAboutVC" bundle:nil];
		
		[self.navigationController pushViewController:aboutVC animated:YES];
		[aboutVC release];
		*/
	}
	
	else if ([listItem isEqualToString:@"Contact support"]){
		
		// Email message here
		MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
		picker.mailComposeDelegate = self;
		
		// SUBJECT
		[picker setSubject:@"RE: Gyde for iOS"];
		
		// TO ADDRESS...
		NSArray *recipients = [[NSArray alloc] initWithObjects:@"hello@c2.net.au", nil];
		[picker setToRecipients:recipients];
		
		// BODY TEXT
		NSString *bodyContent = @"I was using the Tourism App...";
		NSString *emailBody = [NSString stringWithFormat:@"%@\n\n", bodyContent];
		[picker setMessageBody:emailBody isHTML:NO];
		
		// SHOW INTERFACE
		[self presentModalViewController:picker animated:YES];
	}
    
    else if ([listItem isEqualToString:@"Search users"]) {
    
        TAUsersVC *usersVC = [[TAUsersVC alloc] initWithNibName:@"TAUsersVC" bundle:nil];
		[usersVC setUsersMode:UsersModeSearchUsers];
        [usersVC setSelectedUsername:[self appDelegate].loggedInUsername];
        
		[self.navigationController pushViewController:usersVC animated:YES];
    }
    
    else if ([listItem isEqualToString:@"Find via contacts"]) {
        
        TAUsersVC *usersVC = [[TAUsersVC alloc] initWithNibName:@"TAUsersVC" bundle:nil];
		[usersVC setUsersMode:UsersModeFindViaContacts];
        [usersVC setSelectedUsername:[self appDelegate].loggedInUsername];
        
		[self.navigationController pushViewController:usersVC animated:YES];
    }
    
    else if ([listItem isEqualToString:@"Find via Twitter"]) {
        
        TAUsersVC *usersVC = [[TAUsersVC alloc] initWithNibName:@"TAUsersVC" bundle:nil];
		[usersVC setUsersMode:UsersModeFindViaTwitter];
        [usersVC setSelectedUsername:[self appDelegate].loggedInUsername];
        
		[self.navigationController pushViewController:usersVC animated:YES];
    }
    
    else if ([listItem isEqualToString:@"Invite via Twitter"]) {
        
        TAUsersVC *usersVC = [[TAUsersVC alloc] initWithNibName:@"TAUsersVC" bundle:nil];
		[usersVC setUsersMode:UsersModeInviteViaTwitter];
        [usersVC setSelectedUsername:[self appDelegate].loggedInUsername];
        
		[self.navigationController pushViewController:usersVC animated:YES];
    }
}
							




- (NSString *)getUsersDefaultCity {
	
	// In time this should be a property that will be saved in NSUserDefaults.
	NSString *defaultCity = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultCityKey];
	
	return defaultCity;
}


- (void)initUpdateProfileAPI:(NSString *)newCity {
	
	// Convert string to data for transmission
	NSString *jsonString = [NSString stringWithFormat:@"username=%@&city=%@&token=%@", [self appDelegate].loggedInUsername, newCity, [[self appDelegate] sessionToken]];
    NSData *jsonData = [jsonString dataUsingEncoding:NSASCIIStringEncoding];
    
    // Create the URL that will be used to authenticate this user
	NSString *methodName = @"UpdateProfile";
	NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];
    
    // Initialiase the URL Request
    NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:jsonData];
	
	// HTTPFetcher
    profileFetcher = [[HTTPFetcher alloc] initWithURLRequest:request
												  receiver:self
													action:@selector(receivedUpdateProfileResponse:)];
    [profileFetcher start];
}


// Example fetcher response handling
- (void)receivedUpdateProfileResponse:(HTTPFetcher *)aFetcher {
    
    HTTPFetcher *theJSONFetcher = (HTTPFetcher *)aFetcher;
	
	//NSLog(@"UPDATE PROFILE DETAILS:%@",[[NSString alloc] initWithData:theJSONFetcher.data encoding:NSASCIIStringEncoding]);
    
	NSAssert(aFetcher == profileFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	//loading = NO;
	
	NSInteger statusCode = [theJSONFetcher statusCode];
	
	if ([theJSONFetcher.data length] > 0 && statusCode == 200) {
		
		// Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		 
		 // Create a dictionary from the JSON string
		/* NSDictionary *results = [jsonString JSONValue];
		 
		 // Build an array from the dictionary for easy access to each entry
		 NSDictionary *newUserData = [results objectForKey:@"user"];
		 
		[jsonString release];*/
	}
	
	// Hide loading view
	[self hideLoading];
	
	profileFetcher = nil;
    
}


- (void)showLoading {
	
	[SVProgressHUD showInView:self.view status:nil networkIndicator:YES posY:-1 maskType:SVProgressHUDMaskTypeClear];
}


- (void)hideLoading {
	
	[SVProgressHUD dismissWithSuccess:@"Loaded!"];
}


#pragma mark - Public Methods

- (IBAction)logoutButtonTapped:(id)sender {

    [self logout];
}


- (void)initNavBar {
	
	self.navigationItem.title = @"SETTINGS";
	
    UIButton *logoutBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [logoutBtn setImage:[UIImage imageNamed:@"nav-bar-logout-button.png"] forState:UIControlStateNormal];
    [logoutBtn setImage:[UIImage imageNamed:@"nav-bar-logout-button-on.png"] forState:UIControlStateHighlighted];
    [logoutBtn setFrame:CGRectMake(0, 0, 34, 27)];
    [logoutBtn addTarget:self action:@selector(logoutButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *logoutButtonItem = [[UIBarButtonItem alloc] initWithCustomView:logoutBtn];
    
	self.navigationItem.rightBarButtonItem = logoutButtonItem;
}


- (void)logout {
	
    [[self appDelegate].landingVC logout];
}


- (void)willLogout {
    
    [self.navigationController popToRootViewControllerAnimated:NO];
}


@end
