//
//  TAUsersVC.m
//  Tourism App
//
//  Created by Richard Lee on 20/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TAUsersVC.h"
#import	"SVProgressHUD.h"
#import "JSONKit.h"
#import "SVProgressHUD.h"
#import "JSONKitRequest.h"
#import "TAProfileVC.h"
#import "AppDelegate.h"
#import "TAUserTableCell.h"
#import "HTTPFetcher.h"
#import "ASIHTTPRequest.h"

#define TABLE_HEADER_HEIGHT 0.0
#define TABLE_FOOTER_HEIGHT 4.0

#define TAP_NAV_TAG 9000

@interface TAUsersVC ()

@end

@implementation TAUsersVC

@synthesize usersMode, navigationTitle, delegate, searchField, following, accountStore;
@synthesize usersTable, selectedUsername, users, managedObjectContext, selectedAccount, loadCell;

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
    
	// Set the title of this view controller
	self.title = self.navigationTitle;
	
	if (self.usersMode == UsersModeFindViaContacts) {
		
		self.managedObjectContext = [self appDelegate].managedObjectContext;
	}
	
	if (self.usersMode == UsersModeRecommendTo) {
		
        UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [saveBtn setFrame:CGRectMake(256, 8, 54, 27)];
        [saveBtn addTarget:self action:@selector(saveSelections:) forControlEvents:UIControlEventTouchUpInside];
        [saveBtn setImage:[UIImage imageNamed:@"nav-bar-save-button.png"] forState:UIControlStateNormal];
        
        UIView *topNav = [self.view viewWithTag:TAP_NAV_TAG];
        [topNav addSubview:saveBtn];
	}
	
	
	// If the mode is UsersModeSearchUsers
	// then we need to show the search bar
	if (self.usersMode == UsersModeSearchUsers) {
		
		self.searchField.hidden = NO;
		
		CGFloat barHeight = self.searchField.frame.size.height;
		
		// Adjust the position of the table
		CGRect frame = self.usersTable.frame;
		frame.origin.y += barHeight;
		frame.size.height -= barHeight;
		[self.usersTable setFrame:frame];
	}
}


#pragma mark - Private Methods
- (AppDelegate *)appDelegate {
	
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}


- (void)viewDidUnload {
	
	self.navigationTitle = nil;
	self.searchField = nil;
	self.following = nil;
	self.accountStore = nil;
	self.usersTable	= nil;
	self.selectedUsername = nil;
	self.users = nil;
	self.managedObjectContext = nil;
	self.selectedAccount = nil;
	self.loadCell = nil;
    self.followingRequest = nil;
    self.followersRequest = nil;
    
    [super viewDidUnload];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)viewWillAppear:(BOOL)animated {
	
    [super viewWillAppear:animated];
	
	if (!usersLoaded && !loading) {
		
		loading = YES;
		
		// Show loading animation
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
		
		switch (self.usersMode) {
				
			case UsersModeFollowing:
				[self initFollowingAPI];
				break;
			
			case UsersModeFollowers:
                [self initFollowingAPI];
				break;
				
			case UsersModeRecommendTo:
				[self.usersTable setAllowsMultipleSelection:YES];
				[self initFollowersAPI];
				break;
				
			case UsersModeFindViaContacts:
				[self initFollowingAPI];
				break;
				
			case UsersModeFindViaTwitter:
				[self initFollowingAPI];
				break;
				
			case UsersModeFindViaFB:
				//[self initFBFriendsAPI];
				break;
				
			case UsersModeInviteViaTwitter:
				[self initTwitterAccountSelection];
				break;
				
			case UsersModeSearchUsers:
				[self initFollowingAPI];
				break;
				
			default:
				loading = NO;
				[MBProgressHUD hideHUDForView:self.view animated:YES];
				break;
		}
	}
    
    [self.usersTable deselectRowAtIndexPath:[self.usersTable indexPathForSelectedRow] animated:YES];
}


