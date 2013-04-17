//
//  TANotificationsManager.h
//  Tourism App
//
//  Created by Richard Lee on 24/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HTTPFetcher;

@interface TANotificationsManager : NSObject {

	NSTimer *pollTimer;
	
	HTTPFetcher *pollFetcher;
	
	NSNumber *recommends;
	NSNumber *meItems;
}

@property (nonatomic, retain) NSNumber *recommends;
@property (nonatomic, retain) NSNumber *meItems;

+ (id)sharedManager;
- (void)updateRecommendations:(NSInteger)newRecommendations;
- (void)updateMe:(NSInteger)newMe;

@end
