//
//  TANotificationsVC.m
//  Tourism App
//
//  Created by Richard Lee on 22/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TANotificationsVC.h"
#import "AppDelegate.h"
#import "StringHelper.h"
#import "JSONKit.h"
#import "HTTPFetcher.h"
#import "TANotificationsManager.h"
#import "TAProfileVC.h"
#import "TAImageDetailsVC.h"
#import "TAGuideDetailsVC.h"
#import "CustomTabBarItem.h"
#import "MyGuidesTableCell.h"
#import "TAScrollVC.h"
#import "SVPullToRefresh.h"

#define RECOMMENDATIONS_TAB_X_POS 76.0
#define ME_TAB_X_POS 166.0
#define FOLLOWING_TAB_X_POS 254.0

#define ANIMATION_DURATION 0.25

@interface TANotificationsVC ()

@end

@implementation TANotificationsVC

@synthesize tabPointer = _tabPointer;
@synthesize selectedCategory = _selectedCategory;
@synthesize reccomendations, meItems, following, recommendationsTable;
@synthesize notifications;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		
//		CustomTabBarItem *tabItem = [[CustomTabBarItem alloc] initWithTitle:@"" image:nil tag:0];
//        
//        tabItem.customHighlightedImage = [UIImage imageNamed:@"news_tab_button-on.png"];
//        tabItem.customStdImage = [UIImage imageNamed:@"news_tab_button.png"];
//		tabItem.imageInsets = UIEdgeInsetsMake(6.0, 0.0, -6.0, 0.0);
//		
//        self.tabBarItem = tabItem;
//        tabItem = nil;
    }
    return self;
}

- (void)viewDidLoad {
	
    [super viewDidLoad];
	
	// Setup nav bar
	[self initNavBar];
    
    self.notifications = [NSMutableArray array];
    
    // By default, we want the view to be in 'Recommends mode'
    // and for the recommends button to be selected
    self.selectedCategory = NotificationsCategoryRecommendations;
    
    UIButton *recommendsBtn = (UIButton *)[self.view viewWithTag:RECOMMENDS_NEWS_TAG];
    [recommendsBtn setSelected:YES];
    [recommendsBtn setHighlighted:NO];
    
    self.selectedTabButton = recommendsBtn;
    
    __weak TANotificationsVC *weakSelf = self;
    
    // Add table refresh handler
    [self.recommendationsTable addPullToRefreshWithActionHandler:^{
        
        // prepend data to dataSource, insert cells at top of table view
        // call [tableView.pullToRefreshView stopAnimating] when done
        [weakSelf initGetNotificationsApi:^(BOOL finished){
            
            [weakSelf.recommendationsTable reloadData];
            [weakSelf.recommendationsTable.pullToRefreshView stopAnimating];
        }];
    }];
	
    
    
}

- (void)viewDidUnload {
	
	self.recommendationsTable = nil;
	
	self.notifications = nil;
	self.meItems = nil; 
	self.following = nil;
	self.reccomendations = nil;
	self.meItems = nil;
	self.following = nil;
    
    self.tabPointer = nil;
	
	[super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



- (void)viewWillAppear:(BOOL)animated {
	
	[super viewWillAppear:animated];
	
	[self initGetNotificationsApi:^(BOOL finished){
    
        [self.recommendationsTable reloadData];
    }];
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
	
    return [self.notifications count];
}


- (void)configureCell:(MyGuidesTableCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    // Make sure the cell images don't scale
    [cell.backgroundView setContentMode:UIViewContentModeTop];
    [cell.selectedBackgroundView setContentMode:UIViewContentModeTop];
	
    // Retrieve the Dictionary at the given index that's in self.users
	NSDictionary *notification = [self.notifications objectAtIndex:[indexPath row]];
	
	NSString *title = [notification objectForKey:@"title"];
	NSString *subtitle = [notification objectForKey:@"subtitle"];
	NSString *avatarURL = [NSString stringWithFormat:@"%@%@", FRONT_END_ADDRESS, [notification objectForKey:@"thumb"]];
    
    cell.titleLabel.text = title;
    cell.authorLabel.text = subtitle;
    
    [cell initImageDownload:avatarURL];
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


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
	return 9.0;
}


- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
	UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.frame.size.width, 9.0)];
	[headerView setBackgroundColor:[UIColor clearColor]];
	
	return headerView;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	// Retrieve the Dictionary at the given index that's in self.users
	NSDictionary *notification = [self.notifications objectAtIndex:[indexPath row]];
	
	// Find the type of notification we're dealing with
	NSString *type = [notification objectForKey:@"type"];
	
	
	if ([type isEqualToString:@"media"]) {
		
		// Push the Image Details VC onto the stack
		TAScrollVC *horizontalScroll = [[TAScrollVC alloc] initWithNibName:@"TAScrollVC" bundle:nil];
        [horizontalScroll setPhotosMode:PhotosModeSinglePhoto];
		[horizontalScroll setSelectedPhotoID:[notification objectForKey:@"code"]];
		
		[self.navigationController pushViewController:horizontalScroll animated:YES];
	}
	
	else if ([type isEqualToString:@"user"]) {
	
		// Push the User Profile VC onto the stack
		TAProfileVC *profileVC = [[TAProfileVC alloc] initWithNibName:@"TAProfileVC" bundle:nil];
		[profileVC setUsername:[notification objectForKey:@"code"]];
		[self.navigationController pushViewController:profileVC animated:YES];
	}
	
	else if ([type isEqualToString:@"guide"]) {
		
		// Push the User Profile VC onto the stack
		// Tell the VC what Guide is in question (GuideID) and what mode
		// we are viewing the guide details in. It is not our guide so we are
		// in GuideModeViewing
		TAGuideDetailsVC *guideDetailsVC = [[TAGuideDetailsVC alloc] initWithNibName:@"TAGuideDetailsVC" bundle:nil];
		[guideDetailsVC setGuideID:[notification objectForKey:@"code"]];
		[guideDetailsVC setGuideMode:GuideModeViewing];
		
		[self.navigationController pushViewController:guideDetailsVC animated:YES];
	}
}


