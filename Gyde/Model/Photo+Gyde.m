//
//  Photo+Gyde.m
//  Gyde
//
//  Created by Richard Lee on 30/03/13.
//  Copyright (c) 2013 Richard Lee. All rights reserved.
//

#import "Photo+Gyde.h"

@implementation Photo (Gyde)

+ (Photo *)photoWithPhotoData:(NSDictionary *)photoData inManagedObjectContext:(NSManagedObjectContext *)context {
	
	Photo *photo = nil;
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity = [NSEntityDescription entityForName:@"Photo" inManagedObjectContext:context];
	request.predicate = [NSPredicate predicateWithFormat:@"photoID = %@", [photoData objectForKey:@"code"]];
	
	NSError *error = nil;
	photo = [[context executeFetchRequest:request error:&error] lastObject];
	
	if (!error && !photo) {
		
		// Create a new Photo
		photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
		photo.photoID = [photoData objectForKey:@"code"];
		photo.caption = [photoData objectForKey:@"caption"];
		
		// Convert string to date object
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"dd/MM/yyyy hh:mm:ss a"];
		NSString *dateString = [photoData objectForKey:@"date"];
		NSDate *photoDate = [dateFormatter dateFromString:dateString];
		photo.date = photoDate;
		
		// TIME ELAPSED
		photo.timeElapsed = [photoData objectForKey:@"elapsed"];
		
		// PATHS
		NSDictionary *imagePaths = [photoData objectForKey:@"paths"];
		photo.thumbURL = [NSString stringWithFormat:@"%@%@", FRONT_END_ADDRESS, [imagePaths objectForKey:@"thumb"]];
		photo.url = [NSString stringWithFormat:@"%@%@", FRONT_END_ADDRESS, [imagePaths objectForKey:@"zoom"]];
		
		// USER
		NSDictionary *userDict = [photoData objectForKey:@"user"];
		photo.username = [userDict objectForKey:@"username"];
		photo.whoTook = [User userWithBasicData:userDict inManagedObjectContext:context];
		
		// COUNT DATA
		NSDictionary *countData = [photoData objectForKey:@"count"];
		photo.lovesCount = [NSNumber numberWithInt:[[countData objectForKey:@"loves"] intValue]];
		
		//CITY
		photo.city = [City cityWithTitle:[photoData objectForKey:@"city"] inManagedObjectContext:context];
		
		// TAG
		photo.tag = [Tag tagWithID:[[photoData objectForKey:@"tag"] intValue] inManagedObjectContext:context];
		
		/*
		 VENUE & LOCATION
		 */
        
		NSDictionary *locationData = [photoData objectForKey:@"location"];
		NSDictionary *venueData = [photoData objectForKey:@"address"];
		
        if ([[venueData allKeys] count] > 0)
            photo.venue = [Venue venueWithData:venueData location:locationData inManagedObjectContext:context];
		
		photo.latitude = [NSNumber numberWithDouble:[[locationData objectForKey:@"latitude"] doubleValue]];
		photo.longitude = [NSNumber numberWithDouble:[[locationData objectForKey:@"longitude"] doubleValue]];
        
		////////////////////////////////////////////////////////////
	}
	
	else if (!error && photo) {
		
		// Create a new Photo
		photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
		photo.photoID = [photoData objectForKey:@"code"];
		photo.caption = [photoData objectForKey:@"caption"];
		
		// Convert string to date object
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"dd/MM/yyyy hh:mm:ss a"];
		NSString *dateString = [photoData objectForKey:@"date"];
		NSDate *photoDate = [dateFormatter dateFromString:dateString];
		photo.date = photoDate;
		
		// TIME ELAPSED
		photo.timeElapsed = [photoData objectForKey:@"elapsed"];
		
		// PATHS
		NSDictionary *imagePaths = [photoData objectForKey:@"paths"];
		photo.thumbURL = [NSString stringWithFormat:@"%@%@", FRONT_END_ADDRESS, [imagePaths objectForKey:@"thumb"]];
		photo.url = [NSString stringWithFormat:@"%@%@", FRONT_END_ADDRESS, [imagePaths objectForKey:@"zoom"]];
		
		// USER
		NSDictionary *userDict = [photoData objectForKey:@"user"];
		photo.username = [userDict objectForKey:@"username"];
		photo.whoTook = [User userWithBasicData:userDict inManagedObjectContext:context];
		
		// COUNT DATA
		NSDictionary *countData = [photoData objectForKey:@"count"];
		photo.lovesCount  = [NSNumber numberWithInt:[[countData objectForKey:@"loves"] intValue]];
        
		//CITY
		photo.city = [City cityWithTitle:[photoData objectForKey:@"city"] inManagedObjectContext:context];
		
		// TAG
		photo.tag = [Tag tagWithID:[[photoData objectForKey:@"tag"] intValue] inManagedObjectContext:context];
		
		
		// VENUE & LOCATION
        
		NSDictionary *locationData = [photoData objectForKey:@"location"];
		NSDictionary *venueData = [photoData objectForKey:@"address"];
        
        if ([[venueData allKeys] count] > 0)
            photo.venue = [Venue venueWithData:venueData location:locationData inManagedObjectContext:context];
		
		photo.latitude = [NSNumber numberWithDouble:[[locationData objectForKey:@"latitude"] doubleValue]];
		photo.longitude = [NSNumber numberWithDouble:[[locationData objectForKey:@"longitude"] doubleValue]];
        
		////////////////////////////////////////////////////////////
	}
	
	return photo;
}

@end
