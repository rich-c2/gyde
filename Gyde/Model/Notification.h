//
//  Notification.h
//  Gyde
//
//  Created by Richard Lee on 28/03/13.
//  Copyright (c) 2013 Richard Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Notification : NSManagedObject

@property (nonatomic, retain) NSString * code;
@property (nonatomic, retain) NSNumber * read;
@property (nonatomic, retain) NSString * subtitle;
@property (nonatomic, retain) NSString * thumbURL;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * type;

@end