#pragma MY METHODS

- (void)initNavBar {
	
	self.navigationItem.title = @"NOTIFICATIONS";
	self.navigationController.navigationBarHidden = NO;
}


/* This function calls the "getnotifications" API 
   The API will return how many new/unreceived notifications
   have been registered in the CMS for this user. It takes one parameter: a category
   string which dictates whether the API will fetch ME, recommendations or following
   notifications.
*/	
- (void)initRecommendationsAPI {
	
	NSString *type = @"me";
	
#warning TO DO
	NSInteger page = 1;
	NSInteger size = 5;
	//&pg=%i&sz=%i
	
	NSString *postString = [NSString stringWithFormat:@"username=%@&token=%@&category=%@", [self appDelegate].loggedInUsername, [[self appDelegate] sessionToken], type];
	
	NSData *postData = [NSData dataWithBytes:[postString UTF8String] length:[postString length]];
	
	// Create the URL that will be used to authenticate this user
	NSString *methodName = @"getnotifications";
	NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];
	
	// Initialiase the URL Request
	NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:postData];
	
	// HTTPFetcher
	recommendationsFetcher = [[HTTPFetcher alloc] initWithURLRequest:request
												   receiver:self action:@selector(receivedRecommendationsResponse:)];
	[recommendationsFetcher start];
}


- (void)initGetNotificationsApi:(void(^)(BOOL finished))completionBlock {

    NSString *category = [self getSelectedCategory];
    
	//NSInteger page = 1;
	//NSInteger size = 5;
	//&pg=%i&sz=%i
		
    NSDictionary *params = @{ @"username" : [self appDelegate].loggedInUsername, @"token" : [[self appDelegate] sessionToken], @"category" : category };
    
    [[GlooRequestManager sharedManager] post:@"getnotifications" params:params
                               dataLoadBlock:^(NSDictionary *json){}
                             completionBlock:^(NSDictionary *json){
                             
                                 if (self.selectedCategory == NotificationsCategoryRecommendations) {
                                     self.reccomendations = json[@"notifications"];
                                     self.notifications = self.reccomendations;
                                 }
                                 
                                 else if (self.selectedCategory == NotificationsCategoryMe) {
                                     self.meItems = json[@"notifications"];
                                     self.notifications = self.meItems;
                                 }
     
                                 else if (self.selectedCategory == NotificationsCategoryFollowing) {
                                     self.following = json[@"notifications"];
                                     self.notifications = self.following;
                                 }
                                 
                                 completionBlock(YES);
                             }
                                  viewForHUD:self.recommendationsTable];
}


- (IBAction)newsCategoryTabTapped:(id)sender {

    UIButton *btn = (UIButton *)sender;
        
    if (btn.tag != self.selectedCategory) {
        
        [self.selectedTabButton setSelected:NO];
        
        [btn setSelected:YES];
        [btn setHighlighted:NO];
        
        self.selectedTabButton = btn;
        
    
        switch (btn.tag) {
                
            case NotificationsCategoryRecommendations:
                self.selectedCategory = NotificationsCategoryRecommendations;
                break;
                
            case NotificationsCategoryMe:
                self.selectedCategory = NotificationsCategoryMe;
                break;
                
            case NotificationsCategoryFollowing:
                self.selectedCategory = NotificationsCategoryFollowing;
                break;
                
            default:
                break;
        }
        
        [self animateTabPointer];
        
        [self initGetNotificationsApi:^(BOOL finished){
        
            [self.recommendationsTable reloadData];
        }];
    }
}


- (void)animateTabPointer {
    
    //CGRect newFrame = self.tabPointer.frame;
    CGPoint newCenter = self.tabPointer.center;
    
    switch (self.selectedCategory) {
            
        case NotificationsCategoryRecommendations:
            newCenter.x = RECOMMENDATIONS_TAB_X_POS;
            break;
            
        case NotificationsCategoryMe:
            newCenter.x = ME_TAB_X_POS;
            break;
            
        case NotificationsCategoryFollowing:
            newCenter.x = FOLLOWING_TAB_X_POS;
            break;
            
        default:
            break;
    }

    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
		
		self.tabPointer.center = newCenter;
		
	} completion:^(BOOL finished) {
		
		// callback functionality
	}];
}


/*
	This function returns a string representing what notification
	category is currently selected. At the minute it bases this on
	what tab is selected in the UISegmentControl.
*/
- (NSString *)getSelectedCategory {
	
	NSString *category;
	
	switch (self.selectedCategory) {
			
		case NotificationsCategoryRecommendations:
			category = @"recommendations";
			break;
			
		case NotificationsCategoryMe:
			category = @"me";
			break;
			
		case NotificationsCategoryFollowing:
			category = @"following";
			break;
			
		default:
			category = @"recommendations";
			break;
	}
	
	return category;
}


- (void)willLogout {
    
    [self.navigationController popToRootViewControllerAnimated:NO];
}



@end
