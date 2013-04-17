//
//  Tag+Gyde.h
//  Gyde
//
//  Created by Richard Lee on 30/03/13.
//  Copyright (c) 2013 Richard Lee. All rights reserved.
//

#import "Tag.h"

@interface Tag (Gyde)

+ (Tag *)tagWithID:(NSInteger)tagIDNum inManagedObjectContext:(NSManagedObjectContext *)context;
+ (Tag *)tagWithTitle:(NSString *)tagTitle andID:(NSInteger)tagIDNum
inManagedObjectContext:(NSManagedObjectContext *)context;

@end
