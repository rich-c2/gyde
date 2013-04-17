//
//  TAImageGridVC.h
//  Tourism App
//
//  Created by Richard Lee on 21/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GridImage.h"
#import "TAExploreVC.h"

@class HTTPFetcher;

#define LATEST_MODE_TAG 9000
#define POPULAR_MODE_TAG 9001

typedef enum  {
	ImagesModeMyPhotos = 0,
	ImagesModeLikedPhotos = 1,
	ImagesModeCityTag = 2
} ImagesMode;

typedef enum {
	SortModeLatest = LATEST_MODE_TAG,
	SortModePopular = POPULAR_MODE_TAG
} SortMode;

@interface TAImageGridVC : UIViewController <GridImageDelegate, ExploreDelegate> {
	
	ImagesMode imagesMode;
	
	// This only applies the 'Explore' journey
	SortMode sortMode;	
	IBOutlet UISegmentedControl *sortModeToggler;
	
	// City/Tag combo data
	NSNumber *tagID;
	NSString *tag;
	NSString *city;
	
	NSInteger fetchSize;
	NSInteger imagesPageIndex;

	IBOutlet UIView *imagesView;
	IBOutlet UIScrollView *gridScrollView;
	
	HTTPFetcher *imagesFetcher;
	
	BOOL loading;
	BOOL imagesLoaded;
	
	BOOL isDragging;
	BOOL refresh;
	
	BOOL filterMode;
	
	UIBarButtonItem *resetButton;
	UIBarButtonItem *filterButton;
	
	NSMutableArray *masterArray;
	NSMutableArray *photos;
	NSMutableArray *filteredPhotos;
	
	NSString *username;
}

@property SortMode sortMode;
@property (nonatomic, retain) IBOutlet UISegmentedControl *sortModeToggler;

@property ImagesMode imagesMode;

@property (nonatomic, retain) NSNumber *tagID;
@property (nonatomic, retain) NSString *tag;
@property (nonatomic, retain) NSString *city;

@property (nonatomic, retain) IBOutlet UIView *imagesView;
@property (nonatomic, retain) IBOutlet UIScrollView *gridScrollView;

@property (nonatomic, retain) UIButton *selectedTabButton;
@property (nonatomic, retain) NSString *username;

@property (nonatomic, retain) UIBarButtonItem *resetButton;
@property (nonatomic, retain) UIBarButtonItem *filterButton;

@property (nonatomic, retain) NSMutableArray *masterArray;
@property (nonatomic, retain) NSMutableArray *photos;
@property (nonatomic, retain) NSMutableArray *filteredPhotos;

- (IBAction)loadMoreButtonClicked:(id)sender;
- (IBAction)goBack:(id)sender;
- (IBAction)sortModeWasChanged:(id)sender;

@end
