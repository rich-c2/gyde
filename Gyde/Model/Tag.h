//
//  Tag.h
//  Gyde
//
//  Created by Richard Lee on 28/03/13.
//  Copyright (c) 2013 Richard Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Guide, Photo;

@interface Tag : NSManagedObject

@property (nonatomic, retain) NSNumber * tagID;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSSet *forGuides;
@property (nonatomic, retain) NSSet *onPhoto;
@end

@interface Tag (CoreDataGeneratedAccessors)

- (void)addForGuidesObject:(Guide *)value;
- (void)removeForGuidesObject:(Guide *)value;
- (void)addForGuides:(NSSet *)values;
- (void)removeForGuides:(NSSet *)values;

- (void)addOnPhotoObject:(Photo *)value;
- (void)removeOnPhotoObject:(Photo *)value;
- (void)addOnPhoto:(NSSet *)values;
- (void)removeOnPhoto:(NSSet *)values;

@end
