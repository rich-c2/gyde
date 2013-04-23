//
//  AppDelegate.m
//  Gyde
//
//  Created by Richard Lee on 24/03/13.
//  Copyright (c) 2013 Richard Lee. All rights reserved.
//

#import "AppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>
#import "StringHelper.h"
#import "MeVC.h"
#import "TANotificationsVC.h"
#import "TANotificationsManager.h"
#import "TASettingsVC.h"
#import "TAExploreVC.h"
#import "TACameraVC.h"

NSString *const FBSessionStateChangedNotification =
@"au.net.c2.Tourism-App:FBSessionStateChangedNotification";

NSString* const DEMO_PASSWORD = @"pass";
NSString* const DEMO_USERNAME = @"fuzzyhead";
NSString* const API_ADDRESS = @"http://want.supergloo.net.au/api/";
NSString* const FRONT_END_ADDRESS = @"http://want.supergloo.net.au";
NSString* const TEST_API_ADDRESS = @"http://www.richardflee.me/test/";
NSString* const FACEBOOK_APP_ID = @"502827299731831";

static NSString *kTwitterUsernameKey = @"twitterUsernameKey";
static NSString *ktwitterUserIDKey = @"twitterUserIDKey";
static NSString *kTwitterAccountIDKey = @"twitterAccountIDKey";

@implementation AppDelegate

@synthesize window = _window;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;
@synthesize profileVC, notificationsVC, tabBarController, landingVC;
@synthesize sessionToken, loggedInUsername, loginVC, landingNav;
@synthesize settingsVC, exploreVC, cameraVC, userLoggedIn;
@synthesize session = _session;



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // STATUS BAR COLOUR/STYLE
	[application setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    
    [self addNavbarAppearanceProxies];
    
    // FLURRY
    //[Flurry startSession:@"D4T46KDBMSNRFK3S9KHF"];
	
	// Setup any test/temporary data in here
	// FOR NOW, the log-in data iset in here
	[self initApp];
	
	// Add Feed tab ////////////////////////////////////////////////////////////////////////
	
	settingsVC = [[TASettingsVC alloc] initWithNibName:@"TASettingsVC" bundle:nil];
	[settingsVC setManagedObjectContext:[self managedObjectContext]];
    
	UINavigationController *navcon = [[UINavigationController alloc] init];
	[navcon pushViewController:settingsVC animated:NO];
	
	// Add Explore tab ////////////////////////////////////////////////////////////////////////
	
	exploreVC = [[TAExploreVC alloc] initWithNibName:@"TAExploreVC" bundle:nil];
	[exploreVC setManagedObjectContext:[self managedObjectContext]];
	
	UINavigationController *navcon2 = [[UINavigationController alloc] init];
	[navcon2 pushViewController:exploreVC animated:NO];
	
	// Add Share tab ////////////////////////////////////////////////////////////////////////
	
	cameraVC = [[TACameraVC alloc] initWithNibName:@"TACameraVC" bundle:nil];
	
	UINavigationController *navcon3 = [[UINavigationController alloc] init];
	[navcon3 pushViewController:cameraVC animated:NO];
	
	
	// Add News tab ////////////////////////////////////////////////////////////////////////
	
	notificationsVC = [[TANotificationsVC alloc] initWithNibName:@"TANotificationsVC" bundle:nil];
	
	UINavigationController *navcon4 = [[UINavigationController alloc] init];
	[navcon4 pushViewController:notificationsVC animated:NO];
	
	
	// Add Profile tab ////////////////////////////////////////////////////////////////////////
	
	profileVC = [[MeVC alloc] initWithNibName:@"MeVC" bundle:nil observeLogin:YES];
	[profileVC setManagedObjectContext:[self managedObjectContext]];
	
	UINavigationController *navcon5 = [[UINavigationController alloc] init];
	[navcon5 pushViewController:profileVC animated:NO];

	
	//////////////////////////////////////////////////////////////////////////////////////////
	
	
	// Create a tabbar controller and an array to contain the view controllers
//    CGFloat screenWidth = 320.0;
//    CGFloat screenHeight = 480.0;
//    
//    // Adding custom tab bar imagery
//    UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tab-bar-bg.png"]];
//	bgImageView.frame = CGRectMake(0, 0, screenWidth, 49);
//	
//	
//	// Detect what iOS the iPad is running and insert the tab bar background
//	// image at the appropriate index. If it's OS5 then the image has to be
//	// placed at index 1.
//	if ([[[UIDevice currentDevice] systemVersion] floatValue] < 5)
//		[[self.tabBarController tabBar] insertSubview:bgImageView atIndex:0];
//	
//	else [[self.tabBarController tabBar] insertSubview:bgImageView atIndex:1];
//	
//	
//	self.tabBarController.tabBar.frame = CGRectMake(0, (screenHeight - 49), screenWidth, 49);
	
	
	NSMutableArray *localViewControllersArray = [[NSMutableArray alloc] initWithCapacity:5];
	[localViewControllersArray addObject:navcon5];
	[localViewControllersArray addObject:navcon2];
	[localViewControllersArray addObject:navcon3];
	[localViewControllersArray addObject:navcon4];
	[localViewControllersArray addObject:navcon];
    
	
	// set the tab bar controller view controller array to the localViewControllersArray
	tabBarController.viewControllers = localViewControllersArray;

    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    // FBSample logic
    // We need to properly handle activation of the application with regards to SSO
    //  (e.g., returning from iOS 6.0 authorization dialog or from fast app switching).
    [FBSession.activeSession handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // FBSample logic
    // if the app is going away, we close the session if it is open
    // this is a good idea because things may be hanging off the session, that need
    // releasing (completion block, etc.) and other components in the app may be awaiting
    // close notification in order to do cleanup
    [FBSession.activeSession close];
    
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}


#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil) {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil) {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Gyde" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil) {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Gyde.sqlite"];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


#pragma FACEBOOK

// FBSample logic
// The native facebook application transitions back to an authenticating application when the user
// chooses to either log in, or cancel. The url passed to this method contains the token in the
// case of a successful login. By passing the url to the handleOpenURL method of a session object
// the session object can parse the URL, and capture the token for use by the rest of the authenticating
// application; the return value of handleOpenURL indicates whether or not the URL was handled by the
// session object, and does not reflect whether or not the login was successful; the session object's
// state, as well as its arguments passed to the state completion handler indicate whether the login
// was successful; note that if the session is nil or closed when handleOpenURL is called, the expression
// will be boolean NO, meaning the URL was not handled by the authenticating application
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    // attempt to extract a token from the url
    return [FBSession.activeSession handleOpenURL:url];
}


