//
//  City.h
//  Gyde
//
//  Created by Richard Lee on 30/03/13.
//  Copyright (c) 2013 Richard Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Guide, Photo;

@interface City : NSManagedObject

@property (nonatomic, retain) NSString * cityID;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSSet *locationForGuide;
@property (nonatomic, retain) NSSet *photosTakenHere;
@end

@interface City (CoreDataGeneratedAccessors)

- (void)addLocationForGuideObject:(Guide *)value;
- (void)removeLocationForGuideObject:(Guide *)value;
- (void)addLocationForGuide:(NSSet *)values;
- (void)removeLocationForGuide:(NSSet *)values;

- (void)addPhotosTakenHereObject:(Photo *)value;
- (void)removePhotosTakenHereObject:(Photo *)value;
- (void)addPhotosTakenHere:(NSSet *)values;
- (void)removePhotosTakenHere:(NSSet *)values;

@end
