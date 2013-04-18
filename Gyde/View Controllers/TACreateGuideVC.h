//
//  TACreateGuideVC.h
//  Tourism App
//
//  Created by Richard Lee on 27/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TAUsersVC.h"
#import "TAGuidesListVC.h"

@class HTTPFetcher;

@interface TACreateGuideVC : UIViewController <RecommendsDelegate> {

	HTTPFetcher *fetcher;
	HTTPFetcher *recommendFetcher;
	
	NSMutableArray *recommendToUsernames;
	
	NSString *imageCode;
	NSNumber *guideTagID;
	NSString *guideCity;
	
	IBOutlet UILabel *tagLabel;
	IBOutlet UILabel *cityLabel;
	IBOutlet UITextField *titleField;
    IBOutlet UITextField *descriptionField;
}

@property (nonatomic, retain) id <GuidesListDelegate> delegate;

@property (nonatomic, retain) NSMutableArray *recommendToUsernames;

@property (nonatomic, retain) NSString *imageCode;
@property (nonatomic, retain) NSNumber *guideTagID;
@property (nonatomic, retain) NSString *guideCity;

@property (nonatomic, retain) IBOutlet UILabel *tagLabel;
@property (nonatomic, retain) IBOutlet UILabel *cityLabel;
@property (nonatomic, retain) IBOutlet UITextField *titleField;
@property (nonatomic, retain) IBOutlet UITextField *descriptionField;

@property (nonatomic, assign) BOOL addToFacebook;
@property (nonatomic, assign) BOOL shareOnTwitter;

- (IBAction)submitButtonTapped:(id)sender;
- (IBAction)recommendButtonTapped:(id)sender;

@end
