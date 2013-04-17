//
//  TAMapVC.h
//  Tourism App
//
//  Created by Richard Lee on 29/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

typedef enum {
	MapModeSingle = 0,
	MapModeMultiple = 1,
    MapModeMultipleAnnotations = 2
} MapMode;


@protocol ModalMapDelegate

- (void)mapCloseButtonWasTapped;

@end

@interface TAMapVC : UIViewController {
	
	MapMode mapMode;
    
    BOOL mapLoaded;

	NSDictionary *locationData;
	NSArray *photos;
    NSArray *mapAnnotations;
	
	IBOutlet MKMapView *map;
}

@property MapMode mapMode;

@property (nonatomic, retain) id <ModalMapDelegate> delegate;

@property (nonatomic, strong) Photo *photo;

@property (nonatomic, retain) IBOutlet MKMapView *map;
@property (retain, nonatomic) IBOutlet UIButton *closeBtn;
@property (retain, nonatomic) IBOutlet UIButton *backBtn;
@property (retain, nonatomic) IBOutlet UILabel *addressLabel;

@property (nonatomic, retain) NSDictionary *locationData;
@property (nonatomic, retain) NSArray *photos;
@property (nonatomic, retain) NSArray *mapAnnotations;

- (IBAction)closeButtonTapped:(id)sender;

@end