- (void)viewWillDisappear:(BOOL)animated {
    
	[super viewWillDisappear:animated];
    
    if ([self.followingRequest inProgress]) {
        
        [self.followingRequest clearDelegatesAndCancel];
    }
    
    if ([self.followersRequest inProgress]) {
        
        [self.followersRequest clearDelegatesAndCancel];
    }
}


- (IBAction)followingButtonTapped:(id)sender {
	
	UIButton *userCellButton = (UIButton *)sender;
	
	UIView *contentView = [userCellButton superview];
	TAUserTableCell *userCell = (TAUserTableCell *)[contentView superview];
	
	NSIndexPath *path = [self.usersTable indexPathForCell:userCell];
	
    [userCell setFollowingUser:NO];
	
	/*if (self.usersMode == UsersModeSearchUsers) {
		
		NSDictionary *user = [self.users objectAtIndex:[path row]];
		[self initUnfollowAPI:[user objectForKey:@"username"]];
	}
	
	else {*/
		
		User *user = [self.users objectAtIndex:[path row]];
		[self initUnfollowAPI:user.username];
	//}
}


- (IBAction)followButtonTapped:(id)sender {
	
	UIButton *userCellButton = (UIButton *)sender;
	
	UIView *contentView = [userCellButton superview];
	TAUserTableCell *userCell = (TAUserTableCell *)[contentView superview];
	
	NSIndexPath *path = [self.usersTable indexPathForCell:userCell];
	
    [userCell setFollowingUser:YES];
	
	/*if (self.usersMode == UsersModeSearchUsers) {
		
		NSDictionary *user = [self.users objectAtIndex:[path row]];
		[self initFollowAPI:[user objectForKey:@"username"]];
	}
	
	else {*/
		
		User *user = [self.users objectAtIndex:[path row]];
		[self initFollowAPI:user.username];
	//}
}


#pragma mark Search Bar Delegate methods
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	
	// Hide keyboard
	[self.searchField resignFirstResponder];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
	
	// Call "FindUser" API
	if (!loading) [self initFindUserAPI];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
    return [self.users count];
}


