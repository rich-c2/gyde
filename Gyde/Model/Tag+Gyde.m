//
//  Tag+Gyde.m
//  Gyde
//
//  Created by Richard Lee on 30/03/13.
//  Copyright (c) 2013 Richard Lee. All rights reserved.
//

#import "Tag+Gyde.h"

@implementation Tag (Gyde)


+ (Tag *)tagWithID:(NSInteger)tagIDNum inManagedObjectContext:(NSManagedObjectContext *)context {
	
	Tag *tag = nil;
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity = [NSEntityDescription entityForName:@"Tag" inManagedObjectContext:context];
	request.predicate = [NSPredicate predicateWithFormat:@"tagID == %i", tagIDNum];
	
	NSError *error = nil;
	tag = [[context executeFetchRequest:request error:&error] lastObject];
		
	return tag;
}


+ (Tag *)tagWithTitle:(NSString *)tagTitle andID:(NSInteger)tagIDNum
inManagedObjectContext:(NSManagedObjectContext *)context {
	
	Tag *tag = nil;
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity = [NSEntityDescription entityForName:@"Tag" inManagedObjectContext:context];
	request.predicate = [NSPredicate predicateWithFormat:@"tagID == %i", tagIDNum];
	
	NSError *error = nil;
	tag = [[context executeFetchRequest:request error:&error] lastObject];
	
	if (!error && !tag) {
				
		// Create a new tag
		tag = [NSEntityDescription insertNewObjectForEntityForName:@"Tag" inManagedObjectContext:context];
		tag.title = tagTitle;
		tag.tagID = [NSNumber numberWithInt:tagIDNum];
	}
	
	return tag;
}


@end
