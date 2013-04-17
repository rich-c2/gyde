//
//  TAMapItVC.h
//  Tourism App
//
//  Created by Richard Lee on 3/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "TAPlacesVC.h"
#import "RLNoteView.h"

@interface TAMapItVC : UIViewController {

	id <PlacesDelegate> delegate;
	
	NSString *address;
	NSString *city;
	NSString *state;
	NSString *postalCode;
	NSString *country;
	
	IBOutlet UITextField *titleField;
	IBOutlet UILabel *addressLabel;
	IBOutlet MKMapView *map;
	CLLocation *currentLocation;
}

@property (nonatomic, retain) id <PlacesDelegate> delegate;

@property (nonatomic, retain) NSString *address;
@property (nonatomic, retain) NSString *city;
@property (nonatomic, retain) NSString *state;
@property (nonatomic, retain) NSString *postalCode;
@property (nonatomic, retain) NSString *country;

@property (retain, nonatomic) IBOutlet UIImageView *addressBackground;


@property (nonatomic, retain) IBOutlet UITextField *titleField;
@property (nonatomic, retain) IBOutlet UILabel *addressLabel;
@property (nonatomic, retain) IBOutlet MKMapView *map;
@property (nonatomic, retain) CLLocation *currentLocation;

@property (nonatomic, retain) IBOutlet RLNoteView *tipView;

- (IBAction)goBack:(id)sender;
- (IBAction)saveLocation:(id)sender;

@end
