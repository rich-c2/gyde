//
//  TAMapItVC.m
//  Tourism App
//
//  Created by Richard Lee on 3/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TAMapItVC.h"
#import "MyMapAnnotation.h"

@interface TAMapItVC ()

@end

@implementation TAMapItVC

@synthesize map, currentLocation, delegate, addressLabel, titleField;
@synthesize address, city, state, postalCode, country, tipView;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
	
    [super viewDidLoad];
    
    self.navigationItem.title = @"MAP IT";
    
    UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [saveBtn setImage:[UIImage imageNamed:@"nav-bar-save-button.png"] forState:UIControlStateNormal];
    [saveBtn setImage:[UIImage imageNamed:@"nav-bar-save-button-on.png"] forState:UIControlStateHighlighted];
    [saveBtn setFrame:CGRectMake(0, 0, 54, 27)];
    [saveBtn addTarget:self action:@selector(saveLocation:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *saveBtnItem = [[UIBarButtonItem alloc] initWithCustomView:saveBtn];
    self.navigationItem.rightBarButtonItem = saveBtnItem;
    
    // Hide the note view
    [self.tipView hideTipViewWithAnimation:NO completionBlock:^(BOOL finished){}];
    
    // Place tiled bg for image view behind
    // the address label
    self.addressBackground.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"map-it-address-tile-bg.png"]]; 
	
	[self initMapView];
}

- (void)viewDidUnload {
	
	self.address = nil; 
	self.city = nil; 
	self.state = nil; 
	self.postalCode = nil;
	self.country = nil;
	
    self.map = nil;
	self.currentLocation = nil;
	self.titleField = nil;
	
    self.tipView = nil;
    self.addressLabel = nil;
	
    [self setAddressBackground:nil];
    [super viewDidUnload];
 }

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewWillAppear:(BOOL)animated {
    
    // Show the note view
    [self.tipView showTipViewWithAnimation:YES completionBlock:^(BOOL finished){
    
        [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(hideTipView) userInfo:nil repeats:NO];
    }];

    [super viewWillAppear:animated];
}

- (void)hideTipView {

    // Hide the note view
    [self.tipView hideTipViewWithAnimation:YES completionBlock:^(BOOL finished){}];
}


#pragma mark - UITextField delegations
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	
	// Hide keyboard
	[textField resignFirstResponder];
    
    return YES;
}


#pragma MKMapViewDelegate methods

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
	
    if ([annotation isKindOfClass:[MKUserLocation class]])
		return nil;		
	
	static NSString * const kPinAnnotationIdentifier = @"PinIdentifier";
	
	MKPinAnnotationView* pinView;
	
    if ([annotation isKindOfClass:[MyMapAnnotation class]]) {
		
		// try to dequeue an existing pin view first
        static NSString* annotationIdentifier = @"annotationIdentifier";
        pinView = (MKPinAnnotationView *)
		[self.map dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
		
		if (!pinView) {
			
			pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:kPinAnnotationIdentifier];
			
			[pinView setUserInteractionEnabled:YES];
			[pinView setSelected:YES];
			[pinView setCanShowCallout:NO];
			[pinView setDraggable:YES];
		}
	}
	
	return pinView;
}


- (void)mapView:(MKMapView *)mapView 
 annotationView:(MKAnnotationView *)annotationView 
didChangeDragState:(MKAnnotationViewDragState)newState 
   fromOldState:(MKAnnotationViewDragState)oldState  {
	
	if (oldState == MKAnnotationViewDragStateDragging) {
		
		CLLocationCoordinate2D droppedAt = annotationView.annotation.coordinate;
        NSLog(@"dragging at %f,%f", droppedAt.latitude, droppedAt.longitude);
    }
	
    if (newState == MKAnnotationViewDragStateEnding) {
		
        CLLocationCoordinate2D droppedAt = annotationView.annotation.coordinate;
        NSLog(@"dropped at %f,%f", droppedAt.latitude, droppedAt.longitude);
		
		CLLocation *newLocation = [[CLLocation alloc] initWithLatitude:droppedAt.latitude longitude:droppedAt.longitude];
		
		self.currentLocation = newLocation;
		
		// Update street address label
		[self updateAddress];
    }
}


- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
	
	NSLog(@"didSelectAnnotationView");
}


- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
	
	NSLog(@"DESELECT");
}


/*	The MKMapView has been 'created' in IB but this function formats 
 the region of the map, what it is centered around, zoom level etc. 
 It also calls the placeStore function. */
