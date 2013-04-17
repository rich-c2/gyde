//
//  TAMyContentVC.h
//  Tourism App
//
//  Created by Richard Lee on 28/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TAMyContentVC : UIViewController {

	NSString *username;
	NSArray *menuItems;
	IBOutlet UITableView *menuTable;
}

@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSArray *menuItems;
@property (nonatomic, retain) IBOutlet UITableView *menuTable;

@end
