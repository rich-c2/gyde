//
//  TAScrollVC.h
//  Tourism App
//
//  Created by Richard Lee on 18/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TAUsersVC.h"
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>
#import "TAPhotoFrame.h"
#import "TAPhotoDetails.h"
#import "TAMapVC.h"

@class HTTPFetcher;

typedef enum  {
    PhotosModeRegular = 0,
	PhotosModeMyPhotos = 1,
	PhotosModeLovedPhotos = 2,
    PhotosModeSinglePhoto = 3
} PhotosMode;

@interface TAScrollVC : UIViewController <RecommendsDelegate, PhotoDetailsDelegate, UIActionSheetDelegate, ModalMapDelegate> {
	
    PhotosMode photosMode;
        
	// Test views
	UIImageView *mainView;

	// Close button
	IBOutlet UIButton *closeBtn;
	
	// BOOL trackers
	BOOL loading;
	BOOL photosLoaded;
    BOOL uploadsLoaded;
	
	// Toolbar buttons
	UIBarButtonItem *loveBtn;
	
	HTTPFetcher *loveFetcher;
	HTTPFetcher *recommendFetcher;
	HTTPFetcher *vouchFetcher;
	HTTPFetcher *flagFetcher;
	HTTPFetcher *addCommentFetcher;
	HTTPFetcher *addToGuideFetcher;
	HTTPFetcher *createGuidefetcher;
    HTTPFetcher *uploadsFetcher;
    HTTPFetcher *lovedPhotosFetcher;
    HTTPFetcher *mediaFetcher;
	
	NSInteger fetchSize;
	NSInteger imagesPageIndex;
	
	NSInteger scrollIndex;
	
	IBOutlet UIScrollView *photosScrollView;
	NSString *selectedPhotoID;
	
	NSMutableArray *photos;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property PhotosMode photosMode;

@property (nonatomic, retain) UIView *mainView;

@property (nonatomic, retain) IBOutlet UIBarButtonItem *loveBtn;

@property (nonatomic, retain) IBOutlet UIScrollView *photosScrollView;
@property (nonatomic, retain) NSString *selectedPhotoID;

@property (nonatomic, retain) NSMutableArray *photos;

- (IBAction)goBack:(id)sender;

@end
