//
//  TARegisterVC.h
//  Tourism App
//
//  Created by Richard Lee on 10/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TACitiesListVC.h"
#import "GydeScrollViewController.h"

@class HTTPFetcher;

@interface TARegisterVC : GydeScrollViewController <UIScrollViewDelegate, CitiesDelegate> {
	
	HTTPFetcher *registerFetcher;

	IBOutlet UITextField *nameField;
	IBOutlet UITextField *emailField;
	IBOutlet UITextField *usernameField;
	IBOutlet UITextField *passwordField;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, retain) IBOutlet UITextField *nameField;
@property (nonatomic, retain) IBOutlet UITextField *emailField;
@property (nonatomic, retain) IBOutlet UITextField *usernameField;
@property (nonatomic, retain) IBOutlet UITextField *passwordField;
@property (retain, nonatomic) IBOutlet UILabel *cityLabel;
@property (nonatomic, assign) BOOL citySelected;

- (IBAction)goBack:(id)sender;



@end
