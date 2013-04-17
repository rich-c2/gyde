//
//  TAMediaResultsVC.h
//  Tourism App
//
//  Created by Richard Lee on 30/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GridImage.h"

@class ASIHTTPRequest;

#define GUIDES_MODE_TAG 9000
#define PHOTOS_MODE_TAG 9001

typedef enum {
    ResultsModeGuides = GUIDES_MODE_TAG,
    ResultsModePhotos = PHOTOS_MODE_TAG
} ResultsMode;

@interface TAMediaResultsVC : UIViewController <GridImageDelegate> {
	
    ResultsMode resultsMode;
    
    NSInteger imagesPageIndex;
    NSInteger fetchSize;
	
    BOOL guidesLoaded;
    BOOL imagesLoaded;
}

@property ResultsMode resultsMode;

@property (nonatomic, retain) ASIHTTPRequest *findMediaRequest;
@property (nonatomic, retain) ASIHTTPRequest *findGuidesRequest;

@property (nonatomic, retain) NSNumber *tagID;
@property (nonatomic, retain) NSString *tag;
@property (nonatomic, retain) NSString *city;

@property (retain, nonatomic) UIButton *selectedTabButton;

@property (retain, nonatomic) IBOutlet UILabel *searchInputTitle;
@property (retain, nonatomic) IBOutlet UITableView *guidesTable;
@property (retain, nonatomic) IBOutlet UIScrollView *gridScrollView;

@property (nonatomic, retain) NSMutableArray *guides;
@property (nonatomic, retain) NSMutableArray *photos;


@end