#pragma MY-METHODS

- (void)initApp {
	
	// TEST LOGIN
	//[self login];
	
	// Setup the pre-defined Tag objects in Core Data
	[self initTags];
	
	//[self initNotificationsManager];
}


- (void)initTags {
	
	[Tag tagWithTitle:@"Bars" andID:1 inManagedObjectContext:self.managedObjectContext];
	[Tag tagWithTitle:@"Cafes" andID:2 inManagedObjectContext:self.managedObjectContext];
	[Tag tagWithTitle:@"Museums" andID:3 inManagedObjectContext:self.managedObjectContext];
	[Tag tagWithTitle:@"Galleries" andID:4 inManagedObjectContext:self.managedObjectContext];
	[Tag tagWithTitle:@"Restaurants" andID:5 inManagedObjectContext:self.managedObjectContext];
	[Tag tagWithTitle:@"Sports" andID:6 inManagedObjectContext:self.managedObjectContext];
	
	[self saveContext];
}


- (NSMutableArray *)serializeImageData:(NSArray *)newPhotos {
	
	NSMutableArray *returnArray = [NSMutableArray array];
	
	for (int i = 0; i < [newPhotos count]; i++) {
		
		NSDictionary *photoDict = [newPhotos objectAtIndex:i];
		
		// Add to Core Data DB
		Photo *photo = [Photo photoWithPhotoData:photoDict inManagedObjectContext:self.managedObjectContext];
		
		// Add to return array
		[returnArray addObject:photo];
	}
	
	return returnArray;
}


- (NSMutableArray *)serializeUsersData:(NSArray *)newUsers {
	
	NSMutableArray *returnArray = [NSMutableArray array];
	
	for (NSDictionary *userDict in newUsers) {
        
		// Add to Core Data DB
		User *user = [User userWithBasicData:userDict inManagedObjectContext:self.managedObjectContext];
		
		// Add to return array
		[returnArray addObject:user];
	}
	
	return returnArray;
}


- (void)initNotificationsManager {
    
	// Initiate the notifications manager which polls the API for notifications
	TANotificationsManager *notificationsManager = [TANotificationsManager sharedManager];
	
	/*
     Register to receive change notifications for the "recommends" property of
     the 'notificationsManager' object and specify that both the old and new values of "recommends"
     should be provided in the observe… method.
     */
    [notificationsManager addObserver:self
						   forKeyPath:@"recommends"
							  options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
							  context:NULL];
	
	[notificationsManager addObserver:self
						   forKeyPath:@"meItems"
							  options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
							  context:NULL];
}


- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object change:(NSDictionary *)change
                       context:(void *)context {
	
	NSString *message;
	NSInteger recommendations = 0;
	NSInteger meItems = 0;
	
    if ([keyPath isEqual:@"recommends"])
		recommendations = [[change objectForKey:NSKeyValueChangeNewKey] intValue];
	
	else if ([keyPath isEqual:@"meItems"])
		meItems = [[change objectForKey:NSKeyValueChangeNewKey] intValue];
	
	message = [NSString stringWithFormat:@"Received %i new recommendations and %i ME items", recommendations, meItems];
	
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"HEY" message:message delegate:self cancelButtonTitle:@"OK!" otherButtonTitles:nil, nil];
	[av show];
}

