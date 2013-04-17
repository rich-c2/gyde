//
//  TAPlacesVC.h
//  Tourism App
//
//  Created by Richard Lee on 3/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreLocation/CoreLocation.h"
#import <MapKit/MapKit.h>
#import "RLNoteView.h"

@class HTTPFetcher;

@protocol PlacesDelegate

@optional

- (void)placeSelected:(NSMutableDictionary *)placeData;

- (void)locationMapped:(NSMutableDictionary *)newPlaceData;

@end

@interface TAPlacesVC : UIViewController {
	
	id <PlacesDelegate> delegate;
	
	BOOL loading;
	BOOL venuesLoaded;

	HTTPFetcher *venuesFetcher;
	
	NSMutableArray *places;
	NSNumber *latitude;
	NSNumber *longitude;
	
	IBOutlet UITableView *placesTable;
	IBOutlet UIButton *mapItBtn;
}

@property (nonatomic, retain) id <PlacesDelegate> delegate;

@property (nonatomic, retain) NSMutableArray *places;
@property (nonatomic, retain) NSNumber *latitude;
@property (nonatomic, retain) NSNumber *longitude;

@property (retain, nonatomic) IBOutlet MKMapView *placesMap;

@property (retain, nonatomic) IBOutlet UIView *loadingView;
@property (nonatomic, retain) IBOutlet RLNoteView *tipView;

@property (nonatomic, retain) IBOutlet UITableView *placesTable;
@property (nonatomic, retain) IBOutlet UIButton *mapItBtn;

- (IBAction)mapItButtonTapped:(id)sender;
- (IBAction)goBack:(id)sender;

@end
