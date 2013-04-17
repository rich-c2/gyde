//
//  FacebookHelper.h
//  Gyde
//
//  Created by Richard Lee on 7/04/13.
//  Copyright (c) 2013 Richard Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const FBSessionStateChangedNotification;

@interface FacebookHelper : NSObject

+ (FacebookHelper *)sharedHelper;

- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI;
- (void)closeSession;

@end
