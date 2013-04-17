//
//  AppDelegate.h
//  Gyde
//
//  Created by Richard Lee on 24/03/13.
//  Copyright (c) 2013 Richard Lee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "TALandingVC.h"

extern NSString *const FBSessionStateChangedNotification;

extern NSString* const DEMO_PASSWORD;
extern NSString* const DEMO_USERNAME;
extern NSString* const API_ADDRESS;
extern NSString* const FRONT_END_ADDRESS;
extern NSString* const TEST_API_ADDRESS;
extern NSString* const FACEBOOK_APP_ID;

@class MeVC;
@class TANotificationsVC;
@class TALoginVC;
@class TASettingsVC;
@class TACameraVC;
@class TAExploreVC;

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
	
	
	BOOL userLoggedIn;
	
	IBOutlet TALoginVC *loginVC;
	IBOutlet TALandingVC *landingVC;
	IBOutlet UINavigationController *landingNav;
    
	IBOutlet UITabBarController *tabBarController;
	
	TASettingsVC *settingsVC;
	TAExploreVC *exploreVC;
	TACameraVC *cameraVC;
	MeVC *profileVC;
	TANotificationsVC *notificationsVC;
	
	NSString *sessionToken;
	NSString *loggedInUsername;
}

@property (nonatomic) BOOL userLoggedIn;

@property (strong, nonatomic) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet TALoginVC *loginVC;
@property (nonatomic, retain) IBOutlet TALandingVC *landingVC;
@property (nonatomic, retain) IBOutlet UINavigationController *landingNav;

@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

@property (nonatomic, retain) TASettingsVC *settingsVC;
@property (nonatomic, retain) TAExploreVC *exploreVC;
@property (nonatomic, retain) TACameraVC *cameraVC;
@property (nonatomic, retain) MeVC *profileVC;
@property (nonatomic, retain) TANotificationsVC *notificationsVC;

@property (nonatomic, retain) NSString *sessionToken;
@property (nonatomic, retain) NSString *loggedInUsername;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

// FBSample logic
// In this sample the app delegate maintains a property for the current
// active session, and the view controllers reference the session via
// this property, as well as play a role in keeping the session object
// up to date; a more complicated application may choose to introduce
// a simple singleton that owns the active FBSession object as well
// as access to the object by the rest of the application
@property (strong, nonatomic) FBSession *session;


- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

- (void)setToken:(NSString *)token;

- (NSMutableURLRequest *)createPostRequestWithURL:(NSURL *)url postData:(NSData *)postData;
- (NSURL *)createRequestURLWithMethod:(NSString *)methodName testMode:(BOOL)test;

- (NSArray *)serializeGuideData:(NSArray *)newGuides;
- (NSArray *)serializePhotoData:(NSArray *)newPhotos;
- (NSMutableArray *)serializeUsersData:(NSArray *)newUsers;

- (void)setTwitterUserID:(NSString *)newUserID;
- (void)setTwitterUsername:(NSString *)newUsername;
- (void)setTwitterAccountID:(NSString *)newAccountID;

- (NSString *)getTwitterUserID;
- (NSString *)getTwitterUsername;
- (NSString *)getTwitterAccountID;

- (void)quitCamera;

@end
