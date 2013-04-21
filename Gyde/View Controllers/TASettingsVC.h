
//
//  TASettingsVC.h
//  Tourism App
//
//  Created by Richard Lee on 3/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "TACitiesListVC.h"

@class HTTPFetcher;

@interface TASettingsVC : UIViewController <CitiesDelegate, MFMailComposeViewControllerDelegate> {

	NSMutableDictionary *menuDictionary;
	NSArray *keys;
	
	IBOutlet UITableView *settingsTable;
	
	HTTPFetcher *profileFetcher;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, retain) NSMutableDictionary *icons;
@property (nonatomic, retain) NSMutableDictionary *menuDictionary;
@property (nonatomic, retain) NSArray *keys;

@property (nonatomic, retain) IBOutlet UITableView *settingsTable;

@end
