//
//  TAFriendsVC.h
//  Tourism App
//
//  Created by Richard Lee on 4/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>
#import <MessageUI/MessageUI.h>

@interface TAFriendsVC : UIViewController <ABPeoplePickerNavigationControllerDelegate, ABPersonViewControllerDelegate, MFMailComposeViewControllerDelegate> {

	IBOutlet UITableView *friendsTable;
	NSArray *tableContent;
}

@property (nonatomic, retain) IBOutlet UITableView *friendsTable;
@property (nonatomic, retain) NSArray *tableContent;

@end
