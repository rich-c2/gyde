//
//  GeocodingHelper.m
//  Gyde
//
//  Created by Richard Lee on 8/04/13.
//  Copyright (c) 2013 Richard Lee. All rights reserved.
//

#import "GeocodingHelper.h"

@implementation GeocodingHelper

+ (GeocodingHelper *)sharedHelper {
    
    static GeocodingHelper *instance;
    @synchronized(self) {
        if (!instance) {
            instance = [[GeocodingHelper alloc] init];
        }
        return instance;
    }
}

@end
