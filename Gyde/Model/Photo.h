//
//  Photo.h
//  Gyde
//
//  Created by Richard Lee on 31/03/13.
//  Copyright (c) 2013 Richard Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class City, Guide, Tag, User, Venue;

@interface Photo : NSManagedObject

@property (nonatomic, retain) NSString * caption;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber * lovesCount;
@property (nonatomic, retain) NSString * photoID;
@property (nonatomic, retain) NSString * thumbURL;
@property (nonatomic, retain) NSString * timeElapsed;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) City *city;
@property (nonatomic, retain) NSSet *inGuides;
@property (nonatomic, retain) NSSet *lovedBy;
@property (nonatomic, retain) Tag *tag;
@property (nonatomic, retain) Venue *venue;
@property (nonatomic, retain) User *whoTook;
@end

@interface Photo (CoreDataGeneratedAccessors)

- (void)addInGuidesObject:(Guide *)value;
- (void)removeInGuidesObject:(Guide *)value;
- (void)addInGuides:(NSSet *)values;
- (void)removeInGuides:(NSSet *)values;

- (void)addLovedByObject:(User *)value;
- (void)removeLovedByObject:(User *)value;
- (void)addLovedBy:(NSSet *)values;
- (void)removeLovedBy:(NSSet *)values;

@end