- (void)configureCell:(TAUserTableCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	
    
    // Make sure the cell images don't scale
    [cell.backgroundView setContentMode:UIViewContentModeTop];
    [cell.selectedBackgroundView setContentMode:UIViewContentModeTop];
    
    
	NSString *name;
	NSString *username;
	NSString *avatarURL;	
	
	BOOL followingUser = NO;
	
	// FOR NOW - account for the fact that FindUser returns
	// a set of Users in a different format
	//if (self.usersMode == UsersModeFindViaContacts || self.usersMode == UsersModeFindViaTwitter) {
		
		User *user = [self.users objectAtIndex:[indexPath row]];
		
		if ([self.following containsObject:user.username])
			followingUser = YES;
		
		name = user.fullName;
		username = user.username;
		avatarURL = user.avatarURL;
		
		[cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
		
		if ([name length] == 0) name = @"";
	/*}
	
	else {
		
		// Retrieve the Dictionary at the given index that's in self.users
		NSDictionary *user = [self.users objectAtIndex:[indexPath row]];
		
		name = [user objectForKey:@"name"];
		username = [user objectForKey:@"username"];
		avatarURL = [NSString stringWithFormat:@"%@%@", FRONT_END_ADDRESS, [user objectForKey:@"avatar"]];
		
		if ([self.following containsObject:username])
			followingUser = YES;
		
		[cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
		
		if ([name length] == 0) name = @"";
	}*/
	
    if (self.usersMode != UsersModeRecommendTo)
        [cell setFollowingUser:followingUser];
	
	[cell.usernameLabel setText:username];
	[cell.nameLabel setText:name];
	
	[cell initImage:avatarURL];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    TAUserTableCell *cell = (TAUserTableCell *)[tableView dequeueReusableCellWithIdentifier:[TAUserTableCell reuseIdentifier]];
	
	if (cell == nil) {
		
		[[NSBundle mainBundle] loadNibNamed:@"TAUserTableCell" owner:self options:nil];
        cell = loadCell;
        self.loadCell = nil;
	}
	
	// Retrieve Track object and set it's name to the cell
	[self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (self.usersMode != UsersModeRecommendTo) {
		
		//if (self.usersMode == UsersModeFindViaContacts) {
			
			// Retrieve the User object at the given index that's in self.users
			User *user = [self.users objectAtIndex:[indexPath row]];		
			NSString *username = user.username;
			
			TAProfileVC *profileVC = [[TAProfileVC alloc] initWithNibName:@"TAProfileVC" bundle:nil];
			[profileVC setUsername:username];
			
			[self.navigationController pushViewController:profileVC animated:YES];
		/*}
			
		else {
			
			// Retrieve the Dictionary at the given index that's in self.users
			NSDictionary *user = [self.users objectAtIndex:[indexPath row]];		
			NSString *username = [user objectForKey:@"username"];
			
			TAProfileVC *profileVC = [[TAProfileVC alloc] initWithNibName:@"TAProfileVC" bundle:nil];
			[profileVC setUsername:username];
			
			[self.navigationController pushViewController:profileVC animated:YES];
			[profileVC release];
		}*/
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

- (void)imageLoaded:(UIImage *)image withURL:(NSURL *)url {
	
	NSArray *cells = [self.usersTable visibleCells];
//    [cells retain];
    SEL selector = @selector(imageLoaded:withURL:);
	
    for (int i = 0; i < [cells count]; i++) {
		
		UITableViewCell* c = [cells objectAtIndex: i];
        if ([c respondsToSelector:selector]) {
            [c performSelector:selector withObject:image withObject:url];
        }
//        [c release];
		c = nil;
    }
	
//    [cells release];
}


- (void)initFollowingAPI {
    
    NSDictionary *params = @{@"username" : self.selectedUsername, @"pg" : [NSString stringWithFormat:@"%d", page], @"sz" : [NSString stringWithFormat:@"%d", batchSize] };
    
    [[GlooRequestManager sharedManager] post:@"Following" params:params
                               dataLoadBlock:^(NSDictionary *json) {}
                             completionBlock:^(NSDictionary *json) {
                             
                                 usersLoaded = YES;
                                 
                                 // Build an array from the dictionary for easy access to each entry
                                 NSMutableArray *newFollowers = [[self appDelegate] serializeUsersData:[json objectForKey:@"users"]];
                                 
                                 [self populateFollowingArray:newFollowers];
                                 
                                 if (self.usersMode == UsersModeFindViaContacts)
                                     [self initAddressBook];
                                 
                                 else if (self.usersMode == UsersModeFindViaTwitter)
                                     [self initTwitterAccountSelection];
                                 
                                 else if (self.usersMode == UsersModeSearchUsers) {
                                     
                                     // we are no longer loading
                                     loading = NO;
                                     
                                     [MBProgressHUD hideHUDForView:self.view animated:YES];
                                 }
                                 
                                 else if (self.usersMode == UsersModeFollowers)
                                     [self initFollowersAPI];
                                 
                                 
                                 else {
                                     
                                     // we are no longer loading
                                     loading = NO;
                                     
                                     // Sort alphabetically by venue title
                                     NSSortDescriptor *alphaDesc = [[NSSortDescriptor alloc] initWithKey:@"username" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
                                     [newFollowers sortUsingDescriptors:[NSArray arrayWithObject:alphaDesc]];
                                     
                                     self.users = newFollowers;
                                     
                                     [MBProgressHUD hideHUDForView:self.view animated:YES];
                                     
                                     // Reload table
                                     [self.usersTable reloadData];
                                 }

                             }
                            viewForHUD:nil];
}


- (void)initFollowersAPI {
	
	// Create the URL that will be used to authenticate this user
    if (!self.followersRequest) {
        
        NSString *methodName = @"Followers";
        NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];
        
        self.followersRequest = [ASIHTTPRequest requestWithURL:url];
        [self.followersRequest addRequestHeader:@"Accept" value:@"application/json"];
        [self.followersRequest addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
        [self.followersRequest setRequestMethod:@"POST"];
        
        [self.followersRequest setDelegate:self];
        [self.followersRequest setDidFinishSelector:@selector(followersAPIFinished:)];
        [self.followersRequest setDidFailSelector:@selector(followersAPIFailed:)];
    }
    
    // Construct the data to be attached to the request
    NSString *postString = [NSString stringWithFormat:@"username=%@&pg=%i&sz=%i", self.selectedUsername, page, batchSize];
	NSMutableData *postData = [NSMutableData dataWithBytes:[postString UTF8String] length:[postString length]];
    [self.followersRequest setPostBody:postData];
    [self.followersRequest addRequestHeader:@"Content-Length" value:[NSString stringWithFormat:@"%d", [postData length]]];
    
    // Start the request
    [self.followersRequest startAsynchronous];
    
}


- (void)followersAPIFinished:(ASIHTTPRequest*)req {
    
    NSLog(@"followersAPIFinished");
    
    // We are not loading
	loading = NO;
    
    if ([req.responseData length] > 0 && [req responseStatusCode] == 200) {
        
		// We've finished loading the artists
		usersLoaded = YES;
        
        // Create a dictionary from the JSON string
        NSDictionary *results = [[req responseString] objectFromJSONString];
		
		// Build an array from the dictionary for easy access to each entry
		NSMutableArray *newFollowers = [[self appDelegate] serializeUsersData:[results objectForKey:@"users"]];
		
		// Sort alphabetically by venue title
		NSSortDescriptor *alphaDesc = [[NSSortDescriptor alloc] initWithKey:@"username" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
		[newFollowers sortUsingDescriptors:[NSArray arrayWithObject:alphaDesc]];
		
		self.users = newFollowers;
    }
	
	// Reload table
	[self.usersTable reloadData];
	
	[MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}


- (void)followersAPIFailed:(ASIHTTPRequest*)req {
    
    // We are not loading
	loading = NO;
    
    usersLoaded = NO;
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}


- (void)willLogout {
    
    [self.navigationController popToRootViewControllerAnimated:NO];
}


- (void)saveSelections:(id)sender {

	NSArray *selectedPaths = [self.usersTable indexPathsForSelectedRows];
	NSMutableArray *selectedUsers = [NSMutableArray array];
	
	for (int i = 0; i < [selectedPaths count]; i++) {
		
		NSIndexPath *path = [selectedPaths objectAtIndex:i];
		
		User *user = [self.users objectAtIndex:[path row]];
		NSString *username = [user username];
		
		[selectedUsers addObject:username];
	}
	
	// Pass the usernames array to the delegate (Create Guide VC)
	[self.delegate recommendToUsernames:selectedUsers];
	
	// Go back to Create Guide VC
	[self.navigationController popViewControllerAnimated:YES];
}


- (void)initFindUserAPI {
	
	NSString *postString = [NSString stringWithFormat:@"q=%@", self.searchField.text];
	NSData *postData = [NSData dataWithBytes:[postString UTF8String] length:[postString length]];
	
	// Create the URL that will be used to authenticate this user
	NSString *methodName = @"FindUser";
	NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];
	
	// Initialiase the URL Request
	NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:postData];
	
	usersFetcher = [[HTTPFetcher alloc] initWithURLRequest:request
												   receiver:self action:@selector(receivedFindUserResponse:)];
	[usersFetcher start];
}


// Example fetcher response handling
- (void)receivedFindUserResponse:(HTTPFetcher *)aFetcher {
    
    HTTPFetcher *theJSONFetcher = (HTTPFetcher *)aFetcher;
    
    NSAssert(aFetcher == usersFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	// We are not loading
	loading = NO;
	
	//NSLog(@"PRINTING USER SEARCH DATA:%@",[[NSString alloc] initWithData:theJSONFetcher.data encoding:NSASCIIStringEncoding]);
	
	NSInteger statusCode = [theJSONFetcher statusCode];
    
    if ([theJSONFetcher.data length] > 0 && statusCode == 200) {
		
		// We've finished loading the cities
		usersLoaded = YES;
        
        // Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		
		// Create a dictionary from the JSON string
		NSDictionary *results = [jsonString objectFromJSONString];
		
//		[jsonString release];
		
		// Build an array from the dictionary for easy access to each entry
		self.users = [[self appDelegate] serializeUsersData:[results objectForKey:@"users"]];
    }
	
	[MBProgressHUD hideHUDForView:self.view animated:YES];
	
	[self.usersTable reloadData];
    
//    [usersFetcher release];
    usersFetcher = nil;
}

#warning TO DO
- (void)initAddressBook {

//	ABAddressBookRef ab =ABAddressBookCreate();
//	NSArray *contacts = (__bridge NSArray *)ABAddressBookCopyArrayOfAllPeople(ab);
//	
//	NSMutableArray *emails = [[NSMutableArray alloc] init];
//	
//	for (int i = 0; i < [contacts count]; i++) {
//	
//		ABRecordRef *person = (ABRecordRef *)[contacts objectAtIndex:i];
//		
//		ABMultiValueRef emailProperty = (ABMultiValueRef)ABRecordCopyValue(person, kABPersonEmailProperty);
//		
//		// convert it to an array
//		CFArrayRef allEmails = ABMultiValueCopyArrayOfAllValues(emailProperty);
//		
//		CFRelease(emailProperty);
//		
//		// add these emails to our initial array
//		[emails addObjectsFromArray:(__bridge NSArray *)allEmails];
//		
//		//CFRelease(allEmails);
//	}
//	
//	CFRelease((__bridge CFTypeRef)(contacts));
//	
//	NSString *emailsString = [emails componentsJoinedByString:@","];
//	
//	[self initContactsFriendsAPI:emailsString];
//	
//	CFRelease(ab);
}


- (void)initContactsFriendsAPI:(NSString *)emailsString {

	NSString *postString = [NSString stringWithFormat:@"username=%@&token=%@&friends_emails=%@", 
							[self appDelegate].loggedInUsername, [[self appDelegate] sessionToken], emailsString];
	NSData *postData = [NSData dataWithBytes:[postString UTF8String] length:[postString length]];
	
	// Create the URL that will be used to authenticate this user
	NSString *methodName = @"ContactsFriends";
	NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];
	
	// Initialiase the URL Request
	NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:postData];
	
	// JSONFetcher
	contactsFetcher = [[HTTPFetcher alloc] initWithURLRequest:request
												  receiver:self
													action:@selector(receivedContactsFriendsResponse:)];
	[contactsFetcher start];
}


// Example fetcher response handling
- (void)receivedContactsFriendsResponse:(HTTPFetcher *)aFetcher {
    
    HTTPFetcher *theJSONFetcher = (HTTPFetcher *)aFetcher;
    
    NSAssert(aFetcher == contactsFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	// We are not loading
	loading = NO;
	
	NSInteger statusCode = [theJSONFetcher statusCode];
	
	//NSLog(@"PRINTING CONTACTS FRIENDS:%@",[[NSString alloc] initWithData:theJSONFetcher.data encoding:NSASCIIStringEncoding]);
    
    if ([theJSONFetcher.data length] > 0 && statusCode == 200) {
        
        // Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		
		// Create a dictionary from the JSON string
		NSDictionary *results = [jsonString objectFromJSONString];
		
		// Build an array from the dictionary for easy access to each entry
		self.users = [self convertToUsers:[results objectForKey:@"users"]];
		
		// clean up
//		[jsonString release];
		
		// We've finished loading the artists
		usersLoaded = YES;
    }
	
	// Reload table
	[self.usersTable reloadData];
	
	[MBProgressHUD hideHUDForView:self.view animated:YES];
    
//    [contactsFetcher release];
    contactsFetcher = nil;
}


- (void)determineFollowingUsers:(NSMutableArray *)installedUsers {

	/*self.users = [NSMutableArray array];
	
	NSArray *keys = 
	
	for (int i = 0; i < [self.following count]; i++) {
	
		NSDictionary *userDict = [self.following objectAtIndex:i];
		
		NSString *username = [userDict objectForKey:@"username"];
		
		if ([installedUsers containsObject:username]) {
		
			[installedUsers replaceObjectAtIndex:<#(NSUInteger)#> withObject:<#(id)#>];
		}
		
	}
	*/
}


- (void)initTwitterFriendsAPI:(NSString *)user_ids {
	
	NSString *postString = [NSString stringWithFormat:@"username=%@&token=%@&user_ids=%@", 
							[self appDelegate].loggedInUsername, [[self appDelegate] sessionToken], user_ids];
	
	NSLog(@"TWITTER FRIENDS DATA:%@", postString);
	
	NSData *postData = [NSData dataWithBytes:[postString UTF8String] length:[postString length]];
	
	// Create the URL that will be used to authenticate this user
	NSString *methodName = @"TwitterFriends";
	NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];
	
	// Initialiase the URL Request
	NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:postData];
	
	// HTTPFetcher
	contactsFetcher = [[HTTPFetcher alloc] initWithURLRequest:request
													 receiver:self
													   action:@selector(receivedTwitterFriendsResponse:)];
	[contactsFetcher start];
}


// Example fetcher response handling
- (void)receivedTwitterFriendsResponse:(HTTPFetcher *)aFetcher {
    
    HTTPFetcher *theJSONFetcher = (HTTPFetcher *)aFetcher;
    
    NSAssert(aFetcher == contactsFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	// We are not loading
	loading = NO;
	
	NSInteger statusCode = [theJSONFetcher statusCode];
	
	//NSLog(@"PRINTING TWITTER FRIENDS:%@",[[NSString alloc] initWithData:theJSONFetcher.data encoding:NSASCIIStringEncoding]);
    
    if ([theJSONFetcher.data length] > 0 && statusCode == 200) {
        
        // Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		
		// Create a dictionary from the JSON string
		NSDictionary *results = [jsonString objectFromJSONString];
		
		// Build an array from the dictionary for easy access to each entry
		self.users = [self convertToUsers:[results objectForKey:@"users"]];
		
		// clean up
//		[jsonString release];
		
		// We've finished loading the artists
		usersLoaded = YES;
    }
	
	// Reload table
	[self.usersTable reloadData];
	
	[MBProgressHUD hideHUDForView:self.view animated:YES];
    
//    [contactsFetcher release];
    contactsFetcher = nil;
}


- (void)initTwitterIDsAPI:(ACAccount *)account {
	
	NSString *username = account.username;
			
	//  Next, we create an URL that points to the target endpoint
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.twitter.com/1.1/friends/ids.json?screen_name=%@&stringify_ids=true", username]];
	
	//  Now we can create our request.  Note that we are performing a GET request.
	TWRequest *request = [[TWRequest alloc] initWithURL:url 
											 parameters:nil 
										  requestMethod:TWRequestMethodGET];
	
	// Attach the account object to this request
	[request setAccount:account];
			
	[request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
		
		if (!responseData) {
			// inspect the contents of error 
			NSLog(@"%@", error);
		} 
		
		else {
			
			NSError *jsonError;
			NSArray *idsArray = [[NSJSONSerialization JSONObjectWithData:responseData 
																 options:NSJSONReadingMutableLeaves 
																   error:&jsonError] objectForKey:@"ids"];            
			if (idsArray) {      
				
				// at this point, we have an object that we can parse
				NSLog(@"TIMELINE:%@", idsArray);
				
				NSString *userIDs = [idsArray componentsJoinedByString:@","];
				[self initTwitterFriendsAPI:userIDs];
				
			} 
			else { 
				// inspect the contents of jsonError
				NSLog(@"%@", jsonError);
			}
		}
	}];
}
			 

- (NSMutableArray *)convertToUsers:(NSArray *)usersArray {

	NSMutableArray *userObjects = [NSMutableArray array];
	
	for (int i = 0; i < [usersArray count]; i++) {
		
		NSDictionary *userDict = [usersArray objectAtIndex:i];
 		User *user = [User userWithBasicData:userDict inManagedObjectContext:self.managedObjectContext];
		[userObjects addObject:user];
	}
	
	return userObjects;
}


- (void)populateFollowingArray:(NSArray *)followingArray {
	
	self.following = [NSMutableArray array];
	
	for (int i = 0; i < [followingArray count]; i++) {
		
		User *user = [followingArray objectAtIndex:i];
		
		[self.following addObject:[user username]];
	}
}


- (void)initTwitterAccountSelection {
	
	ACAccountStore *tmpAccountStore = [[ACAccountStore alloc] init];
	self.accountStore = tmpAccountStore;
//	[tmpAccountStore release];
	
	// Create an account type that ensures Twitter accounts are retrieved.
	ACAccountType *accountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
	
	// Request access from the user to use their Twitter accounts.
	[self.accountStore requestAccessToAccountsWithType:accountType withCompletionHandler:^(BOOL granted, NSError *error) {
		
		if(granted) {
			
			NSString *accID = [[self appDelegate] getTwitterAccountID];
			
			if ([accID length] > 0) {
			
				self.selectedAccount = [self.accountStore accountWithIdentifier:accID];
			
				if (self.usersMode == UsersModeInviteViaTwitter) [self initFriendsAPI:self.selectedAccount];
				
				else if (self.usersMode == UsersModeFindViaTwitter) [self initTwitterIDsAPI:self.selectedAccount];
			}
			
			else {
				
				//NSArray *accounts = [accountStore accountsWithAccountType:accountType];
			}
		}
	}];
}


- (void)initFriendsAPI:(ACAccount *)account {

	[MBProgressHUD hideHUDForView:self.view animated:YES];
	
	NSString *username = account.username;
	
	//  Next, we create an URL that points to the target endpoint
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.twitter.com/1.1/friends/ids.json?screen_name=%@&stringify_ids=true", username]];
	
	//  Now we can create our request.  Note that we are performing a GET request.
	TWRequest *request = [[TWRequest alloc] initWithURL:url 
											 parameters:nil requestMethod:TWRequestMethodGET];
	
	// Attach the account object to this request
	[request setAccount:account];
	
	[request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
		
		if (!responseData) {
			
			// inspect the contents of error 
			NSLog(@"%@", error);
		} 
		
		else {
			
			NSError *jsonError;
			NSArray *idsArray = [[NSJSONSerialization JSONObjectWithData:responseData 
																options:NSJSONReadingMutableLeaves 
																  error:&jsonError] objectForKey:@"ids"];            
			if (idsArray) {                          
				
				// Now format these user_ids and pass
				// them to Twitter (using users/lookup) to get
				// the usernames
				//NSLog(@"TIMELINE:%@", idsArray);
				
				NSString *userIDs = [idsArray componentsJoinedByString:@","];
				
				[self initUsersLookupAPI:userIDs withAccount:self.selectedAccount];
			} 
			
			else { 
				
				// inspect the contents of jsonError
				NSLog(@"%@", jsonError);
			}
		}
	}];
}


- (void)initUsersLookupAPI:(NSString *)userIDs withAccount:(ACAccount *)account {
	
	NSString *user_ids_str_enc = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,(CFStringRef)userIDs,NULL,CFSTR(","),kCFStringEncodingUTF8);
	
	NSString *urlStr = [NSString stringWithFormat:@"https://api.twitter.com/1.1/users/lookup.json?user_id=%@&include_entities=false", user_ids_str_enc];

	//  Next, we create an URL that points to the target endpoint
	NSURL *url = [NSURL URLWithString:urlStr];
	
	NSLog(@"url:%@", [url description]);
	
	//  Now we can create our request.  Note that we are performing a GET request.
	TWRequest *request = [[TWRequest alloc] initWithURL:url 
											 parameters:nil requestMethod:TWRequestMethodPOST];
	
	NSLog(@"SELECTED ACCOUNT:%@", account);
	
	// Attach the account object to this request
	[request setAccount:account];
	
	[request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
		
		if (!responseData) {
			
			// inspect the contents of error 
			NSLog(@"%@", error);
		} 
		
		else {
			
			NSError *jsonError;
			NSArray *timeline = [NSJSONSerialization JSONObjectWithData:responseData 
																options:NSJSONReadingMutableLeaves 
																  error:&jsonError];            
			if (timeline) {                          
				
				// Now format these user_ids and pass
				// them to Twitter (using users/lookup) to get
				// the usernames
				NSLog(@"LOOKUP TIMELINE:%@", timeline);
			} 
			else { 
				// inspect the contents of jsonError
				NSLog(@"%@", jsonError);
			}
		}
	}];
}
	 
	 
- (void)initFollowAPI:(NSString *)followingUsername {
 
	NSString *postString = [NSString stringWithFormat:@"following=%@&follower=%@&token=%@", followingUsername, [self appDelegate].loggedInUsername, [self appDelegate].sessionToken];

	NSData *postData = [NSData dataWithBytes:[postString UTF8String] length:[postString length]];

	// Create the URL that will be used to authenticate this user
	NSString *methodName = @"Follow";	
	NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];

	// Initialiase the URL Request
	NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:postData];

	// HTTPFetcher
	followFetcher = [[HTTPFetcher alloc] initWithURLRequest:request
												receiver:self
												  action:@selector(receivedFollowResponse:)];
	[followFetcher start];
}


