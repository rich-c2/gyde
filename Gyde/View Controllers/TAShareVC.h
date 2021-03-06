//
//  TAShareVC.h
//  Tourism App
//
//  Created by Richard Lee on 28/08/12.
//  Copyright (c) 2012 C2 Media Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TASimpleListVC.h"
#import "CoreLocation/CoreLocation.h"
#import "TAUsersVC.h"
#import "TAPlacesVC.h"
#import <FacebookSDK/FacebookSDK.h>
#import "TAGuidesListVC.h"
#import <MapKit/MapKit.h>

@class Tag;
@class ACAccountStore;

@interface TAShareVC : UIViewController <TagsDelegate, GuidesListDelegate, RecommendsDelegate, PlacesDelegate> {
	
	// Was the submission of the photo successful?
	BOOL submissionSuccess;
    BOOL postToFacebook;
    BOOL addToGuide;
    BOOL createNewGuide;
	
	// UI
	IBOutlet UITextField *captionField;
	IBOutlet UILabel *tagLabel;
	IBOutlet UILabel *cityLabel;
	
	IBOutlet UIImageView *photoView;
		
	NSString *selectedCity;
	Tag *selectedTag;
	NSMutableArray *recommendToUsernames;
	NSMutableDictionary *placeData;

	UIImage *photo;
	NSURL *imageReferenceURL;
	
	CLLocation *currentLocation;
	
	IBOutlet UILabel *placeTitleLabel;
	IBOutlet UIScrollView *scrollView;
	
	ACAccountStore *savedAccountStore;
	NSString *selectedAccountIdentifier;
}


@property (nonatomic, retain) IBOutlet UITextField *captionField;
@property (nonatomic, retain) IBOutlet UILabel *tagLabel;
@property (nonatomic, retain) IBOutlet UILabel *cityLabel;
@property (nonatomic, retain) IBOutlet MKMapView *map;

@property (nonatomic, retain) IBOutlet UIButton *recommendBtn;

@property (nonatomic, retain) IBOutlet UIImageView *photoView;

@property (nonatomic, retain) NSString *selectedCity;
@property (nonatomic, retain) Tag *selectedTag;
@property (nonatomic, retain) NSMutableArray *recommendToUsernames;
@property (nonatomic, retain) NSMutableDictionary *placeData;
@property (nonatomic, retain) NSMutableDictionary *guideData;

@property (nonatomic, retain) UIImage *photo;
@property (nonatomic, retain) NSURL *imageReferenceURL;

@property (nonatomic, retain) CLLocation *currentLocation;

@property (nonatomic, retain) IBOutlet UILabel *placeTitleLabel;
@property (nonatomic, retain) IBOutlet UILabel *placeAddressLabel;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;

@property (nonatomic, retain) ACAccountStore *savedAccountStore;
@property (nonatomic, retain) NSString *selectedAccountIdentifier;

@property (nonatomic, assign) BOOL shareOnTwitter;

- (IBAction)recommendButtonTapped:(id)sender;

@end
