//
//  NSManagedObject+Gyde.m
//  Gyde
//
//  Created by Richard Lee on 13/04/13.
//  Copyright (c) 2013 Richard Lee. All rights reserved.
//

#import "NSManagedObject+Gyde.h"

@implementation NSManagedObject (Gyde)

#pragma mark - key-value coding helpers

- (void)setNotNilString:(NSString *)value forKey:(NSString *)key
{
	if (value != nil) {
		[self setValue:value forKey:key];
	}
}

- (void)setNotNilBool:(NSString *)value forKey:(NSString *)key
{
	if (value != nil) {
		[self setValue:[NSNumber numberWithBool:value.boolValue] forKey:key];
	}
}

- (void)setNotNilInt:(NSString *)value forKey:(NSString *)key
{
	if (value != nil) {
		[self setValue:[NSNumber numberWithInt:[value intValue]] forKey:key];
	}
}

- (void)setNotNilDate:(NSString *)value forKey:(NSString *)key
{
	if (value != nil) {
		NSDateFormatter *df = [[NSDateFormatter alloc] init];
		df.dateFormat = @"yyyy-MM-dd HH:mm:SS";
		NSDate *date = [df dateFromString:value];
		[self setValue:date forKey:key];
	}
}


@end
