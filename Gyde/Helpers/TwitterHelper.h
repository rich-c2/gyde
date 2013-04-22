//
//  TwitterHelper.h
//  Gyde
//
//  Created by Richard Lee on 22/04/13.
//  Copyright (c) 2013 Richard Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TwitterHelper : NSObject

+ (TwitterHelper *)sharedHelper;
- (BOOL)isTwitterAvailable;

@end
