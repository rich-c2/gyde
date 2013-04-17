//
//  Guide+Gyde.m
//  Gyde
//
//  Created by Richard Lee on 30/03/13.
//  Copyright (c) 2013 Richard Lee. All rights reserved.
//

#import "Guide+Gyde.h"

@implementation Guide (Gyde)

+ (Guide *)guideWithGuideData:(NSDictionary *)guideData inManagedObjectContext:(NSManagedObjectContext *)context {
	
	Guide *guide = nil;
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity = [NSEntityDescription entityForName:@"Guide" inManagedObjectContext:context];
	request.predicate = [NSPredicate predicateWithFormat:@"guideID = %@", [guideData objectForKey:@"guideID"]];
	
	NSError *error = nil;
	guide = [[context executeFetchRequest:request error:&error] lastObject];
	
	// If no error and no Guide object was found
	if (!error && !guide) {
		
		// CREATE A NEW GUIDE
		guide = [NSEntityDescription insertNewObjectForEntityForName:@"Guide" inManagedObjectContext:context];
		guide.guideID = [guideData objectForKey:@"guideID"];
        
        [guide updateWithData:guideData];
        
        // IMAGE IDs
        NSArray *imageArray = [guideData objectForKey:@"images"];
        NSString *idString = [imageArray componentsJoinedByString:@","];
        [guide setImageIDs:idString];
		
		NSDictionary *userData = [guideData objectForKey:@"author"];
		[guide setAuthor:[User userWithUsername:[userData objectForKey:@"username"]  inManagedObjectContext:context]];
		[guide setTag:[Tag tagWithID:[[guideData objectForKey:@"tag"] intValue] inManagedObjectContext:context]];
		[guide setCity:[City cityWithTitle:[guideData objectForKey:@"city"] inManagedObjectContext:context]];
	}
    
    else if (!error && guide) {
		
		// CREATE A NEW GUIDE
		guide.guideID = [guideData objectForKey:@"guideID"];
        
        [guide updateWithData:guideData];
        
		NSDictionary *userData = [guideData objectForKey:@"author"];
		[guide setAuthor:[User userWithUsername:[userData objectForKey:@"username"]  inManagedObjectContext:context]];
		[guide setTag:[Tag tagWithID:[[guideData objectForKey:@"tag"] intValue] inManagedObjectContext:context]];
		[guide setCity:[City cityWithTitle:[guideData objectForKey:@"city"] inManagedObjectContext:context]];
		
		// IMAGE IDs
		NSArray *imageArray = [guideData objectForKey:@"images"];
		NSString *idString = [imageArray componentsJoinedByString:@","];
		[guide setImageIDs:idString];
	}
	
	return guide;
}


+ (Guide *)guideWithGuideData:(NSDictionary *)guideData andImageIDs:(NSString *)IDstring inManagedObjectContext:(NSManagedObjectContext *)context {
	
	Guide *guide = nil;
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity = [NSEntityDescription entityForName:@"Guide" inManagedObjectContext:context];
	request.predicate = [NSPredicate predicateWithFormat:@"guideID = %@", [guideData objectForKey:@"guideID"]];
	
	NSError *error = nil;
	guide = [[context executeFetchRequest:request error:&error] lastObject];
	
	// If no error and no Guide object was found
	if (!error && !guide) {
		
		// CREATE A NEW GUIDE
		guide = [NSEntityDescription insertNewObjectForEntityForName:@"Guide" inManagedObjectContext:context];
		guide.guideID = [guideData objectForKey:@"guideID"];
        
        [guide updateWithData:guideData];
        
		NSDictionary *userData = [guideData objectForKey:@"author"];
		[guide setAuthor:[User userWithUsername:[userData objectForKey:@"username"]  inManagedObjectContext:context]];
		[guide setTag:[Tag tagWithID:[[guideData objectForKey:@"tag"] intValue] inManagedObjectContext:context]];
		[guide setCity:[City cityWithTitle:[guideData objectForKey:@"city"] inManagedObjectContext:context]];
		
		// IMAGE IDs
		[guide setImageIDs:IDstring];
	}
	
	return guide;
}
         
- (void)updateWithData:(NSDictionary *)data {

    [self setNotNilString:data[@"title"] forKey:@"title"];
    [self setNotNilInt:data[@"private"] forKey:@"private"];
    [self setNotNilString:data[@"description"] forKey:@"desc"];
    [self setNotNilString:[NSString stringWithFormat:@"%@%@", FRONT_END_ADDRESS,data[@"thumb"]] forKey:@"thumbURL"];
    [self setNotNilInt:data[@"loves"] forKey:@"lovesCount"];
    [self setNotNilString:data[@"elapsed"] forKey:@"timeElapsed"];
    [self setNotNilInt:data[@"imagecount"] forKey:@"photosCount"];
}

@end
