//
//  TANotificationsVC.h
//  Tourism App
//
//  Created by Richard Lee on 22/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define RECOMMENDS_NEWS_TAG 9000
#define ME_NEWS_TAG 9001
#define FOLLOWING_NEWS_TAG 9002

@class MyGuidesTableCell;

typedef enum  {
	NotificationsCategoryRecommendations = RECOMMENDS_NEWS_TAG,
	NotificationsCategoryMe = ME_NEWS_TAG, 
	NotificationsCategoryFollowing = FOLLOWING_NEWS_TAG
} NotificationsCategory;

@interface TANotificationsVC : UIViewController {

    NotificationsCategory selectedCategory;
    
    HTTPFetcher *recommendationsFetcher;
	
	BOOL loading;
	BOOL recommendationsLoaded;
	
	NSMutableArray *notifications;
	NSMutableArray *reccomendations;
	NSMutableArray *meItems;
	NSMutableArray *following;
    
	IBOutlet UITableView *recommendationsTable;
}

@property NotificationsCategory selectedCategory;

@property (nonatomic, retain) UIButton *selectedTabButton;

@property (nonatomic, retain) NSMutableArray *notifications;
@property (nonatomic, retain) NSMutableArray *reccomendations;
@property (nonatomic, retain) NSMutableArray *meItems;
@property (nonatomic, retain) NSMutableArray *following;

@property (nonatomic, retain) IBOutlet UIImageView *tabPointer;

@property (nonatomic, retain) IBOutlet UITableView *recommendationsTable;

- (NSString *)getSelectedCategory;
- (void)willLogout;

@end
