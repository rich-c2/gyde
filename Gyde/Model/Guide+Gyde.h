//
//  Guide+Gyde.h
//  Gyde
//
//  Created by Richard Lee on 30/03/13.
//  Copyright (c) 2013 Richard Lee. All rights reserved.
//

#import "Guide.h"

@interface Guide (Gyde)

+ (Guide *)guideWithGuideData:(NSDictionary *)guideData inManagedObjectContext:(NSManagedObjectContext *)context;

+ (Guide *)guideWithGuideData:(NSDictionary *)guideData andImageIDs:(NSString *)IDstring inManagedObjectContext:(NSManagedObjectContext *)context;

- (void)updateWithData:(NSDictionary *)data;

@end
