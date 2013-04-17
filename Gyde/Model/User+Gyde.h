//
//  User+Gyde.h
//  Gyde
//
//  Created by Richard Lee on 30/03/13.
//  Copyright (c) 2013 Richard Lee. All rights reserved.
//

#import "User.h"

@interface User (Gyde)

+ (User *)userWithBasicData:(NSDictionary *)basicInfo inManagedObjectContext:(NSManagedObjectContext *)context;
+ (User *)userWithUsername:(NSString *)theUsername
	inManagedObjectContext:(NSManagedObjectContext *)context;
+ (User *)userWithLoginData:(NSDictionary *)loginData inManagedObjectContext:(NSManagedObjectContext *)context;

@end
