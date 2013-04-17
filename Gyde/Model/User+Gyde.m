//
//  User+Gyde.m
//  Gyde
//
//  Created by Richard Lee on 30/03/13.
//  Copyright (c) 2013 Richard Lee. All rights reserved.
//

#import "User+Gyde.h"

@implementation User (Gyde)

// Here the persistant store will be queried using the username data within the basicInfo dictionary.
// The basicInfo dictionary will only contain a username and avatarURL.
+ (User *)userWithBasicData:(NSDictionary *)basicInfo inManagedObjectContext:(NSManagedObjectContext *)context {
	
	User *user = nil;
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:context];
	request.predicate = [NSPredicate predicateWithFormat:@"username = %@", [basicInfo objectForKey:@"username"]];
	
	NSError *error = nil;
	user = [[context executeFetchRequest:request error:&error] lastObject];
	
	if (!error && !user) {
		
		// Create a new User
		user = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:context];
		user.username = [basicInfo objectForKey:@"username"];
		user.avatarURL = [NSString stringWithFormat:@"%@%@", FRONT_END_ADDRESS, [basicInfo objectForKey:@"avatar"]];
		//user.fullName = [basicInfo objectForKey:@"name"];
	}
	
	else if (!error && user) {
		
		// Update user properties
		user.username = [basicInfo objectForKey:@"username"];
		user.avatarURL = [NSString stringWithFormat:@"%@%@", FRONT_END_ADDRESS, [basicInfo objectForKey:@"avatar"]];
		//user.fullName = [basicInfo objectForKey:@"name"];
	}
	
	return user;
}



// Creates User NSManagedObject using the data returned from a login requests
+ (User *)userWithLoginData:(NSDictionary *)loginData inManagedObjectContext:(NSManagedObjectContext *)context {
	
	User *user = nil;
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:context];
	request.predicate = [NSPredicate predicateWithFormat:@"username = %@", [loginData objectForKey:@"username"]];
	
	NSError *error = nil;
	user = [[context executeFetchRequest:request error:&error] lastObject];
	
	if (!error && !user) {
		
		// Create a new User
		user = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:context];
		user.username = [loginData objectForKey:@"username"];
		user.avatarURL = [NSString stringWithFormat:@"%@%@", FRONT_END_ADDRESS, [loginData objectForKey:@"avatar"]];
		user.fullName = [loginData objectForKey:@"name"];
        user.photosCount = [NSNumber numberWithInt:[[loginData objectForKey:@"media"] intValue]];
        user.guidesCount = [NSNumber numberWithInt:[[loginData objectForKey:@"guides"] intValue]];
        user.followersCount = [NSNumber numberWithInt:[[loginData objectForKey:@"followers"] intValue]];
        user.followingCount = [NSNumber numberWithInt:[[loginData objectForKey:@"following"] intValue]];
        user.city = [loginData objectForKey:@"city"];
	}
	
	else if (!error && user) {
		
		// Update user properties
		user.username = [loginData objectForKey:@"username"];
		user.avatarURL = [NSString stringWithFormat:@"%@%@", FRONT_END_ADDRESS, [loginData objectForKey:@"avatar"]];
		user.fullName = [loginData objectForKey:@"name"];
        user.photosCount = [NSNumber numberWithInt:[[loginData objectForKey:@"media"] intValue]];
        user.guidesCount = [NSNumber numberWithInt:[[loginData objectForKey:@"guides"] intValue]];
        user.followersCount = [NSNumber numberWithInt:[[loginData objectForKey:@"followers"] intValue]];
        user.followingCount = [NSNumber numberWithInt:[[loginData objectForKey:@"following"] intValue]];
        user.city = [loginData objectForKey:@"city"];
	}
	
	return user;
}


// Here the persistant store will be queried using just a username
+ (User *)userWithUsername:(NSString *)theUsername
	inManagedObjectContext:(NSManagedObjectContext *)context {
	
	User *user = nil;
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:context];
	request.predicate = [NSPredicate predicateWithFormat:@"username = %@", theUsername];
	
	NSError *error = nil;
	user = [[context executeFetchRequest:request error:&error] lastObject];
	
	return user;
}


@end
