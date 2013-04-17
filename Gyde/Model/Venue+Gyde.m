//
//  Venue+Gyde.m
//  Gyde
//
//  Created by Richard Lee on 30/03/13.
//  Copyright (c) 2013 Richard Lee. All rights reserved.
//

#import "Venue+Gyde.h"

@implementation Venue (Gyde)

+ (Venue *)venueWithData:(NSDictionary *)venueData location:(NSDictionary *)locationData inManagedObjectContext:(NSManagedObjectContext *)context {
	
	Venue *venue = nil;
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity = [NSEntityDescription entityForName:@"Venue" inManagedObjectContext:context];
	request.predicate = [NSPredicate predicateWithFormat:@"title = %@", [venueData objectForKey:@"title"]];
	
	NSError *error = nil;
	venue = [[context executeFetchRequest:request error:&error] lastObject];
	
	if (!error && !venue) {
		
		// Create a new User
		venue = [NSEntityDescription insertNewObjectForEntityForName:@"Venue" inManagedObjectContext:context];
		venue.title = [venueData objectForKey:@"title"];
		venue.address = [venueData objectForKey:@"address"];
		venue.city = [venueData objectForKey:@"city"];
		venue.state = [venueData objectForKey:@"state"];
		venue.country = [venueData objectForKey:@"country"];
		venue.postcode = [venueData objectForKey:@"postcode"];
		
		venue.latitude = [NSNumber numberWithDouble:[[venueData objectForKey:@"latitude"] doubleValue]];
		venue.longitude = [NSNumber numberWithDouble:[[venueData objectForKey:@"longitude"] doubleValue]];
	}
	
	return venue;
}


@end
