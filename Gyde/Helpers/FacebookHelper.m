//
//  FacebookHelper.m
//  Gyde
//
//  Created by Richard Lee on 7/04/13.
//  Copyright (c) 2013 Richard Lee. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>
#import "FacebookHelper.h"

@implementation FacebookHelper

+ (FacebookHelper *)sharedHelper {
    static FacebookHelper *sharedHelper;
    @synchronized(self) {
        if (!sharedHelper) {
            sharedHelper = [[FacebookHelper alloc] init];
        }
        return sharedHelper;
    }
}

/*
 * Opens a Facebook session and optionally shows the login UX.
 */
- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI {
    NSArray *permissions = @[@"email", @"user_birthday"];
    return [FBSession
            openActiveSessionWithReadPermissions:permissions
            allowLoginUI:allowLoginUI
            completionHandler:^(FBSession *session,
                                FBSessionState state,
                                NSError *error) {
                [self sessionStateChanged:session
                                    state:state
                                    error:error];
            }];
}

/*
 * Callback for session changes.
 */
- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error {
    
    switch (state) {
        case FBSessionStateOpen:
            if (!error) {
                
                [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"facebook_session_available" object:nil]];
                
            }
            break;
        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed:
            [FBSession.activeSession closeAndClearTokenInformation];
            break;
        default:
            break;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:FBSessionStateChangedNotification object:session];
    
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Facebook error"
                                  message:error.localizedDescription
                                  delegate:nil cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)closeSession {
    [FBSession.activeSession closeAndClearTokenInformation];
}


@end
