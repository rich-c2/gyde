//
//  GlooRequestManager.h
//  Gyde
//
//  Created by Richard Lee on 8/04/13.
//  Copyright (c) 2013 Richard Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <CommonCrypto/CommonDigest.h>
#import "Reachability.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "ASIDownloadCache.h"
#import "ASINetworkQueue.h"
#import "SBJSON.h"

@interface GlooRequestManager : NSObject <ASIHTTPRequestDelegate>  {
    
	ASINetworkQueue *operationQueue;
    Reachability *apiReachable;
    Reachability *internetReachable;
}

+ (GlooRequestManager *)sharedManager;

- (BOOL)isApiReachable;
- (void)get:(NSString *)endpoint params:(NSDictionary *)params expectingRawData:(BOOL)expectingRawData completionBlock:(void (^)(NSDictionary *result))completionBlock;
- (void)post:(NSString *)endpoint params:(NSDictionary *)params
dataLoadBlock:(void (^)(NSDictionary *))dataLoadBlock
completionBlock:(void (^)(NSDictionary *))completionBlock
  viewForHUD:(UIView *)hudView;
- (void)post:(NSString *)endpoint image:(UIImage *)image
imageParamKey:(NSString *)imageParamKey
    fileName:(NSString *)fileName
      params:(NSDictionary *)params
dataLoadBlock:(void (^)(NSDictionary *))dataLoadBlock
completionBlock:(void (^)(NSDictionary *))completionBlock
  viewForHUD:(UIView *)hudView;
- (void)image:(NSString *)url completionBlock:(void (^)(UIImage *image))completionBlock;


@property (nonatomic, strong) Reachability *apiReachable;
@property (nonatomic, strong) Reachability *internetReachable;

@property (strong, nonatomic) NSString *apiBaseUrl;
@property (strong, nonatomic) NSString *apiBaseDomain;
@property (strong, nonatomic) NSString *apiAppSecret;
@property (assign, nonatomic) NSInteger apiRequestTimeoutSeconds;
@property (assign, nonatomic) ASICachePolicy cachePolicy;
@property (assign, nonatomic) ASICacheStoragePolicy cacheStoragePolicy;

@end
