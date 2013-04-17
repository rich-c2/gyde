//
//  Venue+Gyde.h
//  Gyde
//
//  Created by Richard Lee on 30/03/13.
//  Copyright (c) 2013 Richard Lee. All rights reserved.
//

#import "Venue.h"

@interface Venue (Gyde)

+ (Venue *)venueWithData:(NSDictionary *)venueData location:(NSDictionary *)locationData inManagedObjectContext:(NSManagedObjectContext *)context;

@end