- (void)initMapView {
	
	// Map type
	self.map.mapType = MKMapTypeStandard;
	
	/*Region and Zoom*/
	MKCoordinateRegion region;
	MKCoordinateSpan span;
	span.latitudeDelta = 0.0006;
	span.longitudeDelta = 0.0006;
	
	CLLocationCoordinate2D coordLocation;
	coordLocation.latitude = self.currentLocation.coordinate.latitude;
	coordLocation.longitude = self.currentLocation.coordinate.longitude;
	region.span = span;
	region.center = coordLocation;
	
	[self.map setRegion:region animated:TRUE];
	[self.map regionThatFits:region];
	
	NSString *title = @"Photo location";
	
	MyMapAnnotation *mapAnnotation = [[MyMapAnnotation alloc] initWithCoordinate:self.currentLocation.coordinate title:title];
	[self.map addAnnotation:mapAnnotation];	
	
	// Update street address label
	[self updateAddress];
}


- (IBAction)saveLocation:(id)sender {
	
	if ([self.titleField.text length] > 0) {
		
		NSNumber *latNum = [NSNumber numberWithDouble:self.currentLocation.coordinate.latitude];
		NSNumber *lngNum = [NSNumber numberWithDouble:self.currentLocation.coordinate.longitude];
		
		NSDictionary *locationData = [NSDictionary dictionaryWithObjectsAndKeys:self.address, @"address", self.city, @"city", self.state, @"state", self.country, @"country", self.postalCode, @"postalCode", latNum, @"lat", lngNum, @"lng", nil];
		
		NSMutableDictionary *newPlaceData = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.titleField.text, @"name", locationData, @"location", @"0", @"verified", nil];

		// Pass the location that the user has selected
		// onto the delegate, and pop back to the share VC
		[self.delegate locationMapped:newPlaceData];
		
		NSArray *viewControllers = [self.navigationController viewControllers];
		UIViewController *shareVC = [viewControllers objectAtIndex:([viewControllers count] - 3)];
		
		[self.navigationController popToViewController:shareVC animated:YES];
	}
	
	else {
		
		UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Sorry!" message:@"You must enter a title for the place location you're plotting before proceeding." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
		[av show];
	}
}


- (void)updateAddress {

	CLGeocoder *geocoder = [[CLGeocoder alloc] init];
	[geocoder reverseGeocodeLocation:self.currentLocation completionHandler:^(NSArray *placemarks, NSError *error)
	 {
		 
		 if(placemarks && placemarks.count > 0) {
			 
			 CLPlacemark *topResult = [placemarks objectAtIndex:0];
             
			 NSString *subThoroughFare;
             NSString *thoroughFare;
             
             
             if (!([[topResult subThoroughfare] isEqual:[NSNull null]]) && [[topResult subThoroughfare] length] > 0)
                 subThoroughFare = [NSString stringWithFormat:@"%@ ", [topResult subThoroughfare]];
             else subThoroughFare = @"";
             
             if (!([[topResult thoroughfare] isEqual:[NSNull null]]) && [[topResult thoroughfare] length] > 0)
                 thoroughFare = [NSString stringWithFormat:@"%@", [topResult thoroughfare]];
             else thoroughFare = @"";
             
             
             self.address = [NSString stringWithFormat:@"%@%@", subThoroughFare, thoroughFare];
             
             
             
             if (!([[topResult subLocality] isEqual:[NSNull null]]) && [[topResult subLocality] length] > 0)
                 self.city = [topResult subLocality];
             else self.city = @"";
             
             
             if (!([[topResult administrativeArea] isEqual:[NSNull null]]) && [[topResult administrativeArea] length] > 0)
                 self.state = [topResult administrativeArea];
             else self.state = @"";
             
             
             if (!([[topResult postalCode] isEqual:[NSNull null]]) && [[topResult postalCode] length] > 0)
                 self.postalCode = [topResult postalCode];
             else self.postalCode = @"";
             
             
             if (!([[topResult country] isEqual:[NSNull null]]) && [[topResult country] length] > 0)
                 self.country = [topResult country];
             else self.country = @"";
             
			 
			 // Update the label at the bottom of the mapContainer to display the latest fetched address
			 NSString *locationAddress = [NSString stringWithFormat:@"%@ %@ %@ %@", self.address, self.city, self.state, self.postalCode];
			 
			 if ([locationAddress length] > 0) self.addressLabel.text = locationAddress;
             
             CGFloat maxWidth = 270;
             CGFloat maxHeight = 35.0;
             CGSize maxSize = CGSizeMake(maxWidth, maxHeight);
             CGSize addressStringSize = [locationAddress sizeWithFont:self.addressLabel.font
                                            constrainedToSize:maxSize
                                                lineBreakMode:self.addressLabel.lineBreakMode];
             
             CGRect addressFrame = CGRectMake(self.addressLabel.frame.origin.x, self.addressLabel.frame.origin.y, addressStringSize.width, addressStringSize.height);
             
             self.addressLabel.frame = addressFrame;

		 }
	 }];
}


- (IBAction)goBack:(id)sender {

    [self.navigationController popViewControllerAnimated:YES];
}


@end
