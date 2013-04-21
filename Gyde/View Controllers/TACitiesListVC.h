//
//  TACitiesListVC.h
//  Tourism App
//
//  Created by Richard Lee on 30/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreLocation/CoreLocation.h"

@class HTTPFetcher;
@class MyCoreLocation;
@class XMLFetcher;
@class City;

@protocol CitiesDelegate

- (void)locationSelected:(City *)city;

@end

@interface TACitiesListVC : UIViewController {
	
	UIButton *setBtn;
	IBOutlet UIButton *locateBtn;

	id <CitiesDelegate> delegate;
		
	HTTPFetcher *citiesFetcher;
	
	BOOL loading;
	BOOL citiesLoaded;
		
	IBOutlet UITextField *searchField;
	IBOutlet UITableView *citiesTable;
	NSArray *cities;
	City *selectedCity;
	
	XMLFetcher *cityFetcher;
	MyCoreLocation *locationManager;
	CLLocation *currentLocation;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, retain) UIButton *setBtn;
@property (nonatomic, retain) IBOutlet UIButton *locateBtn;

@property (nonatomic, retain) id <CitiesDelegate> delegate;

@property (nonatomic, retain) IBOutlet UITextField *searchField;
@property (nonatomic, retain) IBOutlet UITableView *citiesTable;
@property (nonatomic, retain) NSArray *cities;
@property (nonatomic, retain) City *selectedCity;

@property (nonatomic, retain) MyCoreLocation *locationManager;
@property (nonatomic, retain) CLLocation *currentLocation;

- (IBAction)setButtonTapped:(id)sender;

@end