// The sessionToken property can be set here
// by passing it as an argument
- (void)setToken:(NSString *)token {
	
	self.sessionToken = token;
}

- (NSMutableURLRequest *)createPostRequestWithURL:(NSURL *)url postData:(NSData *)postData {
	
	// Initialiase the URL Request
	NSMutableURLRequest *request = (NSMutableURLRequest*)[NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
	
	// Add the Authorization header with the credentials made above.
	[request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[request setValue:[NSString stringWithFormat:@"%d", [postData length]] forHTTPHeaderField:@"Content-Length"];
	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:postData];
	
	return request;
}


- (NSURL *)createRequestURLWithMethod:(NSString *)methodName testMode:(BOOL)test {
	
	NSString *api = (test ? TEST_API_ADDRESS : API_ADDRESS);
	
	// Create the URL that will be used to authenticate this user
	NSString *urlString = [NSString stringWithFormat:@"%@%@", api, methodName];
	
	NSURL *url = [urlString convertToURL];
	
	return url;
}



#pragma LOGIN METHODS

- (void)addNavbarAppearanceProxies {
    
    UIColor *navColor = [UIColor colorWithRed:158.0/255.0 green:11.0/255.0 blue:15.0/255.0 alpha:1.0];
    
    NSDictionary *navBarTextAttributes = @{
        UITextAttributeFont : [UIFont fontWithName:@"FreightSansBold" size:20],
        UITextAttributeTextShadowColor : navColor,
        UITextAttributeTextShadowOffset : [NSValue valueWithUIOffset:UIOffsetMake(0,1)]
	};
    
    
	[[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"nav-bar-blank.png"] forBarMetrics:UIBarMetricsDefault];
	[[UINavigationBar appearance] setTitleVerticalPositionAdjustment:3 forBarMetrics:UIBarMetricsDefault];
	[[UINavigationBar appearance] setTintColor:navColor];
	[[UINavigationBar appearance] setTitleTextAttributes:navBarTextAttributes];
        
    [[UIBarButtonItem appearance] setBackgroundImage:[[UIImage imageNamed:@"navBarButton.png"]
                                                      resizableImageWithCapInsets:UIEdgeInsetsMake(12, 4, 12, 4)]
                                            forState:UIControlStateNormal
                                          barMetrics:UIBarMetricsDefault];
    
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:[[UIImage imageNamed:@"navBarBack.png"]
                                                                resizableImageWithCapInsets:UIEdgeInsetsMake(4, 11, 0, 5)]
                                                      forState:UIControlStateNormal
                                                    barMetrics:UIBarMetricsDefault];
}

- (void)removeNavbarAppearanceProxies {
    [[UINavigationBar appearance] setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [[UIBarButtonItem appearance] setBackgroundImage:nil forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:nil forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
}


- (NSArray *)serializeGuideData:(NSArray *)newGuides {
	
	NSMutableArray *returnArray = [NSMutableArray array];
	
	for (int i = 0; i < [newGuides count]; i++) {
		
		NSDictionary *guideDictionary = [newGuides objectAtIndex:i];
		
		// Add to Core Data DB
		Guide *guide = [Guide guideWithGuideData:guideDictionary inManagedObjectContext:self.managedObjectContext];
		
		// Add to return array
		[returnArray addObject:guide];
	}
	
	NSArray *guides = [returnArray copy];
	
	return guides;
}


- (NSArray *)serializePhotoData:(NSArray *)newPhotos {
	
	NSMutableArray *returnArray = [NSMutableArray array];
	
	for (NSDictionary *photoDict in newPhotos) {
		
		// Add to Core Data DB
		Photo *photo = [Photo photoWithPhotoData:photoDict inManagedObjectContext:self.managedObjectContext];
		
		// Add to return array
		[returnArray addObject:photo];
	}
	
	NSArray *photos = [returnArray copy];
	
	return photos;
}


- (void)setTwitterUserID:(NSString *)newUserID {
    
	[[NSUserDefaults standardUserDefaults] setObject:newUserID forKey:ktwitterUserIDKey];
}


- (void)setTwitterUsername:(NSString *)newUsername {
	
	[[NSUserDefaults standardUserDefaults] setObject:newUsername forKey:kTwitterUsernameKey];
}


- (void)setTwitterAccountID:(NSString *)newAccountID {
	
	[[NSUserDefaults standardUserDefaults] setObject:newAccountID forKey:kTwitterAccountIDKey];
}


- (NSString *)getTwitterUserID {
	
	return [[NSUserDefaults standardUserDefaults] objectForKey:ktwitterUserIDKey];
}


- (NSString *)getTwitterUsername {
	
	return [[NSUserDefaults standardUserDefaults] objectForKey:kTwitterUsernameKey];
}


- (NSString *)getTwitterAccountID {
	
	return [[NSUserDefaults standardUserDefaults] objectForKey:kTwitterAccountIDKey];
}


- (void)quitCamera {
    
    [self.tabBarController setSelectedIndex:0];
}


@end
