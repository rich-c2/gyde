//
//  TAMapView.m
//  Tourism App
//
//  Created by Richard Lee on 27/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TAMapView.h"
#import "MyMapAnnotation.h"

@implementation TAMapView

@synthesize map;

- (id)initWithFrame:(CGRect)frame latitude:(NSNumber *)latitude longitude:(NSNumber *)longitude {
	
    self = [super initWithFrame:frame];
	
    if (self) {
        
		MKMapView *tempMap = [[MKMapView alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, frame.size.height)];
		[tempMap setMapType:MKMapTypeStandard];
		
		self.map = tempMap;
		
		[self addSubview:self.map];
		
		[self initSingleLocation:latitude longitude:longitude];
    }
	
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


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
			[pinView setCanShowCallout:YES];
		}
	}
	
	return pinView;
}


#pragma MY-METHODS 

- (void)initSingleLocation:(NSNumber *)latitude longitude:(NSNumber *)longitude  {
	
	// Map type
	self.map.mapType = MKMapTypeStandard;
	
	/*Region and Zoom*/
	MKCoordinateRegion region;
	MKCoordinateSpan span;
	span.latitudeDelta = 0.0006;
	span.longitudeDelta = 0.0006;
	
	CLLocationCoordinate2D coordLocation;
	coordLocation.latitude = [latitude doubleValue];
	coordLocation.longitude = [longitude doubleValue];
	region.span = span;
	region.center = coordLocation;
	
	[self.map setRegion:region animated:TRUE];
	[self.map regionThatFits:region];
	
	NSString *title = @"Test pin";
	
	MyMapAnnotation *mapAnnotation = [[MyMapAnnotation alloc] initWithCoordinate:coordLocation title:title];
	[self.map addAnnotation:mapAnnotation];
}




@end
