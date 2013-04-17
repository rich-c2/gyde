//
//  Guide.h
//  Gyde
//
//  Created by Richard Lee on 13/04/13.
//  Copyright (c) 2013 Richard Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class City, Photo, Tag, User;

@interface Guide : NSManagedObject

@property (nonatomic, retain) NSString * frontEndURL;
@property (nonatomic, retain) NSString * guideID;
@property (nonatomic, retain) NSString * imageIDs;
@property (nonatomic, retain) NSNumber * lovesCount;
@property (nonatomic, retain) NSNumber * photosCount;
@property (nonatomic, retain) NSNumber * private;
@property (nonatomic, retain) NSString * thumbURL;
@property (nonatomic, retain) NSString * timeElapsed;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) User *author;
@property (nonatomic, retain) City *city;
@property (nonatomic, retain) NSSet *followedBy;
@property (nonatomic, retain) NSSet *photos;
@property (nonatomic, retain) Tag *tag;
@end

@interface Guide (CoreDataGeneratedAccessors)

- (void)addFollowedByObject:(User *)value;
- (void)removeFollowedByObject:(User *)value;
- (void)addFollowedBy:(NSSet *)values;
- (void)removeFollowedBy:(NSSet *)values;

- (void)addPhotosObject:(Photo *)value;
- (void)removePhotosObject:(Photo *)value;
- (void)addPhotos:(NSSet *)values;
- (void)removePhotos:(NSSet *)values;

@end
