//
//  TAGuideDetailsVC.h
//  Tourism App
//
//  Created by Richard Lee on 28/08/12.
//  Copyright (c) 2012 C2 Media Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GridImage.h"
#import "TAUsersVC.h"
#import <MessageUI/MessageUI.h>
#import <MapKit/MapKit.h>
#import <FacebookSDK/FacebookSDK.h>

@class HTTPFetcher;
@class TAPhotoTableCell;

typedef enum  {
	GuideModeCreated = 0,
	GuideModeViewing = 1
} GuideMode;

@interface TAGuideDetailsVC : UIViewController <GridImageDelegate, UIActionSheetDelegate, RecommendsDelegate, MFMailComposeViewControllerDelegate> {

	GuideMode guideMode;
	MKMapView *guideMap;
	
	IBOutlet UITableView *photosTable;
	
	TAPhotoTableCell *loadCell;
	
	HTTPFetcher *loveFetcher;
	
	NSDictionary *guideData;
	NSMutableArray *photos;
	NSString *guideID;
	
	BOOL isLoved;
	BOOL loading;
	BOOL guideLoaded;
	
	UIButton *authorBtn;
	IBOutlet UIScrollView *gridScrollView;
	UILabel *titleLabel;
	IBOutlet UIView *imagesView;
}

@property GuideMode guideMode;
@property (nonatomic, retain) MKMapView *guideMap;

@property (retain, nonatomic) UIButton *loveBtn;
@property (retain, nonatomic) UIButton *photosCountBtn;
@property (retain, nonatomic) UIButton *timeElapsedBtn;
@property (retain, nonatomic) UITextView *descriptionView;
@property (retain, nonatomic) UILabel *headerLabel;

@property (nonatomic, retain) IBOutlet UITableView *photosTable;

@property (nonatomic, retain) IBOutlet UIImageView *guideThumb;

@property (nonatomic, retain) IBOutlet TAPhotoTableCell *loadCell;

@property (nonatomic, retain) NSDictionary *guideData;
@property (nonatomic, retain) NSMutableArray *photos;
@property (nonatomic, retain) NSString *guideID;

@property (nonatomic, retain) IBOutlet UIButton *authorBtn;
@property (nonatomic, retain) IBOutlet UIScrollView *gridScrollView;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UIView *imagesView;

@property (nonatomic, retain) NSMutableDictionary *postParams;

- (IBAction)authorButtonTapped:(id)sender;
- (IBAction)initFollowersList:(id)sender;
- (void)configureCell:(TAPhotoTableCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (IBAction)publishGuideToFacebookFeed:(id)sender;
- (IBAction)displayEmail:(id)sender;

@end
