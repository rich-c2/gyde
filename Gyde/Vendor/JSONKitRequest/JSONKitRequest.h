//
//  JSONKitRequest.h
//  Tourism App
//
//  Created by Richard Lee on 7/10/12.
//
//

#import <Foundation/Foundation.h>

@interface JSONKitRequest : NSObject
#if TARGET_OS_IPHONE
	<UITextFieldDelegate>
#endif
{
	id receiver;
	SEL action;
	
	NSURLConnection *connection;
	NSMutableData *data;
	NSURLAuthenticationChallenge *challenge;
	
	NSURLRequest *urlRequest;
	NSInteger failureCode;
	BOOL showAlerts;
	BOOL showAuthentication;
	NSDictionary *responseHeaderFields;
	void *context;
		
#if TARGET_OS_IPHONE
		UITextField *usernameField;
		UITextField *passwordField;
		UIAlertView *passwordAlert;
#endif
}

@property (nonatomic, readonly) NSData *data;
@property (nonatomic, readonly) NSURLRequest *urlRequest;
@property (nonatomic, readonly) NSDictionary *responseHeaderFields;
@property (nonatomic, readonly) NSInteger failureCode;
@property (nonatomic, assign) BOOL showAlerts;
@property (nonatomic, assign) BOOL showAuthentication;
@property (nonatomic, assign) void *context;

- (id)initWithURLRequest:(NSURLRequest *)aURLRequest
				receiver:(id)aReceiver
				  action:(SEL)receiverAction;
- (void)start;
- (void)cancel;
- (void)close;

@end
