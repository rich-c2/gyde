//
//  User.h
//  Gyde
//
//  Created by Richard Lee on 30/03/13.
//  Copyright (c) 2013 Richard Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Guide, Photo;

@interface User : NSManagedObject

@property (nonatomic, retain) NSString * avatarThumbURL;
@property (nonatomic, retain) NSString * avatarURL;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * emailAddress;
@property (nonatomic, retain) NSNumber * followersCount;
@property (nonatomic, retain) NSNumber * followingCount;
@property (nonatomic, retain) NSString * fullName;
@property (nonatomic, retain) NSNumber * guidesCount;
@property (nonatomic, retain) NSNumber * photosCount;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSSet *followingGuides;
@property (nonatomic, retain) NSSet *guides;
@property (nonatomic, retain) NSSet *lovedPhotos;
@property (nonatomic, retain) NSSet *photosTaken;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addFollowingGuidesObject:(Guide *)value;
- (void)removeFollowingGuidesObject:(Guide *)value;
- (void)addFollowingGuides:(NSSet *)values;
- (void)removeFollowingGuides:(NSSet *)values;

- (void)addGuidesObject:(Guide *)value;
- (void)removeGuidesObject:(Guide *)value;
- (void)addGuides:(NSSet *)values;
- (void)removeGuides:(NSSet *)values;

- (void)addLovedPhotosObject:(Photo *)value;
- (void)removeLovedPhotosObject:(Photo *)value;
- (void)addLovedPhotos:(NSSet *)values;
- (void)removeLovedPhotos:(NSSet *)values;

- (void)addPhotosTakenObject:(Photo *)value;
- (void)removePhotosTakenObject:(Photo *)value;
- (void)addPhotosTaken:(NSSet *)values;
- (void)removePhotosTaken:(NSSet *)values;

@end
