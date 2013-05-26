//
//  MyCoreLocation.m
//  Telstra OSS Mobile Inventory
//
//  Created by Muliawan Sjarif on 20/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MyCoreLocation.h"

@implementation MyCoreLocation

@synthesize locationManager, caller, updating;

- (id)init {
	
    self = [super init];
    if (self) {
		
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
		self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
	
		updating = NO;
		showErrors = NO;
    }
    
    return self;
}


- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {
    
    CLLocation *latestLocation = [locations lastObject];
	
	if (latestLocation.horizontalAccuracy <= 100) {
		
		updating = NO;
	
		[self.locationManager stopUpdatingLocation];
		
		if ([(NSObject *)self.caller respondsToSelector:@selector(updateLocationDidFinish:)])
			[(NSObject *)self.caller performSelector:@selector(updateLocationDidFinish:) withObject:latestLocation];
	}
}


- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    
    [self.locationManager stopUpdatingLocation];
    
	if (showErrors) {
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Error" 
														message:[error description]
													   delegate:nil 
											  cancelButtonTitle:@"Close" 
											  otherButtonTitles:nil, nil];
		[alert show];
	}
    
    else {
        
        if ([(NSObject *)self.caller respondsToSelector:@selector(updateLocationDidFailWithError:)])
            [(NSObject *)self.caller performSelector:@selector(updateLocationDidFailWithError:) withObject:error];
    }
}


- (void)startUpdating {

	[self.locationManager startUpdatingLocation];
	
	updating = YES;
}


- (void)stopUpdating {
	
	updating = NO;
	
	[self.locationManager stopUpdatingLocation];
}


@end
