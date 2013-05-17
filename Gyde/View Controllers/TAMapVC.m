//
//  TAMapVC.m
//  Tourism App
//
//  Created by Richard Lee on 29/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TAMapVC.h"
#import "MyMapAnnotation.h"
#import "TAScrollVC.h"

#define BOTTOM_SHADOW_TAG 8000
#define ADDRESS_VIEW_TAG 1000

@interface TAMapVC ()

@end

@implementation TAMapVC

@synthesize map, mapMode, locationData, photos, mapAnnotations;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
	
    [super viewDidLoad];
    
    self.title = @"MAP";
    self.navigationController.navigationBarHidden = NO;
    
    // Hide the back button and
    // show the close button if this
    // is being viewed modally
    if (self.delegate) {
    
        [self.backBtn setHidden:YES];
        [self.closeBtn setHidden:NO];
                
        UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeBtn setImage:[UIImage imageNamed:@"nav-photo-details-close-button.png"] forState:UIControlStateNormal];
        [closeBtn setImage:[UIImage imageNamed:@"nav-photo-details-close-button-on.png"] forState:UIControlStateHighlighted];
        [closeBtn setFrame:CGRectMake(267, 0, 43, 27)];
        [closeBtn addTarget:self action:@selector(closeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *closeButtonItem = [[UIBarButtonItem alloc] initWithCustomView:closeBtn];
        
        self.navigationItem.rightBarButtonItem = closeButtonItem;
        
        // Hide the bottom shadow image view
        UIImageView *shadow = (UIImageView *)[self.view viewWithTag:BOTTOM_SHADOW_TAG];
        CGRect newFrame = shadow.frame;
        newFrame.origin.y = 460 - newFrame.size.height;
        [shadow setFrame:newFrame];
    }
}

- (void)viewDidUnload {
	
	self.photos = nil;
	self.locationData = nil; 
	self.mapAnnotations = nil;
    self.map = nil;
	
    [self setCloseBtn:nil];
    [self setBackBtn:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)viewWillAppear:(BOOL)animated {

	[super viewWillAppear:animated];
    
    if (!mapLoaded) {
	
        if (self.mapMode == MapModeSingle) {
            
            [self initSingleLocation];
            [self updateAddress];
        }
            
        else if (self.mapMode == MapModeMultiple) {
            
            [self initMapLocations];
            UIView *addressView = (UIView *)[self.view viewWithTag:ADDRESS_VIEW_TAG];
            addressView.hidden = YES;
            
            CGRect newFrame = self.map.frame;
            newFrame.size.height += addressView.frame.size.height;
            self.map.frame = newFrame;
        }
        
        else if (self.mapMode == MapModeMultipleAnnotations) {
            
            [self initMapAnnotations];
            UIView *addressView = (UIView *)[self.view viewWithTag:ADDRESS_VIEW_TAG];
            addressView.hidden = YES;
            
            CGRect newFrame = self.map.frame;
            newFrame.size.height += addressView.frame.size.height;
            self.map.frame = newFrame;
        }
    }
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
            
			pinView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];

			[pinView setUserInteractionEnabled:YES];
			[pinView setCanShowCallout:YES];
		}
	}
	
	return pinView;
}


- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view
        calloutAccessoryControlTapped:(UIControl *)control {

    MyMapAnnotation *selectedAnnotation = (MyMapAnnotation *)view.annotation;
        
    TAScrollVC *scrollVC = [[TAScrollVC alloc] initWithNibName:@"TAScrollVC" bundle:nil];
    [scrollVC setPhotosMode:PhotosModeSinglePhoto];
    [scrollVC setSelectedPhotoID:selectedAnnotation.locationID];
    
    [self.navigationController pushViewController:scrollVC animated:YES];
}


#pragma MY-METHODS 

- (IBAction)goBack:(id)sender {

    [self.navigationController popViewControllerAnimated:YES];
}


- (void)initSingleLocation {
	
	/*Region and Zoom*/
	MKCoordinateRegion region;
	MKCoordinateSpan span;
	span.latitudeDelta = 0.0006;
	span.longitudeDelta = 0.0006;
	
	CLLocationCoordinate2D coordLocation;
	coordLocation.latitude = [[self.locationData objectForKey:@"latitude"] doubleValue];
	coordLocation.longitude = [[self.locationData objectForKey:@"longitude"] doubleValue];
	region.span = span;
	region.center = coordLocation;
	
	[self.map setRegion:region animated:TRUE];
	[self.map regionThatFits:region];
	
	NSString *title = self.photo.venue.title;
	
	MyMapAnnotation *mapAnnotation = [[MyMapAnnotation alloc] initWithCoordinate:coordLocation title:title];
    mapAnnotation.locationID = self.photo.photoID;
	[self.map addAnnotation:mapAnnotation];
    
    mapLoaded = YES;
}


- (void)initMapLocations {
	
	/*Region and Zoom*/
	MKCoordinateRegion region;
	MKCoordinateSpan span;
	span.latitudeDelta = 0.09;
	span.longitudeDelta = 0.09;

	for (int i = 0; i < [self.photos count]; i++) {
		
		Photo *photo = [self.photos objectAtIndex:i];
		
		CLLocationCoordinate2D coordLocation;
		coordLocation.latitude = [photo.latitude doubleValue];
		coordLocation.longitude = [photo.longitude doubleValue];
		
		if (i == 0) {
		
			region.span = span;
			region.center = coordLocation;
			
			[self.map setRegion:region animated:TRUE];
			[self.map regionThatFits:region];
		}
	
		NSString *title = photo.venue.title;
		if ([title length] == 0) title = @"[untitled]";
		
		MyMapAnnotation *mapAnnotation = [[MyMapAnnotation alloc] initWithCoordinate:coordLocation title:title];
        [mapAnnotation setLocationID:[photo photoID]];
        
		[self.map addAnnotation:mapAnnotation];
	}
    
    mapLoaded = YES;
}


- (void)initMapAnnotations {
	
	/*Region and Zoom*/
	MKCoordinateRegion region;
	MKCoordinateSpan span;
	span.latitudeDelta = 0.09;
	span.longitudeDelta = 0.09;
        
	for (int i = 0; i < [self.mapAnnotations count]; i++) {
		
        MyMapAnnotation *mapAnnotation = [self.mapAnnotations objectAtIndex:i];
        
		if (i == 0) {
            
			region.span = span;
            region.center = mapAnnotation.coordinate;
			
			[self.map setRegion:region animated:TRUE];
			[self.map regionThatFits:region];
		}
        
		[self.map addAnnotation:mapAnnotation];
	}
    
    mapLoaded = YES;
}


- (IBAction)closeButtonTapped:(id)sender; {
    
    [self.delegate mapCloseButtonWasTapped];
}

- (void)updateAddress {

    // Update the label at the bottom of the mapContainer to display the latest fetched address
    NSString *locationAddress = self.photo.venue.address;
    
    if ([locationAddress isEqualToString:@"<null>"] || locationAddress.length == 0)
        locationAddress = @"-";
    
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


@end