// Example fetcher response handling
- (void)receivedFollowResponse:(HTTPFetcher *)aFetcher {
 
	HTTPFetcher *theJSONFetcher = (HTTPFetcher *)aFetcher;

	//NSLog(@"DETAILS:%@",[[NSString alloc] initWithData:theJSONFetcher.data encoding:NSASCIIStringEncoding]);

	NSAssert(aFetcher == followFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");

	BOOL success = NO;
	NSInteger statusCode = [theJSONFetcher statusCode];

	if ([theJSONFetcher.data length] > 0 && statusCode == 200) {
	 
		// Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];

		// Create a dictionary from the JSON string
		NSDictionary *results = [jsonString objectFromJSONString];

		if ([[results objectForKey:@"result"] isEqualToString:@"ok"]) success = YES;

		NSLog(@"FOLLOW jsonString:%@", jsonString);

//		[jsonString release];
	}

	// Follow API was successful
	if (success) {
	 
		
	}

//	[followFetcher release];
	followFetcher = nil;
}


- (void)initUnfollowAPI:(NSString *)followingUsername {
	
	NSString *postString = [NSString stringWithFormat:@"following=%@&follower=%@&token=%@", followingUsername, [self appDelegate].loggedInUsername, [self appDelegate].sessionToken];
	
	NSData *postData = [NSData dataWithBytes:[postString UTF8String] length:[postString length]];
	
	// Create the URL that will be used to authenticate this user
	NSString *methodName = @"Unfollow";	
	NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];
	
	// Initialiase the URL Request
	NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:postData];
	
	// HTTPFetcher
	unfollowFetcher = [[HTTPFetcher alloc] initWithURLRequest:request
													 receiver:self
													   action:@selector(receivedUnfollowResponse:)];
	[unfollowFetcher start];
}


// Example fetcher response handling
- (void)receivedUnfollowResponse:(HTTPFetcher *)aFetcher {
    
    HTTPFetcher *theJSONFetcher = (HTTPFetcher *)aFetcher;
	
	//NSLog(@"DETAILS:%@",[[NSString alloc] initWithData:theJSONFetcher.data encoding:NSASCIIStringEncoding]);
    
	NSAssert(aFetcher == unfollowFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");	
	
	BOOL success = NO;
	NSInteger statusCode = [theJSONFetcher statusCode];
	
	if ([theJSONFetcher.data length] > 0 && statusCode == 200) {
		
		// Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		
		// Create a dictionary from the JSON string
		NSDictionary *results = [jsonString objectFromJSONString];
		
		if ([[results objectForKey:@"result"] isEqualToString:@"ok"]) success = YES;
		
		NSLog(@"UNFOLLOW jsonString:%@", jsonString);
		
//		[jsonString release];
	}
	
	// Follow API was successful
	if (success) {
		
		
	}
	
//	[unfollowFetcher release];
	unfollowFetcher = nil;
}	 


- (IBAction)goBack:(id)sender {

    [self.navigationController popViewControllerAnimated:YES];
}


@end
