//
//  City+Gyde.m
//  Gyde
//
//  Created by Richard Lee on 30/03/13.
//  Copyright (c) 2013 Richard Lee. All rights reserved.
//

#import "City+Gyde.h"

@implementation City (Gyde)


+ (City *)cityWithTitle:(NSString *)cityTitle inManagedObjectContext:(NSManagedObjectContext *)context {
	
	City *city = nil;
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity = [NSEntityDescription entityForName:@"City" inManagedObjectContext:context];
	request.predicate = [NSPredicate predicateWithFormat:@"title = %@", cityTitle];
	
	NSError *error = nil;
	city = [[context executeFetchRequest:request error:&error] lastObject];
	
	// If no error and no City object was found
	if (!error && !city) {
				
		// Create a new City
		city = [NSEntityDescription insertNewObjectForEntityForName:@"City" inManagedObjectContext:context];
		city.title = cityTitle;
	}
	
	return city;
}

@end
