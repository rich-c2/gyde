//
//  TAMapView.h
//  Tourism App
//
//  Created by Richard Lee on 27/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface TAMapView : UIView {

	MKMapView *map;
}

@property (nonatomic, retain) MKMapView *map;

- (id)initWithFrame:(CGRect)frame latitude:(NSNumber *)latitude longitude:(NSNumber *)longitude;

@end
