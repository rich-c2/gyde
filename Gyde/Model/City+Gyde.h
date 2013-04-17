//
//  City+Gyde.h
//  Gyde
//
//  Created by Richard Lee on 30/03/13.
//  Copyright (c) 2013 Richard Lee. All rights reserved.
//

#import "City.h"

@interface City (Gyde)

+ (City *)cityWithTitle:(NSString *)cityTitle inManagedObjectContext:(NSManagedObjectContext *)context;

@end
