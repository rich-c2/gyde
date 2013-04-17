//
//  MyMapAnnotation.m
//  ATM Locator
//
//  Created by Richard Lee on 12/10/09.
//  Copyright 2009 C2 Media Pty Ltd. All rights reserved.
//

#import "MyMapAnnotation.h"
#import <MapKit/MapKit.h>

@implementation MyMapAnnotation

@synthesize coordinate;
@synthesize url = _url;
@synthesize locationAddress;
@synthesize locationID = _locationID;


- (id)initWithCoordinate:(CLLocationCoordinate2D)coord title:(NSString*)title {
	
	self = [super init];
	coordinate = coord;
	_title      = title;
	
	return self;
}


- (NSString *)title {
	
	return _title;
}


- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate
{
    coordinate=newCoordinate;
}


@end
