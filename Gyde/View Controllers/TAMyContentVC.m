//
//  TAMyContentVC.m
//  Tourism App
//
//  Created by Richard Lee on 28/08/12.
//  Copyright (c) 2012 C2 Media Pty Ltd. All rights reserved.
//

#import "TAMyContentVC.h"
#import "TAImageGridVC.h"
#import "TAGuidesListVC.h"

@interface TAMyContentVC ()

@end

@implementation TAMyContentVC

@synthesize menuTable, menuItems, username;

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
	
	[self initNavBar];
    
	self.menuItems = [NSArray arrayWithObjects:@"Liked photos", @"My photos", @"My guides", @"Following guides", nil];
}


- (void)viewDidUnload {
	
    self.menuTable = nil;
    self.menuItems = nil;
	
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
    return [self.menuItems count];
}


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	
    // Retrieve the menu item from the menuItems array and display
	// it in the cell
	NSString *menuItem = [self.menuItems objectAtIndex:[indexPath row]];
	[cell.textLabel setText:menuItem];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    static NSString *CellIdentifier = @"Cell";
	
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
    if (cell == nil) {
		
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Retrieve Track object and set it's name to the cell
	[self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSString *menuItem = [self.menuItems objectAtIndex:[indexPath row]];
	
	if ([menuItem isEqualToString:@"Liked photos"]) {
		
		TAImageGridVC *likedPhotosVC = [[TAImageGridVC alloc] initWithNibName:@"TAImageGridVC" bundle:nil];
		[likedPhotosVC setUsername:self.username];
		[likedPhotosVC setImagesMode:ImagesModeLikedPhotos];
		
		[self.navigationController pushViewController:likedPhotosVC animated:YES];
	} 
	
	else if ([menuItem isEqualToString:@"My photos"]) {
		
		TAImageGridVC *imageGridVC = [[TAImageGridVC alloc] initWithNibName:@"TAImageGridVC" bundle:nil];
		[imageGridVC setUsername:self.username];
		[imageGridVC setImagesMode:ImagesModeMyPhotos];
		
		[self.navigationController pushViewController:imageGridVC animated:YES];
	} 
	
	else if ([menuItem isEqualToString:@"My guides"]) {
		
		// Go to the list of Guides I created
		// Set the username using the username property
		// Set the GuideMode to be GuidesModeMyGuides
		TAGuidesListVC *guidesListVC = [[TAGuidesListVC alloc] initWithNibName:@"TAGuidesListVC" bundle:nil];
		[guidesListVC setUsername:self.username];
		[guidesListVC setGuidesMode:GuidesModeMyGuides];
		
		[self.navigationController pushViewController:guidesListVC animated:YES];
	} 
	
	else if ([menuItem isEqualToString:@"Following guides"]) {
		
		// Go to the list of guides I'm following
		// Set the username using the username property
		// Set the GuideMode to be GuidesModeFollowing
		TAGuidesListVC *guidesListVC = [[TAGuidesListVC alloc] initWithNibName:@"TAGuidesListVC" bundle:nil];
		[guidesListVC setUsername:self.username];
		[guidesListVC setGuidesMode:GuidesModeFollowing];
		
		[self.navigationController pushViewController:guidesListVC animated:YES];
	} 
}


#pragma MY METHODS

- (void)initNavBar {

	self.navigationController.navigationBarHidden = NO;
}

@end
