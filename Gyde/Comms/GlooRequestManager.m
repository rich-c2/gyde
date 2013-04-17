//
//  GlooRequestManager.m
//  Gyde
//
//  Created by Richard Lee on 8/04/13.
//  Copyright (c) 2013 Richard Lee. All rights reserved.
//

#import "GlooRequestManager.h"

#define API_BASE_URL @"http://want.supergloo.net.au/api/"
#define API_BASE_DOMAIN @"http://want.supergloo.net.au"
#define API_REQUEST_TIMEOUT_IN_SECONDS 60

@implementation GlooRequestManager

@synthesize apiReachable = _apiReachable;
@synthesize internetReachable = _internetReachable;

static GlooRequestManager *sharedRequestManager = nil;

#pragma mark - initialisation

+ (GlooRequestManager *)sharedManager
{
	if (sharedRequestManager == nil) {
		sharedRequestManager = [[super alloc] init];
	}
	return sharedRequestManager;
}

- (id)init {
	if ((self = [super init])) {
		operationQueue = [[ASINetworkQueue alloc] init];
		operationQueue.maxConcurrentOperationCount = 1;
	}
	return self;
}


#pragma mark - main api request methods

- (BOOL)isApiReachable
{
//    if ([apiReachable currentReachabilityStatus] == NotReachable || [internetReachable currentReachabilityStatus] == NotReachable) {
//		return NO;
//	}
	return YES;
}

- (void)get:(NSString *)endpoint params:(NSDictionary *)params dataLoadBlock:(void (^)(NSDictionary *))dataLoadBlock
                        completionBlock:(void (^)(NSDictionary *))completionBlock
                            viewForHUD:(UIView *)hudView {
    
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@?", API_BASE_URL, endpoint];
    
    if (params != nil) {
        NSArray *keys = [params allKeys];
        for (NSString *key in keys) {
            NSString *unencodedString = (NSString *)[params objectForKey:key];
            NSString *encodedString = [unencodedString stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
            [urlString appendFormat:@"%@=%@&",key,encodedString];
        }
    }
    
    NSURL *url = [NSURL URLWithString:urlString];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    [self _sendRequest:request
         dataLoadBlock:dataLoadBlock
       completionBlock:completionBlock
            viewForHUD:hudView];
}

- (void)post:(NSString *)endpoint params:(NSDictionary *)params
                            dataLoadBlock:(void (^)(NSDictionary *))dataLoadBlock
                            completionBlock:(void (^)(NSDictionary *))completionBlock
                                viewForHUD:(UIView *)hudView {
    
    NSString *urlString  = [NSString stringWithFormat:@"%@%@", API_BASE_URL, endpoint];
    
    NSURL *url = [NSURL URLWithString:urlString];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    for (NSString *key in [params allKeys]) {
        [request setPostValue:[params objectForKey:key] forKey:key];
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults valueForKey:@"api_certificate_id"]) {
        [request setPostValue:[defaults valueForKey:@"api_certificate_id"] forKey:@"api_certificate_id"];
    }
    
    [self _sendRequest:request
         dataLoadBlock:dataLoadBlock
       completionBlock:completionBlock
            viewForHUD:hudView];
}

- (void)post:(NSString *)endpoint image:(UIImage *)image
                        imageParamKey:(NSString *)imageParamKey
                            fileName:(NSString *)fileName
                                params:(NSDictionary *)params
                        dataLoadBlock:(void (^)(NSDictionary *))dataLoadBlock
                        completionBlock:(void (^)(NSDictionary *))completionBlock
                          viewForHUD:(UIView *)hudView {
    
    NSString *urlString  = [NSString stringWithFormat:@"%@%@", API_BASE_URL, endpoint];
    
    NSURL *url = [NSURL URLWithString:urlString];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    [request setData:UIImagePNGRepresentation(image) withFileName:fileName andContentType:@"image/png" forKey:imageParamKey];
    
    for (NSString *key in [params allKeys]) {
        [request setPostValue:[params objectForKey:key] forKey:key];
    }
    
    [self _sendRequest:request
         dataLoadBlock:dataLoadBlock
       completionBlock:completionBlock
            viewForHUD:hudView];
}


- (void)_sendRequest:(ASIHTTPRequest *)request
       dataLoadBlock:(void (^)(NSDictionary *))dataLoadBlock
     completionBlock:(void (^)(NSDictionary *))completionBlock
          viewForHUD:(UIView *)hudView {
    
    NSDictionary *failedResult = @{@"success" : @"0",
    @"data"    : @"",
    @"errors"  : @"API connection error"};
    
    // Cannot reach server
	if (![self isApiReachable]) {
        completionBlock(failedResult);
        return;
    }
    
    // Animate activity indicater
    if (hudView) {
        [MBProgressHUD showHUDAddedTo:hudView animated:YES];
    }
    
    // Constructing request
    
    request.timeOutSeconds = API_REQUEST_TIMEOUT_IN_SECONDS;
    
    __weak ASIHTTPRequest *weakRequest = request;
    [request setFailedBlock:^{
        completionBlock(failedResult);
    }];
    
    [request setCompletionBlock:^{
        
#if DWREQUEST_DEBUG
        NSString *response = [weakRequest responseString];
        NSLog(@"%@: %@", weakRequest.url, response);
#endif
        
        if (hudView) {
            [MBProgressHUD hideHUDForView:hudView animated:YES];
        }
        
        if ([weakRequest responseStatusCode] != 200) {
            [self performSelectorOnMainThread:@selector(displayNetworkErrorAlert) withObject:nil waitUntilDone:NO];
            return;
        }
        
        NSMutableDictionary *tempResult = weakRequest.responseString.JSONValue;
        if (tempResult == nil) {
            NSLog(@"JSON PARSING ERROR: %@", [weakRequest responseString]);
            [self performSelectorOnMainThread:@selector(displayNetworkErrorAlert) withObject:nil waitUntilDone:NO];
            completionBlock(failedResult);
            return;
        }
        
//        NSMutableDictionary *result;
//        if ([[tempResult objectForKey:@"success"] intValue] == 1) {
//            if (hudView) {
//                tempResult[@"view_for_hud"] = hudView;
//            }
//            result = tempResult;
//            dataLoadBlock(result);
//            
//        } else {
//            result = [[NSMutableDictionary alloc] init];
//            result[@"success"] = @"0";
//            result[@"data"]    = @"";
//            result[@"errors"]  = [tempResult objectForKey:@"errors"];
//            if (hudView) {
//                tempResult[@"view_for_hud"] = hudView;
//            }
//        }
        
        completionBlock(tempResult);
    }];
    
    [operationQueue addOperation:request];
    [operationQueue go];
}

@end
