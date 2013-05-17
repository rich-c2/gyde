//
//  TAExploreVC.h
//  Tourism App
//
//  Created by Richard Lee on 28/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TASimpleListVC.h"
#import "TACitiesVC.h"
#import "CoreLocation/CoreLocation.h"
#import "TAThumbsSlider.h"
#import <MapKit/MapKit.h>

@class Tag;
@class MyCoreLocation;
@class XMLFetcher;
@class HTTPFetcher;
@class ASINetworkQueue;
@class City;
@class TagsCell;

typedef enum {
	ExploreModeRegular = 0,
	ExploreModeSubset = 1
} ExploreMode;


typedef enum {
	TableModeCities = 0,
	TableModeTags = 1
} TableMode;

@protocol ExploreDelegate

- (void)finishedFilteringWithPhotos:(NSArray *)results;

@end


@interface TAExploreVC : UIViewController <MKReverseGeocoderDelegate, TagsDelegate, CityDelegate, ThumbsSliderDelegate> {
	
    TableMode tableMode;
    
	// Needed?
	BOOL loading;
    BOOL citiesLoaded;
    
	BOOL slidersLoaded;
    BOOL featuredPhotosLoaded;
    BOOL featuredGuidesLoaded;
    BOOL popularGuidesLoaded;
    BOOL recentPhotosLoaded;
    
    NSArray *tableData;
	
    BOOL searching;
    
    IBOutlet TagsCell *loadCell;
    
	IBOutlet UIView *filterView;
	BOOL filtering;
	IBOutlet UIView *tagFieldContainer;
    
    UITableView *tagsTable;
    
    NSInteger fetchSize;
	
	id <ExploreDelegate> delegate;
	
	NSManagedObjectContext *managedObjectContext;
			
	IBOutlet UIScrollView *slidesContainer;
    
	HTTPFetcher	*citySearchFetcher;
	HTTPFetcher *popularFetcher;
    HTTPFetcher *guidesFetcher;
    
    HTTPFetcher *featuredPhotosFetcher;
    HTTPFetcher *featuredGuidesFetcher;
	
	ExploreMode exploreMode;	
	
	Tag *selectedTag;
	NSString *selectedCity;
    
    UIButton *tagBtn;
	
	
	// LOCATION VARS
	MyCoreLocation *locationManager;
	CLLocation *currentLocation;
	BOOL useCurrentLocation;
}

@property (nonatomic, strong) UILabel *titleView;
@property (nonatomic, strong) UILabel *subtitleView;

@property (nonatomic, strong) MKReverseGeocoder *reverseGeocoder;

@property (nonatomic, retain) id <ExploreDelegate> delegate;

@property TableMode tableMode;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (retain, nonatomic) IBOutlet UILabel *navBarTitle;
@property (nonatomic, retain) IBOutlet UIScrollView *slidesContainer;

@property (nonatomic, retain) IBOutlet TagsCell *loadCell;

@property (nonatomic, retain) IBOutlet UIView *filterView;
@property (assign) BOOL filtering;
@property (nonatomic, retain) IBOutlet UIView *tagFieldContainer;

@property (nonatomic, retain) IBOutlet UITableView *tagsTable;

@property ExploreMode exploreMode;

@property (nonatomic, retain) ASINetworkQueue *queue;
@property (nonatomic, retain) NSMutableArray *requests;

// SLIDERS
@property (nonatomic, retain) TAThumbsSlider *popularPhotosSlider;
@property (nonatomic, retain) TAThumbsSlider *recentGuidesSlider;
@property (nonatomic, retain) TAThumbsSlider *popularGuidesSlider;
@property (nonatomic, retain) TAThumbsSlider *recentPhotosSlider;

@property (nonatomic, retain) NSArray *tags;

@property (nonatomic, retain) NSArray *featuredPhotos;
@property (nonatomic, retain) NSArray *recentPhotos;
@property (nonatomic, retain) NSArray *popularGuides;
@property (nonatomic, retain) NSArray *recentGuides;

@property (nonatomic, retain) NSArray *cities;
@property (nonatomic, retain) NSArray *tableData;

@property (nonatomic, retain) IBOutlet UITextField *tagField;
@property (nonatomic, retain) IBOutlet UITextField *cityField;

@property (nonatomic, retain) Tag *selectedTag;
@property (nonatomic, retain) NSString *selectedCity;
@property (nonatomic, retain) NSString *nearbyCity;
@property (nonatomic, retain) IBOutlet UIButton *filterBtn;
@property (nonatomic, retain) IBOutlet UIButton *nearbyBtn;
@property (nonatomic, retain) IBOutlet UIButton *searchBtn;
@property (nonatomic, retain) IBOutlet UIButton *tagBtn;

@property (nonatomic, retain) MyCoreLocation *locationManager;
@property (nonatomic, retain) CLLocation *currentLocation;

- (IBAction)filterButtonTapped:(id)sender;
//- (IBAction)nearbyButtonTapped:(id)sender;
- (void)willLogout;
- (IBAction)nearbyButtonTapped:(id)sender;
- (IBAction)searchButtonTapped:(id)sender;

@end
