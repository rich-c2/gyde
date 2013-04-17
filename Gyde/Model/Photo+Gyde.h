//
//  Photo+Gyde.h
//  Gyde
//
//  Created by Richard Lee on 30/03/13.
//  Copyright (c) 2013 Richard Lee. All rights reserved.
//

#import "Photo.h"

@interface Photo (Gyde)

+ (Photo *)photoWithPhotoData:(NSDictionary *)photoData inManagedObjectContext:(NSManagedObjectContext *)context;

@end
