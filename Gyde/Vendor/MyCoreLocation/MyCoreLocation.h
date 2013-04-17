//
//  MyCoreLocation.h
//  Telstra OSS Mobile Inventory
//
//  Created by Muliawan Sjarif on 20/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreLocation/CoreLocation.h"

@interface MyCoreLocation : NSObject
<CLLocationManagerDelegate> {
    CLLocationManager *locationManager;
    id caller;
	
	BOOL updating;
	BOOL showErrors;
}

@property (nonatomic, assign) BOOL updating;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) id caller;

- (void)startUpdating;
- (void)stopUpdating;

@end
