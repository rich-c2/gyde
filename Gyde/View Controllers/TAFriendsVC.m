//
//  TAFriendsVC.m
//  Tourism App
//
//  Created by Richard Lee on 4/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TAFriendsVC.h"
#import "TAUsersVC.h"
#import <MessageUI/MessageUI.h>

@interface TAFriendsVC ()

@end

@implementation TAFriendsVC

@synthesize friendsTable, tableContent;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	
    if (self) {
        self.title = @"Find friends";
    }
    return self;
}

- (void)viewDidLoad {
	
    [super viewDidLoad];
    
	//self.tableContent = [NSArray arrayWithObjects:@"Find friends via Twitter", @"Find friends via FB", @"Invite friends", @"Search users", nil];
	
	self.tableContent = [NSArray arrayWithObjects:@"Find friends in my contacts", @"Twitter friends", @"Invite via twitter", @"Invite via email",  @"Search users", nil];

}


#pragma mark - Private Methods
- (AppDelegate *)appDelegate {
	
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}


- (void)viewDidUnload {
	
	self.tableContent = nil;
    friendsTable = nil;
	
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



#pragma mark MFMailComposeViewControllerDelegate

// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {	
    
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


#pragma ABPersonViewControllerDelegate methods

- (BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifierForValue {
	
	return YES;
}


#pragma ABPeoplePickerNavigationControllerDelegate

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person 
                                property:(ABPropertyID)property
                              identifier:(ABMultiValueIdentifier)identifier {
	
    
	if (property == kABPersonEmailProperty) {
		
		NSArray *emails = (__bridge NSArray *)ABRecordCopyValue(person, property);
		NSString *emailAddress = (__bridge NSString *)ABMultiValueCopyValueAtIndex((__bridge ABMultiValueRef)(emails), 0);
		
		// Email message here
		MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
		picker.mailComposeDelegate = self;
		
		// SUBJECT
		[picker setSubject:@"I found this great app you'd love..."];
		
		// TO ADDRESS...
		NSArray *recipients = [[NSArray alloc] initWithObjects:emailAddress, nil];
		[picker setToRecipients:recipients];
		
		// BODY TEXT
		NSString *bodyContent = @"You should check out the Tourism App. Just click the link below to download it.";
		NSString *emailBody = [NSString stringWithFormat:@"%@\n\n", bodyContent];
		[picker setMessageBody:emailBody isHTML:NO];
		
		[self dismissModalViewControllerAnimated:NO];
		
		// SHOW INTERFACE
		[self presentModalViewController:picker animated:YES];
	}
	
    return NO;
}


- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person {
	
	[peoplePicker setDisplayedProperties:[NSArray arrayWithObjects:[NSNumber numberWithInt:kABPersonPhoneProperty], [NSNumber numberWithInt:kABPersonEmailProperty], nil]];
	
	return YES;
}


/*
 */


- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {

	[self dismissModalViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	    
    return [self.tableContent count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	static NSString *CellIdentifier = @"Cell";
	
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
    if (cell == nil) {
		
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
	
	[self configureCell:cell atIndexPath:indexPath tableView:tableView];
	
    return cell;
}


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView {
	
	// Retrieve City from cities array
	NSString *cellTitle = [self.tableContent objectAtIndex:[indexPath row]]; 
	
	// Set the text of the cell
	cell.textLabel.text = cellTitle;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSString *cellTitle = [self.tableContent objectAtIndex:[indexPath row]];
	
	[NSArray arrayWithObjects:@"Find friends in my contacts", @"Twitter friends", @"Invite via twitter", @"Invite via email",  @"Search users", nil];
	
	// CONTACTS LIST
	if ([cellTitle isEqualToString:@"Find friends in my contacts"]) {
	
		TAUsersVC *usersVC = [[TAUsersVC alloc] initWithNibName:@"TAUsersVC" bundle:nil];
		[usersVC setUsersMode:UsersModeFindViaContacts];
		[usersVC setSelectedUsername:[self appDelegate].loggedInUsername];
		
		[self.navigationController pushViewController:usersVC animated:YES];
	}
	
	else if ([cellTitle isEqualToString:@"Twitter friends"]) { 
	
		TAUsersVC *usersVC = [[TAUsersVC alloc] initWithNibName:@"TAUsersVC" bundle:nil];
		[usersVC setUsersMode:UsersModeFindViaTwitter];
		
		[self.navigationController pushViewController:usersVC animated:YES];
	}
	
	else if ([cellTitle isEqualToString:@"Invite via twitter"]) { 
		
		TAUsersVC *usersVC = [[TAUsersVC alloc] initWithNibName:@"TAUsersVC" bundle:nil];
		[usersVC setUsersMode:UsersModeInviteViaTwitter];
		
		[self.navigationController pushViewController:usersVC animated:YES];
	}
	
	else if ([cellTitle isEqualToString:@"Invite via email"]) { 
		
		ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
		picker.peoplePickerDelegate = self;   
		
		[self presentModalViewController:picker animated:YES];
	}
	
	// SEARCH USERS
	else if ([cellTitle isEqualToString:@"Search users"]) {
		
		TAUsersVC *usersVC = [[TAUsersVC alloc] initWithNibName:@"TAUsersVC" bundle:nil];
		[usersVC setUsersMode:UsersModeSearchUsers];
		[usersVC setSelectedUsername:[self appDelegate].loggedInUsername];
		
		[self.navigationController pushViewController:usersVC animated:YES];
	}
}



@end
