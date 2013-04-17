//
//  NSManagedObject+Gyde.h
//  Gyde
//
//  Created by Richard Lee on 13/04/13.
//  Copyright (c) 2013 Richard Lee. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (Gyde)

- (void)setNotNilString:(NSString *)value forKey:(NSString *)key;
- (void)setNotNilBool:(NSString *)value forKey:(NSString *)key;
- (void)setNotNilInt:(NSString *)value forKey:(NSString *)key;
- (void)setNotNilDate:(NSString *)value forKey:(NSString *)key;

@end
