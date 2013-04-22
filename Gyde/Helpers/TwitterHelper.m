//
//  TwitterHelper.m
//  Gyde
//
//  Created by Richard Lee on 22/04/13.
//  Copyright (c) 2013 Richard Lee. All rights reserved.
//

#import "TwitterHelper.h"
#import <Twitter/Twitter.h>

@implementation TwitterHelper

+ (TwitterHelper *)sharedHelper {
    static TwitterHelper *sharedHelper;
    @synchronized(self) {
        if (!sharedHelper) {
            sharedHelper = [[TwitterHelper alloc] init];
        }
        return sharedHelper;
    }
}

- (BOOL)isTwitterAvailable {

    //Check for Social Framework availability (iOS 6)
    if(NSClassFromString(@"SLComposeViewController") != nil){
        
        if([SLComposeViewController instanceMethodForSelector:@selector(isAvailableForServiceType)] != nil)
        {
            return ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]);
        }
        
        else {
            
            return NO;
        }
    }
    
    else{
        
        // For TWTweetComposeViewController (iOS 5)
        return ([TWTweetComposeViewController canSendTweet]);
    }
}

@end
