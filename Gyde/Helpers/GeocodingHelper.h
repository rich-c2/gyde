//
//  GeocodingHelper.h
//  Gyde
//
//  Created by Richard Lee on 8/04/13.
//  Copyright (c) 2013 Richard Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface GeocodingHelper : NSObject <MKReverseGeocoderDelegate>

+ (GeocodingHelper *)sharedHelper;

@end
